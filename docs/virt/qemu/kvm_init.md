# KVMの初期化


## Contents
| Link | Description |
| --- | --- |
| [KVMの初期化処理の起点](#init-kvm-start) | main関数ないで、MachineClass、AddressSpaceが初期化された後に呼び出される |
| [kvm_init](#kvm_init)                    | KVMの初期化処理の実態 |
| [kvm_arch_init](#kvm_arck_init)          | KVMへのメモリ登録、ioeventfdの設定 |


<a name="init-kvm-start"></a>
## KVMの初期化処理の起点
* MachineClassのインスタンス化が完了し、vcpuがrealize(スレッド起動し待ち状態)し、AddressSpaceが初期化された後に、kvmの初期化を行う
> vl.c
``` c
3091 int main(int argc, char **argv, char **envp)
3092 {
...
4220     machine_class = select_machine();  // 起動オプションをパースしてMachineClassを選択
4221
4222     set_memory_options(&ram_slots, &maxram_size, machine_class);
4223
4224     os_daemonize();
4225     rcu_disable_atfork();
...
4259     current_machine = MACHINE(object_new(object_class_get_name(  // MachineClassのインスタンス化
4260                           OBJECT_CLASS(machine_class))));
...
4276     cpu_exec_init_all();  # AddressSpaceの初期化
...
4537     configure_accelerator(current_machine);  // kvmの初期化(kvm-all.c: kvm_init)
```

* configure_acceleratorは、最終的にkvm-allのkvm_initを呼び出す
> accel/accel.c
``` c
 54 static int accel_init_machine(AccelClass *acc, MachineState *ms)
 55 {
 56     ObjectClass *oc = OBJECT_CLASS(acc);
 57     const char *cname = object_class_get_name(oc);
 58     AccelState *accel = ACCEL(object_new(cname));
 59     int ret;
 60     ms->accelerator = accel;
 61     *(acc->allowed) = true;
 62     ret = acc->init_machine(ms);
 63     if (ret < 0) {
 64         ms->accelerator = NULL;
 65         *(acc->allowed) = false;
 66         object_unref(OBJECT(accel));
 67     }
 68     return ret;
 69 }

 71 void configure_accelerator(MachineState *ms)
 72 {
 101         ret = accel_init_machine(acc, ms);
```

> kvm.c
```
2498 static void kvm_accel_class_init(ObjectClass *oc, void *data)
2499 {
2500     AccelClass *ac = ACCEL_CLASS(oc);
2501     ac->name = "KVM";
2502     ac->init_machine = kvm_init;
2503     ac->allowed = &kvm_allowed;
2504 }
```


## kvm_init
* ここで、kvm_stateを初期化する
* kvm-fdの取得、kvm-vm-fdの取得、MemoryListenerの登録処理
```
 108 KVMState *kvm_state;

1454 static int kvm_init(MachineState *ms)
1455 {
1456     MachineClass *mc = MACHINE_GET_CLASS(ms);
...
1469     KVMState *s;
...
1475     s = KVM_STATE(ms->accelerator);
...
1492     s->fd = qemu_open("/dev/kvm", O_RDWR); // kvm-fdを取得
...
1531     do {
1532         ret = kvm_ioctl(s, KVM_CREATE_VM, type); // kvm-vm-fdを取得
1533     } while (ret == -EINTR);
...
1633     kvm_state = s;  // globalのkvm_stateに代入
1634
1635     ret = kvm_arch_init(ms, s); // アーキテクチャ固有のinit処理を行う
...
1644     if (kvm_eventfds_allowed) {
1645         s->memory_listener.listener.eventfd_add = kvm_mem_ioeventfd_add;
1646         s->memory_listener.listener.eventfd_del = kvm_mem_ioeventfd_del;
1647     }
1648     s->memory_listener.listener.coalesced_mmio_add = kvm_coalesce_mmio_region;
1649     s->memory_listener.listener.coalesced_mmio_del = kvm_uncoalesce_mmio_region;
1650
1651     kvm_memory_listener_register(s, &s->memory_listener,
1652                                  &address_space_memory, 0);
1653     memory_listener_register(&kvm_io_listener,
1654                              &address_space_io);
1655
1656     s->many_ioeventfds = kvm_check_many_ioeventfds();
1657
1658     s->sync_mmu = !!kvm_vm_check_extension(kvm_state, KVM_CAP_SYNC_MMU);
1659
1660     return 0;
...
1673 }
```


## kvm_arch_init
* KVMにメモリをセット
* qemu_add_machine_init_done_notifierで、machineの初期化終了時に、register_smram_listenerが実行されるようにしている
> target/i386/kvm.c
``` c
1195 int kvm_arch_init(MachineState *ms, KVMState *s)
1196 {
...
1257     shadow_mem = machine_kvm_shadow_mem(ms);
1258     if (shadow_mem != -1) {
1259         shadow_mem /= 4096;
1260         ret = kvm_vm_ioctl(s, KVM_SET_NR_MMU_PAGES, shadow_mem);
1261         if (ret < 0) {
1262             return ret;
1263         }
1264     }
1265
1266     if (kvm_check_extension(s, KVM_CAP_X86_SMM) &&
1267         object_dynamic_cast(OBJECT(ms), TYPE_PC_MACHINE) &&
1268         pc_machine_is_smm_enabled(PC_MACHINE(ms))) {
1269         smram_machine_done.notify = register_smram_listener;
1270         qemu_add_machine_init_done_notifier(&smram_machine_done);
1271     }
1272     return 0;
1273 }
```

* register_smram_listenerでは、address_space_initを実施
* address_space_init内で、eventfdを利用するもの(virtio)がある場合は、eventfd_addを行う
> target/i386/kvm.c
```
1161 static Notifier smram_machine_done;
1162 static KVMMemoryListener smram_listener;
1163 static AddressSpace smram_address_space;
1164 static MemoryRegion smram_as_root;
1165 static MemoryRegion smram_as_mem;
1166
1167 static void register_smram_listener(Notifier *n, void *unused)
1168 {
1169     MemoryRegion *smram =
1170         (MemoryRegion *) object_resolve_path("/machine/smram", NULL);
1171
1172     /* Outer container... */
1173     memory_region_init(&smram_as_root, OBJECT(kvm_state), "mem-container-smram", ~0ull);
1174     memory_region_set_enabled(&smram_as_root, true);
1175
1176     /* ... with two regions inside: normal system memory with low
1177      * priority, and...
1178      */
1179     memory_region_init_alias(&smram_as_mem, OBJECT(kvm_state), "mem-smram",
1180                              get_system_memory(), 0, ~0ull);
1181     memory_region_add_subregion_overlap(&smram_as_root, 0, &smram_as_mem, 0);
1182     memory_region_set_enabled(&smram_as_mem, true);
1183
1184     if (smram) {
1185         /* ... SMRAM with higher priority */
1186         memory_region_add_subregion_overlap(&smram_as_root, 0, smram, 10);
1187         memory_region_set_enabled(smram, true);
1188     }
1189
1190     address_space_init(&smram_address_space, &smram_as_root, "KVM-SMRAM");
1191     kvm_memory_listener_register(kvm_state, &smram_listener,
1192                                  &smram_address_space, 1);
1193 }
```

* eventfd_addの実態は、kvm_set_ioeventfd_mmioとkvm_set_ioeventfd_pio
* これにより、virtioドライバからの通知をioeventfd経由で受け取れるようになる
> accel/kvm/kvm-all.c
``` c
 580 static int kvm_set_ioeventfd_mmio(int fd, hwaddr addr, uint32_t val,
 581                                   bool assign, uint32_t size, bool datamatch)
 582 {
 583     int ret;
 584     struct kvm_ioeventfd iofd = {
 585         .datamatch = datamatch ? adjust_ioeventfd_endianness(val, size) : 0,
 586         .addr = addr,
 587         .len = size,
 588         .flags = 0,
 589         .fd = fd,
 590     };
 591
 592     if (!kvm_enabled()) {
 593         return -ENOSYS;
 594     }
 595
 596     if (datamatch) {
 597         iofd.flags |= KVM_IOEVENTFD_FLAG_DATAMATCH;
 598     }
 599     if (!assign) {
 600         iofd.flags |= KVM_IOEVENTFD_FLAG_DEASSIGN;
 601     }
 602
 603     ret = kvm_vm_ioctl(kvm_state, KVM_IOEVENTFD, &iofd);
 604
 605     if (ret < 0) {
 606         return -errno;
 607     }
 608
 609     return 0;
 610 }
 611
 612 static int kvm_set_ioeventfd_pio(int fd, uint16_t addr, uint16_t val,
 613                                  bool assign, uint32_t size, bool datamatch)
 614 {
 615     struct kvm_ioeventfd kick = {
 616         .datamatch = datamatch ? adjust_ioeventfd_endianness(val, size) : 0,
 617         .addr = addr,
 618         .flags = KVM_IOEVENTFD_FLAG_PIO,
 619         .len = size,
 620         .fd = fd,
 621     };
 622     int r;
 623     if (!kvm_enabled()) {
 624         return -ENOSYS;
 625     }
 626     if (datamatch) {
 627         kick.flags |= KVM_IOEVENTFD_FLAG_DATAMATCH;
 628     }
 629     if (!assign) {
 630         kick.flags |= KVM_IOEVENTFD_FLAG_DEASSIGN;
 631     }
 632     r = kvm_vm_ioctl(kvm_state, KVM_IOEVENTFD, &kick);
 633     if (r < 0) {
 634         return r;
 635     }
 636     return 0;
 637 }
```

# 仮想CPUのrealize


## Contents
| Link | Description |
| --- | --- |
| [仮想CPUの初期化処理の開始場所](#vcpu-init-start)        | MachineClassの初期化時に仮想CPUも初期化(インスタンス化とrealize)をしている |
| [DeviceClassとrealizeについて](#deviceclass-and-realize) | 仮想CPUはDeviceClassとして定義されており、そのrealizeの仕組みについて |
| [仮想CPUのrealize](#vcpu-realize)                        | 仮想CPUのrealize内での処理について(vcpuスレッドは起動するが、他のデバイスが準備できるまでは待機する) |


<a name="vcpu-init-start"></a>
## 仮想CPUの初期化処理の開始場所
* MachineClassの初期化時に、仮想CPUも初期化(インスタンス化とrealize)をしている

> hw/i386/pc_piix.c
``` c
 66 /* PC hardware initialisation */
 67 static void pc_init1(MachineState *machine,
 68                      const char *host_type, const char *pci_type)
 69 {
 ...
 151     pc_cpus_init(pcms);
 ...
 305 }
```

* pc_new_cpuで、CPUのインスタンスを作成し、cpuにrealizedプロパティにtrueを設定している
    * このとき、CPUのrealizeが実行される
> hw/i386/pc.c
```
1094 static void pc_new_cpu(const char *typename, int64_t apic_id, Error **errp)
1095 {
1096     Object *cpu = NULL;
1097     Error *local_err = NULL;
1098
1099     cpu = object_new(typename);
1100
1101     object_property_set_uint(cpu, apic_id, "apic-id", &local_err);
1102     object_property_set_bool(cpu, true, "realized", &local_err);
1103
1104     object_unref(cpu);
1105     error_propagate(errp, local_err);
1106 }
...
1133 void pc_cpus_init(PCMachineState *pcms)
1134 {
1135     int i;
1136     const CPUArchIdList *possible_cpus;
1137     MachineState *ms = MACHINE(pcms);
1138     MachineClass *mc = MACHINE_GET_CLASS(pcms);
1139
1140     /* Calculates the limit to CPU APIC ID values
1141      *
1142      * Limit for the APIC ID value, so that all
1143      * CPU APIC IDs are < pcms->apic_id_limit.
1144      *
1145      * This is used for FW_CFG_MAX_CPUS. See comments on bochs_bios_init().
1146      */
1147     pcms->apic_id_limit = x86_cpu_apic_id_from_index(max_cpus - 1) + 1;
1148     possible_cpus = mc->possible_cpu_arch_ids(ms);
1149     for (i = 0; i < smp_cpus; i++) {
1150         pc_new_cpu(ms->cpu_type, possible_cpus->cpus[i].arch_id, &error_fatal);
1151     }
1152 }
```


<a name="deviceclass-and-realize"></a>
## DeviceClassとrealizeについて
* DeviceClassのインスタンスのrealizeプロパティに値を設定すると、そのClassのrealize関数が呼ばれる

* QOMにおけるプロパティは文字列をキーにした連想配列でセッタとゲッタを持っている
    * Objectのプロパティに値をsetした時にセッタ関数を、getしたときにゲッタ関数を呼ぶことができる
    * これは、object_property_add_ でプロパティを追加する際に設定する
> qom/object.c
``` c
1916 void object_property_add_bool(Object *obj, const char *name,
1917                               bool (*get)(Object *, Error **),
1918                               void (*set)(Object *, bool, Error **),
1919                               Error **errp)
1920 {
1921     Error *local_err = NULL;
1922     BoolProperty *prop = g_malloc0(sizeof(*prop));
1923
1924     prop->get = get;
1925     prop->set = set;
1926
1927     object_property_add(obj, name, "bool",
1928                         get ? property_get_bool : NULL,
1929                         set ? property_set_bool : NULL,
1930                         property_release_bool,
1931                         prop, &local_err);
1932     if (local_err) {
1933         error_propagate(errp, local_err);
1934         g_free(prop);
1935     }
1936 }
```

* type_initで、DeviceClassの型を宣言している
* instance_initには、device_initfnが登録されており、この中でrealizedプロパティを登録している
    * また、このセッタとして、device_set_realizedを登録している
    * つまり、realizedプロパティに値をsetすると、DeviceClassのrealizeが呼ばれる
> hw/core/qdev.c
``` c
 875 static void device_set_realized(Object *obj, bool value, Error **errp)
 876 {
 877     DeviceState *dev = DEVICE(obj);
 878     DeviceClass *dc = DEVICE_GET_CLASS(dev);
 ...
 890     if (value && !dev->realized) {
 ...
 913         if (dc->realize) {
 914             dc->realize(dev, &local_err);
 915         }
 ...
 974     }
 ...
 1006 }

1024 static void device_initfn(Object *obj)
1025 {
1026     DeviceState *dev = DEVICE(obj);
1027     ObjectClass *class;
1028     Property *prop;
...
1038     object_property_add_bool(obj, "realized",
1039                              device_get_realized, device_set_realized, NULL);
...
1059 }

1163 static const TypeInfo device_type_info = {
1164     .name = TYPE_DEVICE,
1165     .parent = TYPE_OBJECT,
1166     .instance_size = sizeof(DeviceState),
1167     .instance_init = device_initfn,
1168     .instance_post_init = device_post_init,
1169     .instance_finalize = device_finalize,
1170     .class_base_init = device_class_base_init,
1171     .class_init = device_class_init,
1172     .abstract = true,
1173     .class_size = sizeof(DeviceClass),
1174 };
1175
1176 static void qdev_register_types(void)
1177 {
1178     type_register_static(&device_type_info);
1179 }
1180
1181 type_init(qdev_register_types)
```

* TYPE_X86_CPUは、TYPE_CPUを継承しており、TYPE_CPUはTYPE_DEVICEを継承している
* realizeには、x86_cpu_realizefnが登録されている
> qom/cpu.c
``` c
491 static const TypeInfo cpu_type_info = {
492     .name = TYPE_CPU,
493     .parent = TYPE_DEVICE,
494     .instance_size = sizeof(CPUState),
495     .instance_init = cpu_common_initfn,
496     .instance_finalize = cpu_common_finalize,
497     .abstract = true,
498     .class_size = sizeof(CPUClass),
499     .class_init = cpu_class_init,
500 };
```
> target/i386/cpu.c
``` c
4626 static void x86_cpu_common_class_init(ObjectClass *oc, void *data)
4627 {
4628     X86CPUClass *xcc = X86_CPU_CLASS(oc);
4629     CPUClass *cc = CPU_CLASS(oc);
4630     DeviceClass *dc = DEVICE_CLASS(oc);
...
4634     dc->realize = x86_cpu_realizefn;
...
4688 }
...
4690 static const TypeInfo x86_cpu_type_info = {
4691     .name = TYPE_X86_CPU,
4692     .parent = TYPE_CPU,
4693     .instance_size = sizeof(X86CPU),
4694     .instance_init = x86_cpu_initfn,
4695     .abstract = true,
4696     .class_size = sizeof(X86CPUClass),
4697     .class_init = x86_cpu_common_class_init,
4698 };
```


<a name="vcpu-realize"></a>
## 仮想CPUのrealize
* realizeの実態はx86_cpu_realizefn
> target/i386/cpu.c
```
4054 static void x86_cpu_realizefn(DeviceState *dev, Error **errp)
4055 {
4056     CPUState *cs = CPU(dev);
4057     X86CPU *cpu = X86_CPU(dev);
4058     X86CPUClass *xcc = X86_CPU_GET_CLASS(dev);
4059     CPUX86State *env = &cpu->env;
4060     Error *local_err = NULL;
4061     static bool ht_warned;
...
4217     qemu_init_vcpu(cs);
...
4233     x86_cpu_apic_realize(cpu, &local_err);
...
4237     cpu_reset(cs);
4238
4239     xcc->parent_realize(dev, &local_err);
...
4246 }
```

* VCPUスレッドを開始します
> cpus.c
```
1739 static void qemu_kvm_start_vcpu(CPUState *cpu)
1740 {
1741     char thread_name[VCPU_THREAD_NAME_SIZE];
1742
1743     cpu->thread = g_malloc0(sizeof(QemuThread));
1744     cpu->halt_cond = g_malloc0(sizeof(QemuCond));
1745     qemu_cond_init(cpu->halt_cond);
1746     snprintf(thread_name, VCPU_THREAD_NAME_SIZE, "CPU %d/KVM",
1747              cpu->cpu_index);
1748     qemu_thread_create(cpu->thread, thread_name, qemu_kvm_cpu_thread_fn,
1749                        cpu, QEMU_THREAD_JOINABLE);
1750     while (!cpu->created) {
1751         qemu_cond_wait(&qemu_cpu_cond, &qemu_global_mutex);
1752     }
1753 }

1771 void qemu_init_vcpu(CPUState *cpu)
1772 {
1773     cpu->nr_cores = smp_cores;
1774     cpu->nr_threads = smp_threads;
1775     cpu->stopped = true;
1776
1777     if (!cpu->as) {
1778         /* If the target cpu hasn't set up any address spaces itself,
1779          * give it the default one.
1780          */
1781         AddressSpace *as = g_new0(AddressSpace, 1);
1782
1783         address_space_init(as, cpu->memory, "cpu-memory");
1784         cpu->num_ases = 1;
1785         cpu_address_space_init(cpu, as, 0);
1786     }
1787
1788     if (kvm_enabled()) {
1789         qemu_kvm_start_vcpu(cpu);
1790     } else if (hax_enabled()) {
...
1796     }
1797 }
```

* 他のデバイスの初期化が未完了のため、VCPUスレッドはCPUStateが起動になるまで待機します
> cpus.c
``` c
 952 static bool cpu_can_run(CPUState *cpu)
 953 {
 954     if (cpu->stop) {
 955         return false;
 956     }
 957     if (cpu_is_stopped(cpu)) {
 958         return false;
 959     }
 960     return true;
 961 }

1101 static void *qemu_kvm_cpu_thread_fn(void *arg)
1102 {
1103     CPUState *cpu = arg;
1104     int r;
1105
1106     rcu_register_thread();
1107
1108     qemu_mutex_lock_iothread();
1109     qemu_thread_get_self(cpu->thread);
1110     cpu->thread_id = qemu_get_thread_id();
1111     cpu->can_do_io = 1;
1112     current_cpu = cpu;
1113
1114     r = kvm_init_vcpu(cpu);
1115     if (r < 0) {
1116         fprintf(stderr, "kvm_init_vcpu failed: %s\n", strerror(-r));
1117         exit(1);
1118     }
1119
1120     kvm_init_cpu_signals(cpu);
1120     kvm_init_cpu_signals(cpu);
1121
1122     /* signal CPU creation */
1123     cpu->created = true;
1124     qemu_cond_signal(&qemu_cpu_cond);
1125
1126     do {
1127         if (cpu_can_run(cpu)) {
1128             r = kvm_cpu_exec(cpu);
1129             if (r == EXCP_DEBUG) {
1130                 cpu_handle_guest_debug(cpu);
1131             }
1132         }
1133         qemu_kvm_wait_io_event(cpu);
1134     } while (!cpu->unplug || cpu_can_run(cpu));
1135
1136     qemu_kvm_destroy_vcpu(cpu);
1137     cpu->created = false;
1138     qemu_cond_signal(&qemu_cpu_cond);
1139     qemu_mutex_unlock_iothread();
1140     return NULL;
1141 }
```

* kvm_cpu_execで、kvmによるマシンコードの実行が行われる
* VM_EXITのreasonにより、適切なエミュレーションを行う
> accel/kvm/kvm-all.c
```
1848 int kvm_cpu_exec(CPUState *cpu)
1849 {
1850     struct kvm_run *run = cpu->kvm_run;
1851     int ret, run_ret;
...
1860     qemu_mutex_unlock_iothread();
1861     cpu_exec_start(cpu);
1862
1863     do {
1864         MemTxAttrs attrs;
1865
1866         if (cpu->vcpu_dirty) {
1867             kvm_arch_put_registers(cpu, KVM_PUT_RUNTIME_STATE);
1868             cpu->vcpu_dirty = false;
1869         }
1870
1871         kvm_arch_pre_run(cpu, run);
1872         if (atomic_read(&cpu->exit_request)) {
1873             DPRINTF("interrupt exit requested\n");
1874             /*
1875              * KVM requires us to reenter the kernel after IO exits to complete
1876              * instruction emulation. This self-signal will ensure that we
1877              * leave ASAP again.
1878              */
1879             kvm_cpu_kick_self();
1880         }
1881
1882         /* Read cpu->exit_request before KVM_RUN reads run->immediate_exit.
1883          * Matching barrier in kvm_eat_signals.
1884          */
1885         smp_rmb();
1886
1887         run_ret = kvm_vcpu_ioctl(cpu, KVM_RUN, 0);
1888
1889         attrs = kvm_arch_post_run(cpu, run);
...
1923         switch (run->exit_reason) {
1924         case KVM_EXIT_IO:
1925             DPRINTF("handle_io\n");
1926             /* Called outside BQL */
1927             kvm_handle_io(run->io.port, attrs,
1928                           (uint8_t *)run + run->io.data_offset,
1929                           run->io.direction,
1930                           run->io.size,
1931                           run->io.count);
1932             ret = 0;
1933             break;
1934         case KVM_EXIT_MMIO:
1935             DPRINTF("handle_mmio\n");
1936             /* Called outside BQL */
1937             address_space_rw(&address_space_memory,
1938                              run->mmio.phys_addr, attrs,
1939                              run->mmio.data,
1940                              run->mmio.len,
1941                              run->mmio.is_write);
1942             ret = 0;
1943             break;
...
1984         default:
1985             DPRINTF("kvm_arch_handle_exit\n");
1986             ret = kvm_arch_handle_exit(cpu, run);
1987             break;
1988         }
1989     } while (ret == 0);
1990
1991     cpu_exec_end(cpu);
1992     qemu_mutex_lock_iothread();
1993
1994     if (ret < 0) {
1995         cpu_dump_state(cpu, stderr, fprintf, CPU_DUMP_CODE);
1996         vm_stop(RUN_STATE_INTERNAL_ERROR);
1997     }
1998
1999     atomic_set(&cpu->exit_request, 0);
2000     return ret;
2001 }
```

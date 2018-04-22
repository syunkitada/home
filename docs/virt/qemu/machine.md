# Machine


## MachineClassの取得とインスタンス化
* main内で引数をパースして、対象のMachineClassを取得し、インスタンス化する
> vl.c
```
3091 int main(int argc, char **argv, char **envp)
3092 {
...
4220     machine_class = select_machine();
...
4259     current_machine = MACHINE(object_new(object_class_get_name(
4260                           OBJECT_CLASS(machine_class))));
```

* select_machineで、引数をパースしてMachineClassを取得する
> vl.c
```
2735  static MachineClass *machine_parse(const char *name)
2736 {
2737     MachineClass *mc = NULL;
2738     GSList *el, *machines = object_class_get_list(TYPE_MACHINE, false);
2739
2740     if (name) {
2741         mc = find_machine(name);
2742     }
2743     if (mc) {
2744         g_slist_free(machines);
2745         return mc;
2746     }
2747     if (name && !is_help_option(name)) {
2748         error_report("unsupported machine type");
2749         error_printf("Use -machine help to list supported machines\n");
2750     } else {
2751         printf("Supported machines are:\n");
2752         machines = g_slist_sort(machines, machine_class_cmp);
2753         for (el = machines; el; el = el->next) {
2754             MachineClass *mc = el->data;
2755             if (mc->alias) {
2756                 printf("%-20s %s (alias of %s)\n", mc->alias, mc->desc, mc->name);
2757             }
2758             printf("%-20s %s%s\n", mc->name, mc->desc,
2759                    mc->is_default ? " (default)" : "");
2760         }
2761     }
2762
2763     g_slist_free(machines);
2764     exit(!name || !is_help_option(name));
2765 }
...
2843 static MachineClass *select_machine(void)
2844 {
2845     MachineClass *machine_class = find_default_machine();
2846     const char *optarg;
2847     QemuOpts *opts;
2848     Location loc;
2849
2850     loc_push_none(&loc);
2851
2852     opts = qemu_get_machine_opts();
2853     qemu_opts_loc_restore(opts);
2854
2855     optarg = qemu_opt_get(opts, "type");
2856     if (optarg) {
2857         machine_class = machine_parse(optarg);
2858     }
2859
2860     if (!machine_class) {
2861         error_report("No machine specified, and there is no default");
2862         error_printf("Use -machine help to list supported machines\n");
2863         exit(1);
2864     }
2865
2866     loc_pop(&loc);
2867     return machine_class;
2868 }
```


## MachineClassの登録処理
* DEFINE_I440FX_MACHINEで、MachineClassを登録します
* MachinClass->initには、pc_init_##suffixが設定され、この中ではpc_init1を呼び出している
    * このpc_init1が実質的な初期化処理を行っている
> hw/i386/pc_piix.c
``` c
 413 #define DEFINE_I440FX_MACHINE(suffix, name, compatfn, optionfn) \
 414     static void pc_init_##suffix(MachineState *machine) \
 415     { \
 416         void (*compat)(MachineState *m) = (compatfn); \
 417         if (compat) { \
 418             compat(machine); \
 419         } \
 420         pc_init1(machine, TYPE_I440FX_PCI_HOST_BRIDGE, \
 421                  TYPE_I440FX_PCI_DEVICE); \
 422     } \
 423     DEFINE_PC_MACHINE(suffix, name, pc_init_##suffix, optionfn)
 424
 425 static void pc_i440fx_machine_options(MachineClass *m)
 426 {
 427     m->family = "pc_piix";
 428     m->desc = "Standard PC (i440FX + PIIX, 1996)";
 429     m->default_machine_opts = "firmware=bios-256k.bin";
 430     m->default_display = "std";
 431 }
 432
 433 static void pc_i440fx_2_11_machine_options(MachineClass *m)
 434 {
 435     pc_i440fx_machine_options(m);
 436     m->alias = "pc";
 437     m->is_default = 1;
 438 }
 439
 440 DEFINE_I440FX_MACHINE(v2_11, "pc-i440fx-2.11", NULL,
 441                       pc_i440fx_2_11_machine_options);
```

> include/hw/i386/pc.h
``` c
 987 #define DEFINE_PC_MACHINE(suffix, namestr, initfn, optsfn) \
 988     static void pc_machine_##suffix##_class_init(ObjectClass *oc, void *data) \
 989     { \
 990         MachineClass *mc = MACHINE_CLASS(oc); \
 991         optsfn(mc); \
 992         mc->init = initfn; \
 993     } \
 994     static const TypeInfo pc_machine_type_##suffix = { \
 995         .name       = namestr TYPE_MACHINE_SUFFIX, \
 996         .parent     = TYPE_PC_MACHINE, \
 997         .class_init = pc_machine_##suffix##_class_init, \
 998     }; \
 999     static void pc_machine_init_##suffix(void) \
1000     { \
1001         type_register(&pc_machine_type_##suffix); \
1002     } \
1003     type_init(pc_machine_init_##suffix)
```


## pc_init1
* Machineの初期化処理
* CPUやハードウェアの初期化もこの中でおこなう
> hw/i386/pc_piix.c
``` c
 66 /* PC hardware initialisation */
 67 static void pc_init1(MachineState *machine,
 68                      const char *host_type, const char *pci_type)
 69 {
 70     PCMachineState *pcms = PC_MACHINE(machine);
 71     PCMachineClass *pcmc = PC_MACHINE_GET_CLASS(pcms);
 72     MemoryRegion *system_memory = get_system_memory();
 73     MemoryRegion *system_io = get_system_io();
 74     int i;
 75     PCIBus *pci_bus;
 76     ISABus *isa_bus;
 77     PCII440FXState *i440fx_state;
 78     int piix3_devfn = -1;
 79     qemu_irq *i8259;
 80     qemu_irq smi_irq;
 81     GSIState *gsi_state;
 82     DriveInfo *hd[MAX_IDE_BUS * MAX_IDE_DEVS];
 83     BusState *idebus[MAX_IDE_BUS];
 84     ISADevice *rtc_state;
 85     MemoryRegion *ram_memory;
 86     MemoryRegion *pci_memory;
 87     MemoryRegion *rom_memory;
 88     ram_addr_t lowmem;
 ...
 151     pc_cpus_init(pcms);
 ...
 157     if (pcmc->pci_enabled) {
 158         pci_memory = g_new(MemoryRegion, 1);
 159         memory_region_init(pci_memory, NULL, "pci", UINT64_MAX);
 160         rom_memory = pci_memory;
 161     } else {
 162         pci_memory = NULL;
 163         rom_memory = system_memory;
 164     }
 ...
 177     /* allocate ram and load rom/bios */
 178     if (!xen_enabled()) {
 179         pc_memory_init(pcms, system_memory,
 180                        rom_memory, &ram_memory);
 181     } else if (machine->kernel_filename != NULL) {
 ...
 184     }
 ...
 238     /* init basic PC hardware */
 239     pc_basic_device_init(isa_bus, pcms->gsi, &rtc_state, true,
 240                          (pcms->vmport != ON_OFF_AUTO_ON), pcms->pit, 0x4);
 241
 242     pc_nic_init(isa_bus, pci_bus);
 ...
 305 }
```

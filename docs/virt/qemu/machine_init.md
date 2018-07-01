# Machineの初期化


## Contents
| Link | Description |
| --- | --- |
| [Machineの初期化処理の起点](#starting-point-machine-init) | main関数ないで呼び出される |
| [Machineの初期化処理](#machine_init)                      | Machineの初期化処理の実態 |


<a name="starting-point-machine-init"></a>
## Machineの初期化処理の起点
* main関数内で、各種オプションのパース、MachineClassのインスタンス化、KVMの初期化などが行われた後に、Machineの初期化を行う
* 処理の実態はMachineClassのinit関数
> vl.c
``` c
3091 int main(int argc, char **argv, char **envp)
3092 {
...
4753     machine_run_board_init(current_machine);  // machineの初期化
...
```

> machine.c
```
754 void machine_run_board_init(MachineState *machine)
755 {
756     MachineClass *machine_class = MACHINE_GET_CLASS(machine);
793     machine_class->init(machine);
794 }
```


<a name="machine-init"></a>
## Machineの初期化処理
* MachineClassがnewされてインスタンス化されたときに、mc->initには、pc_init1が登録されている
* pc_init1では、VCPU、メモリ、デバイス、NICなどの初期化(インスタンス化やrealize)を行う
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
 151     pc_cpus_init(pcms);  // vcpuの初期化処理
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
 180                        rom_memory, &ram_memory);  // メモリの初期化処理
 181     } else if (machine->kernel_filename != NULL) {
 ...
 184     }
 ...
 238     /* init basic PC hardware */
 239     pc_basic_device_init(isa_bus, pcms->gsi, &rtc_state, true,
 240                          (pcms->vmport != ON_OFF_AUTO_ON), pcms->pit, 0x4);  // 基本的なPIO用の初期化処理
 241
 242     pc_nic_init(isa_bus, pci_bus);  // e1000とか用
 ...
 305 }
```

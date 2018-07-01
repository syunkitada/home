# QEMU ChangeLog
* https://wiki.qemu.org/ChangeLog
* x86 KVM、Device emulation and assignmentについての変更をメモする


## 2.12
* https://wiki.qemu.org/ChangeLog/2.12


## 2.11
* https://wiki.qemu.org/ChangeLog/2.11
* x86
    * KVM
        * KVM can advertise Hyper-V frequency MSRs when the TSC frequency is stable and known (either through the tsc_khz option, or by enabling the "invtsc" CPUID feature)
        * Support for over 64 VCPUs in Window guests that have Hyper-V enlightenments enabled
* Device emulation and assignment
    * Support for vmcoreinfo device to store dump details.
    * Block devices
        * IDE and SCSI devices can report the disk rotation rate
    * Input devices
        * virtio-input is now able to REL_WHEEL events.
        * The ps2 device now sends correct scancode sequences for Alt+Print, Shift/Ctrl+Print, Pause and Ctrl+Pause in all code sets
* Monitor
    * "info numa" provides information on hotplugged memory
    * New commands "query-memory-size-summary" (QMP) and "info memory_size_summary" (HMP).
    * New command "watchdog-set-action" (QMP).
    * New option -d to "info mtree" (HMP) to debug the memory API's dispatch tree.

## 2.10
* x86
    * The Q35 MCH supports TSEG higher than 8MB (the largest size available on real hardware)
    * gdbstub now provides access to SSE registers
    * Apple SMC emulation implements the error status port
    * IOMMU?
* Device emulation and assignment
    * ACPI
        * New "-numa cpu" option quickly lets you assign CPUs to nodes by socket/core/thread id (for example a 2-socket x86 machine would be "-numa cpu,node-id=0,socket-id=0 "-numa cpu,node-id=1,socket-id=1" independent of the number of sockets per core.
        * Support for ACPI distance info.
    * virtio
        * vhost-user supports IOTLB messages.


## 2.9
* x86
    * TCG supports 5-level paging.
    * The q35 machine type offers SMI feature negotiation to interested guest firmware.
    * Intel IOMMU emulation can now report the caching mode capability to the guest through the "caching-mode=on" property. This is disabled by default.
    * FIXME: query-cpu-model-expansion?
* Device emulation and assignment
    * Block devices
        * I/O threads (supported by virtio-blk and experimentally by virtio-scsi) will poll for I/O submission and completion for a limited time after they have been woken up. This improves performance on some I/O-heavy testcases but 10-20%. Polling settings are also included in query-iothreads output.


## 2.8
* x86
    * Support for several new CPUID features related to AVX-512 instruction set extensions.
    * The emulated IOAPIC (used by TCG and, with KVM, if the "-machine kernel_irqchip" option has the value "off" or "split") now defaults to version 0x20, which supports directed end-of-interrupt messages.
    * Support for Extended Interrupt Mode (EIM) in the intel_iommu device. EIM requires KVM (Linux v4.7 or newer, for x2APIC support) and "-machine kernel-irqchip=split"; it is enabled automatically if interrupt remapping is enabled ("-machine kernel-irqchip=split -device intel_iommu,intremap=on").
    * Support for up to 288 CPUs with the Q35 machine types. 256 or more CPUs are only supported if IOMMU and EIM are enabled.
* Device emulation and assignment
    * virtio
        * New device vhost-vsock.
        * Initial support for graceful handling of guest errors (i.e. QEMU should not exit on guest errors).
        * Support for new virtio-crypto device.

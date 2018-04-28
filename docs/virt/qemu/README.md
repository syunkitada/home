# QEMU


## Basic Contents
| Link | Description |
| --- | --- |
| [main](main.md)                                      | main関数 |
| [QOM](qom.md)                                        | QOM(QEMU Object Model): QEMU独自のオブジェクト指向を実現するための機構 |
| [Memory](memory.md)                                  | MemoryAPIについて |
| [Machineのインスタンス化](machine.md)                | MachineClassと、そのインスタンス化について |
| [AddressSpaceの初期化](memory_address_space_init.md) | AddressSpaceの初期化について |
| [KVMの初期化](kvm_init.md)                           | KVMの初期化について(kvm fdやkvm-vm fdの取得など) |
| [Machineの初期化](machine_init.md)                   | Machine(インスタンス)の初期化について(VCPU、メモリ、ハードウェアの初期化もここで行われる) |
| [VPUのrealize](vcpu_realize.md)                      | VCPUの初期化(インスタンス化とrealize)について |
| [VirtIO](virtio.md)                                  | virtioについて |
| [VirtIO-BLK](virtio_blk.md)                          | virtio-blkのrealize、ハンドラ内でのIO処理について、IO処理の実態は各種BlockDriverによって行われる |
| [BlockDriver:QCOW2](block_driver_qcow2.md)           | BlockDriver(QCOW2)について |
| [Migration](migration.md)                            | Migrationについて |
| [memo](memo.md)                                      | 雑多メモ |

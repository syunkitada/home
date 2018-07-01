# QEMU


## Basic Contents
| Link | Description |
| --- | --- |
| [基礎知識](base.md)                                  | 仮想マシンについての基礎知識をまとめる |
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


## Other Contents
| Link | Description |
| --- | --- |
| [qemu changelog](qemu_changelog.md)                 | qemu changelogのメモ書き |
| [qemu cmd](qemu_cmd.md)                             | qemu cmdのメモ書き |
| [virt-install](virt_install.md)                     | virt-installでVMを立ち上げる手順   |
| [memo](memo.md)                                     | 雑多メモ |


## References
* 仮想マシンについて
    * [ハイパーバイザの作り方](http://syuu1228.github.io/howto_implement_hypervisor/)
* qemuについて
    * [QEMUのなかみ(QEMU internals) part1](http://rkx1209.hatenablog.com/entry/2015/11/15/214404)
    * [QEMUのなかみ(QEMU internals) part2](http://rkx1209.hatenablog.com/entry/2015/11/20/203511)
    * [KVMのなかみ(KVM internals)](http://rkx1209.hatenablog.com/entry/2016/01/01/101456)
    * [Effective multi-threading in QEMU](http://www.linux-kvm.org/images/1/17/Kvm-forum-2013-Effective-multithreading-in-QEMU.pdf)
* kvmについて
    * [Using the KVM API](https://lwn.net/Articles/658511/)
    * [Linux KVMのコードを追いかけてみよう] (http://www.slideshare.net/ozax86/linux-kvm?qid=fb99f565-8ae4-44d3-9b58-8d8487197566&v=&b=&from_search=26)
    * [KVMの中身](http://rkx1209.hatenablog.com/entry/2016/01/01/101456)
* qcow2について
    * [Improving disk I/O performance in QEMU 2.5 with the qcow2 L2 cache](https://blogs.igalia.com/berto/2015/12/17/improving-disk-io-performance-in-qemu-2-5-with-the-qcow2-l2-cache/)
    * [qcow2 - why (not)?](www.linux-kvm.org/images/9/92/Qcow2-why-not.pdf)

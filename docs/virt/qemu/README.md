# QEMU

## Basic Contents

| Link                                                  | Description                                                                                             |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| [基礎知識](base.md)                                   | 仮想マシンについての基礎知識をまとめる                                                                  |
| [main](main.md)                                       | main 関数                                                                                               |
| [QOM](qom.md)                                         | QOM(QEMU Object Model): QEMU 独自のオブジェクト指向を実現するための機構                                 |
| [Memory](memory.md)                                   | MemoryAPI について                                                                                      |
| [Machine のインスタンス化](machine.md)                | MachineClass と、そのインスタンス化について                                                             |
| [AddressSpace の初期化](memory_address_space_init.md) | AddressSpace の初期化について                                                                           |
| [KVM の初期化](kvm_init.md)                           | KVM の初期化について(kvm fd や kvm-vm fd の取得など)                                                    |
| [Machine の初期化](machine_init.md)                   | Machine(インスタンス)の初期化について(VCPU、メモリ、ハードウェアの初期化もここで行われる)               |
| [VPU の realize](vcpu_realize.md)                     | VCPU の初期化(インスタンス化と realize)について                                                         |
| [VirtIO](virtio.md)                                   | virtio について                                                                                         |
| [VirtIO-BLK](virtio_blk.md)                           | virtio-blk の realize、ハンドラ内での IO 処理について、IO 処理の実態は各種 BlockDriver によって行われる |
| [BlockDriver:QCOW2](block_driver_qcow2.md)            | BlockDriver(QCOW2)について                                                                              |
| [Migration](migration.md)                             | Migration について                                                                                      |
| [RemoteDesktop](remote_desktop.md)                    | Remote Desktop について                                                                                 |

## Other Contents

| Link                                | Description                         |
| ----------------------------------- | ----------------------------------- |
| [qemu changelog](qemu_changelog.md) | qemu changelog のメモ書き           |
| [qemu cmd](qemu_cmd.md)             | qemu cmd のメモ書き                 |
| [virt-install](virt_install.md)     | virt-install で VM を立ち上げる手順 |
| [memo](memo.md)                     | 雑多メモ                            |

## References

- 仮想マシンについて
  - [ハイパーバイザの作り方](http://syuu1228.github.io/howto_implement_hypervisor/)
- qemu について
  - [QEMU のなかみ(QEMU internals) part1](http://rkx1209.hatenablog.com/entry/2015/11/15/214404)
  - [QEMU のなかみ(QEMU internals) part2](http://rkx1209.hatenablog.com/entry/2015/11/20/203511)
  - [KVM のなかみ(KVM internals)](http://rkx1209.hatenablog.com/entry/2016/01/01/101456)
  - [Effective multi-threading in QEMU](http://www.linux-kvm.org/images/1/17/Kvm-forum-2013-Effective-multithreading-in-QEMU.pdf)
- kvm について
  - [Using the KVM API](https://lwn.net/Articles/658511/)
  - [Linux KVM のコードを追いかけてみよう](http://www.slideshare.net/ozax86/linux-kvm?qid=fb99f565-8ae4-44d3-9b58-8d8487197566&v=&b=&from_search=26)
  - [KVM の中身](http://rkx1209.hatenablog.com/entry/2016/01/01/101456)
- qcow2 について
  - [Improving disk I/O performance in QEMU 2.5 with the qcow2 L2 cache](https://blogs.igalia.com/berto/2015/12/17/improving-disk-io-performance-in-qemu-2-5-with-the-qcow2-l2-cache/)
  - [qcow2 - why (not)?](www.linux-kvm.org/images/9/92/Qcow2-why-not.pdf)

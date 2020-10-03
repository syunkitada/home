# Linux

## Basic Contents

| Link                                           | Description                                              |
| ---------------------------------------------- | -------------------------------------------------------- |
| [OS History](os_history)                       | OS の歴史について                                        |
| [カーネルと起動時の処理](kernel_boot.md)       | カーネルの場所、起動時の流れ                             |
| [プロセスとスケジューラ](process_scheduler.md) | プロセス実行の仕組み、スケジューリングの仕組み、割り込み |
| [ファイルシステム](filesystem.md)              | ファイル、ファイルシステム、ブロックデバイス             |
| [デバイス](device.md)                          | デバイス                                                 |
| [メモリ](memory.md)                            | メモリ管理                                               |

## Kernel

| Link                                         | Description              |
| -------------------------------------------- | ------------------------ |
| [カーネル](kernel.md)                        | カーネルメモ             |
| [カーネルデバイスドライバ](kernel_driver.md) | カーネルデバイスドライバ |
| [カーネルパニック](kernel_panic.md)          | カーネルパニック         |
| [デバッグ](debugging.md)                     |                          |
| [テスト](testing.md)                         |                          |

## CPU

| Link                                 | Description      |
| ------------------------------------ | ---------------- |
| [CPU](cpu.md)                        | CPU              |
| [CPU(ハードウェア)](cpu_hardware.md) | CPU の仕組みとか |

## Memory

| [メモリ](memory.md) | メモリの仕組みとか |
| [メモリ(ハードウェア)](memory_hardware.md) | メモリの仕組みとか |
| [メモリ(チューニング)](memory_hardware.md) | メモリのチューニングについて |

## Network

| Link                                  | Description                               |
| ------------------------------------- | ----------------------------------------- |
| [Network Hostory](network_history.md) | ネットワークの歴史について                |
| [Network Basic](network_basic.md)     | ネットワークの基礎知識、OSI とか TCP とか |
| [Network](network.md)                 | ネットワークについて                      |
| [iptables](iptables.md)               | iptables メモ                             |
| [xdp](xdp.md)                         | xdp メモ                                  |

## IO Device

| Link                               | Description                                  |
| ---------------------------------- | -------------------------------------------- |
| [ファイルシステム](filesystem.md)  | ファイル、ファイルシステム、ブロックデバイス |
| [ブロックデバイス](blockdevice.md) | ブロックデバイス                             |
| [デバイス](device.md)              | デバイス                                     |

## その他

| Link                  | Description     |
| --------------------- | --------------- |
| [systemd](systemd.md) | systemd         |
| [strace](strace.md)   | strace いろいろ |

## References

- kernel 全般
  - [Linux Kernel Teaching](https://linux-kernel-labs.github.io/refs/heads/master/index.html)
  - [The Linux Kernel documentation v4.15](https://www.kernel.org/doc/html/v4.15/index.html)
  - [kernel_map](http://www.makelinux.net/kernel_map/)
  - [Linux perf tools](http://www.brendangregg.com/Perf/linuxperftools.png)
  - [Understanding the Linux Virtual Memory Manager](https://www.kernel.org/doc/gorman/html/understand/)
  - [openSUSE: System Analysis and Tuning Guide](https://doc.opensuse.org/documentation/leap/archive/42.3/tuning/html/book.sle.tuning/book.sle.tuning.html)
- Linux Advent Calendar
  - [2013](https://qiita.com/advent-calendar/2013/linux)
  - [2014](https://qiita.com/advent-calendar/2014/linux)
  - [2015](https://qiita.com/advent-calendar/2015/linux)
  - [2016](https://qiita.com/advent-calendar/2016/linux)
  - [2017](https://qiita.com/advent-calendar/2017/linux)
  - [2018](https://qiita.com/advent-calendar/2018/linux)
  - [2019](https://qiita.com/advent-calendar/2019/linux)
- NetworkStack
  - [Network data flow](https://mwiki.static.linuxfound.org/images/1/1c/Network_data_flow_through_kernel.png)
  - [Netfilter packet flow](https://upload.wikimedia.org/wikipedia/commons/3/37/Netfilter-packet-flow.svg)
- StorageStack
  - [Linux Storage Stack Diagram](https://www.thomas-krenn.com/en/wiki/Linux_Storage_Stack_Diagram)
  - [Linux Multi-Queue Block IO Queueing Mechanism (blk-mq)](<https://www.thomas-krenn.com/en/wiki/Linux_Multi-Queue_Block_IO_Queueing_Mechanism_(blk-mq)>)
- Tuning
  - [openSUSE: Part V Kernel Tuning](https://doc.opensuse.org/documentation/leap/archive/42.3/tuning/html/book.sle.tuning/part.tuning.kernel.html)
- CaseStudy
  - Memory
    - [Linkedin: Optimizing Linux Memory Management for Low-latency / High-throughput Databases](https://engineering.linkedin.com/performance/optimizing-linux-memory-management-low-latency-high-throughput-databases)

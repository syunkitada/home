# Linux


## Basic Contents
| Link | Description |
| --- | --- |
| [カーネルと起動時の処理](kernel_boot.md)       | カーネルの場所、起動時の流れ |
| [プロセスとスケジューラ](process_scheduler.md) | プロセス実行の仕組み、スケジューリングの仕組み、割り込み |
| [ファイルシステム](filesystem.md)              | ファイル、ファイルシステム、ブロックデバイス |
| [デバイス](device.md)                          | デバイス |
| [メモリ](memory.md)                            | メモリ管理 |


## Kernel
| Link | Description |
| --- | --- |
| [カーネル](kernel.md)                         | カーネルメモ |
| [カーネルデバイスドライバ](kernel_driver.md)  | カーネルデバイスドライバ               |
| [カーネルパニック](kernel_panic.md)           | カーネルパニック               |


## CPU
| Link | Description |
| --- | --- |
| [CPU](cpu.md)                              | CPU               |
| [CPU(ハードウェア)](cpu_hardware.md)       | CPUの仕組みとか   |


## Memory
| [メモリ](memory.md) | メモリの仕組みとか |
| [メモリ(ハードウェア)](memory_hardware.md) | メモリの仕組みとか |
| [メモリ(チューニング)](memory_hardware.md) | メモリのチューニングについて |


## Network
| Link | Description |
| --- | --- |
| [Network](network.md)                    | ネットワークについて      |
| [Network用語](network_terminology.md)    | ネットワーク用語メモ      |
| [Networkツール](network_tool.md)         | ネットワークツールメモ    |
| [iptables](iptables.md)                  | iptablesメモ    |


## IO Device
| Link | Description |
| --- | --- |
| [ファイルシステム](filesystem.md)              | ファイル、ファイルシステム、ブロックデバイス |
| [デバイス](device.md)                          | デバイス |


## モニタリング
| Link | Description |
| --- | --- |
| [Performance](performance.md)                                            | パフォーマンス          |
| [Observability tools basic](observability_tools_basic.md)                | 基本的な観測ツール      |
| [Observability tools intermediate](observability_tools_intermediate.md)  | 特殊な観測ツール        |
| [Latency](latency.md)                                                    | Latencyいろいろ         |


## その他
| Link | Description |
| --- | --- |
| [initscript](initscript.md)                                             | initscript          |
| [strace](strace.md)                                                     | straceいろいろ      |


## References
* kernel全般
    * [kernel_map](http://www.makelinux.net/kernel_map/)
    * [Linux perf tools](http://www.brendangregg.com/Perf/linuxperftools.png)
* NetworkStack
    * [Network data flow](https://mwiki.static.linuxfound.org/images/1/1c/Network_data_flow_through_kernel.png)
    * [Netfilter packet flow](https://upload.wikimedia.org/wikipedia/commons/3/37/Netfilter-packet-flow.svg)
* StorageStack
    * [Linux Storage Stack Diagram](https://www.thomas-krenn.com/en/wiki/Linux_Storage_Stack_Diagram)
    * [Linux Multi-Queue Block IO Queueing Mechanism (blk-mq)](https://www.thomas-krenn.com/en/wiki/Linux_Multi-Queue_Block_IO_Queueing_Mechanism_(blk-mq))

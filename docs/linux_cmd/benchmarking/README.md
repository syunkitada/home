# Linux Benchmarking

## Benchmarking Tools

| Link                                                         | Target                                                                   | Description                                               |
| ------------------------------------------------------------ | ------------------------------------------------------------------------ | --------------------------------------------------------- |
| [wrk](wrk.md): [GitHub](https://github.com/wg/wrk)           | Web server                                                               | マルチコアで利用でき、高い RPS をはじき出せるのでオススメ |
| [ApacheBench](apachebench.md)                                | Web server                                                               | CPU を使い切れず、正しい RPS を測定できないので微妙       |
| [Siege](siege.md): [GitHub](https://github.com/JoeDog/siege) | Web server                                                               | CPU を使い切れず、正しい RPS を測定できないので微妙       |
| [sysbench](sysbench.md)                                      | CPU, Scheduler, File Systems                                             |                                                           |
| [unixbench](unixbench.md)                                    | CPU, Scheduler                                                           |                                                           |
| [lmbench](lmbench.md)                                        | CPU, Scheduler, DRAM, MemoryBus, System Call Interface, Sockets, TCP/UDP |
| [iperf3](iperf3.md)                                          | Netowrk                                                                  | スループットや TCP の再送が起こってるかなどを測定できる   |
| [mtr](mtr.md)                                                | Network                                                                  |                                                           |
| [fio](fio.md)                                                | File Systems                                                             | iops の測定                                               |
| [dd]()                                                       |                                                                          |                                                           |
| [hdparam]()                                                  |                                                                          |                                                           |

## Tuning

| Link                                | Desctiption               |
| ----------------------------------- | ------------------------- |
| [Tuning について](tuning/README.md) | Tuning についてのうんちく |
| [IO](tuning/io.md)                  | IO                        |

## References

- [クラウドでのネットワーク レイテンシの測定](https://cloudblog.withgoogle.com/ja/products/networking/using-netperf-and-ping-to-measure-network-latency/amp/)

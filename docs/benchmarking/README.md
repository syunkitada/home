# Benchmarking

## Benchmarking Tools
| Link                                                         | Target | Description |
| --- | --- | --- |
| [wrk](wrk.md): [GitHub](https://github.com/wg/wrk)           | Web server | マルチコアで利用でき、高いRPSをはじき出せるのでオススメ |
| [ApacheBench](apachebench.md)                                | Web server | CPUを使い切れず、正しいRPSを測定できないので微妙 |
| [Siege](siege.md): [GitHub](https://github.com/JoeDog/siege) | Web server | CPUを使い切れず、正しいRPSを測定できないので微妙 |
| [sysbench](sysbench.md)                                      | CPU, Scheduler, File Systems | |
| [unixbench](unixbench.md)                                    | CPU, Scheduler | |
| [lmbench](lmbench.md)                                        | CPU, Scheduler, DRAM, MemoryBus, System Call Interface, Sockets, TCP/UDP |
| [iperf3](iperf3.md)                                          | Netowrk | スループットやTCPの再送が起こってるかなどを測定できる |
| [mtr](mtr.md)                                                | Network | |
| [fio](fio.md)                                                | File Systems | iopsの測定 |
| [dd]()                                                       | | |
| [hdparam]()                                                  | | |



## 
BMCで消費電力取りながら、ベンチマークを取る
CPUをぶん回すと、消費電力は数倍と大きく変わってくる

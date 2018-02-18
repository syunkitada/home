# Latency

## Operation Costs in CPU Clock Cycles
* 参考: [Infographics: Operation Costs in CPU Clock Cycles - IT Hare on Soft.ware](http://ithare.com/infographics-operation-costs-in-cpu-clock-cycles/)

| Operation | Cycles | Memo |
| --- | --- | --- |
| "Simple" register-register op (ADD,OR,etc)                        | <1             |  |
| Memory write                                                      | -1             | メモリの書き込みは完了する前に次の命令へすすめるので1クロックで済む |
| Bypass delay: switch between integer and floating-point units     | 0-3            |  |
| "Right" branch of "if"                                            | 1-2            |  |
| Floating-point/vector addition                                    | 1-3            |  |
| Multiplication (integer/float/vector)                             | 1-7            |  |
| L1 read                                                           | 4              |  |
| L2 read                                                           | 10-12          |  |
| "Wrong" branch of "if" (branch misprediction)                     | 10-20          | 分岐予測失敗のペナルティは意外と少ない |
| Integer division                                                  | 15-40          | 整数の割り算は遅い |
| 128-bit vector division                                           | 10-70          |  |
| C function direct call                                            | 25-70          |  |
| Floating-point division                                           | 30-40          |  |
| L3 read                                                           | 30-70          |  |
| C function indirect call                                          | 30-100         |  |
| C++ virtual function call                                         | 50-120         |  |
| Main RAM read                                                     | 100-150        | キャッシュに比べやはり遅い、cacheのhitは重要 |
| NUNA: different-socket L3 read                                    | 100-300        |  |
| Allocation + deallocation pair (small objects)                    | 200-500        |  |
| NUMA: different-socket main RAM read                              | 300-500        |  |
| Kernel call                                                       | 1000-1500      | システムコールは、CPUをkernelモードに切り替えての処理になるなので、コストが高い  |
| Thread context switch (direct costs)                              | 2000           | コンテキストスイッチは、CPUのレジスタ切り替えるのでコストが大きい |
| C++ Exception thrown+caught                                       | 5000-10000     | C++に限らず例外のコストは大きい、しかし例外が発生しなければ(tryを書いてる分には)コストはない。また、if文でチェックを大量にするほうがコストが高い場合もある |
| Thread context switch (total costs, including cache invalidation) | 10000-1million |  |


## Latency
* 参考: [Latency Numbers Every Programmer Should Know](https://gist.github.com/jboner/2841832)
| Operation | Latency(ns) | Latency(us) | Latency(ms) | Latency(relative) |
| --- | --- | --- | --- | --- |
| L1 cache reference                 |           0.5 |         |     |                             |
| Branch mispredict                  |           5   |         |     |                             |
| L2 cache reference                 |           7   |         |     | 14x L1 cache                |
| Mutex lock/unlock                  |          25   |         |     |                             |
| Main memory reference              |         100   |         |     | 20x L2 cache, 200x L1 cache |
| Compress 1K bytes with Zippy       |       3,000   |       3 |     |                             |
| Send 1K bytes over 1 Gbps network  |      10,000   |      10 |     |                             |
| Read 4K randomly from SSD*         |     150,000   |     150 |     | ~1GB/sec SSD                |
| Read 1 MB sequentially from memory |     250,000   |     250 |     |                             |
| Round trip within same datacenter  |     500,000   |     500 |     |                             |
| Read 1 MB sequentially from SSD*   |   1,000,000   |   1,000 |   1 | ~1GB/sec SSD, 4X memory     |
| Disk seek                          |  10,000,000   |  10,000 |  10 | 20x datacenter roundtrip    |
| Read 1 MB sequentially from disk   |  20,000,000   |  20,000 |  20 | 80x memory, 20X SSD         |
| Send packet CA->Netherlands->CA    | 150,000,000   | 150,000 | 150 |                             |

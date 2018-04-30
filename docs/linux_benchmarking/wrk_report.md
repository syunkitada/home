# wrk report


## Environments
* pc1
    * OS: Ubuntu: 16.04.2 LTS (Xenial Xerus), Kernel 4.4.0-59-generic
    * CPU: [Intel(R) Pentium(R) CPU G3258:  Haswel, 2 core, 2 thread, 3.20GHz](https://ark.intel.com/products/82723/Intel-Pentium-Processor-G3258-3M-Cache-3_20-GHz)
    * Memory: W3U1600HQ-8G * 2: 8192MB, Type: DDR3, Speed: 1333 MHz, Rank: 2, Minimum Voltage: 1.5 V, Maximum Voltage: 1.5 V, Configured Voltage: 1.5 V)
    * Storage: CSSD-S6T256NHG6Q 256 GB: Sector Size: 512 bytes logical/physical, SATA Version:  SATA 3.1, 6.0 Gb/s (current: 6.0 Gb/s)


## Simple Benchmark
* ローカルホストからwrk 1threadでベンチマーク
* コンテンツは、"Hello World!"を返すだけ

``` sh
$ ./wrk -c 1 -t 1 --latency -d 10 [target]
```

| Target   | RPS   | 50% Latency[us] | 99% Latency[us] |
| --- | --- | --- |
| nginx    | 47356 | 20              | 104             |
| echo(go) | 49700 | 18              | 184             |
| gin(go)  | 27901 | 34              | 173             |

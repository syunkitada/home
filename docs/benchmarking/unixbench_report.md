# unixbench report

## 環境情報
* pc1
    * OS: Ubuntu: 16.04.2 LTS (Xenial Xerus), Kernel 4.4.0-59-generic
    * CPU: [Intel(R) Pentium(R) CPU G3258:  Haswel, 2 core, 2 thread, 3.20GHz](https://ark.intel.com/products/82723/Intel-Pentium-Processor-G3258-3M-Cache-3_20-GHz)
    * Memory: W3U1600HQ-8G * 2: 8192MB, Type: DDR3, Speed: 1333 MHz, Rank: 2, Minimum Voltage: 1.5 V, Maximum Voltage: 1.5 V, Configured Voltage: 1.5 V)
    * Storage: CSSD-S6T256NHG6Q 256 GB: Sector Size: 512 bytes logical/physical, SATA Version:  SATA 3.1, 6.0 Gb/s (current: 6.0 Gb/s)

| pc            | score  | dhry2reg | whetstone-double | execl  | fstime | fsbuffer | fsdisk | pipe   | context1 | spawn  | shell1 | shell8 | syscal |
| pc1 1core     | 2601.0 | 4430.4   | 659.4            | 1728.4 | 3947.3 | 2894.5   | 5576.8 | 2934.6 | 733.9    | 1703.6 | 4084.6 | 5181.9 | 3836.3 |
| pc1 2core     | 4367.9 | 8749.1   | 1321.1           | 3641.3 | 4366.9 | 3055.0   | 7836.3 | 5800.9 | 2910.5   | 3460.4 | 6216.2 | 5524.8 | 5463.0 |
| pc1_vm1 1core | 2262.5 | 4497.4   | 585.0            | 1429.3 | 3693.1 | 2647.3   | 5579.9 | 1910.1 | 1342.2   | 1585.4 | 2455.9 | 3307.9 | 2655.5 |
| pc1_vm1 2core | 3870.9 | 8797.5   | 1175.9           | 3100.5 | 5556.3 | 4052.1   | 8895.8 | 3776.7 | 2624.4   | 3525.0 | 3608.4 | 3340.6 | 4182.8 |

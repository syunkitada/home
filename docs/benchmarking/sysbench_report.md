# sysbench report

```
# cpu events/ser
$ sysbench --threads=N cpu run --cpu-max-prime=100000

# memory seq write
$ sysbench --threads=N memory run --memory-oper=write --memory-access-mode=seq

# memory seq read
$ sysbench --threads=N memory run --memory-oper=read --memory-access-mode=seq

# memory rnd write
$ sysbench --threads=N memory run --memory-oper=write --memory-access-mode=rnd

# memory rnd read
$ sysbench --threads=N memory run --memory-oper=read --memory-access-mode=rnd

# fileio rnd
$ sysbench --threads=N fileio run --file-total-size=3G --file-test-mode=rndrw

# fileio seq
$ sysbench --threads=N fileio run --file-total-size=3G --file-test-mode=rndrw

# oltp
$ sysbench --db-driver=mysql --mysql-user=sysbench --mysql-password=sysbench --mysql-socket=/var/lib/mysql/mysql.sock --mysql-db=sysbench --range_size=100   --table_size=10000 --tables=2 --threads=1 --events=0 --time=60   --rand-type=uniform /usr/share/sysbench/oltp_read_write.lua prepare
$ sysbench --db-driver=mysql --mysql-user=sysbench --mysql-password=sysbench --mysql-socket=/var/lib/mysql/mysql.sock --mysql-db=sysbench --range_size=100   --table_size=10000 --tables=2 --threads=1 --events=0 --time=60   --rand-type=uniform /usr/share/sysbench/oltp_read_write.lua run
$ sysbench --db-driver=mysql --mysql-user=sysbench --mysql-password=sysbench   --mysql-socket=/var/lib/mysql/mysql.sock --mysql-db=sysbench --range_size=100   --table_size=10000 --tables=2 --threads=1 --events=0 --time=60   --rand-type=uniform /usr/share/sysbench/oltp_read_write.lua cleanup
```

| pc            | cpu events/sec | memory seq write | memory seq read | memory rnd write | memory rnd read | rnd reads/s | rnd writes/s | rnd fsyncs/s | rnd read MiB/s | rnd write MiB/s | sql read | sql write | sql other | sql total | sql transaction/sec | sql query/sec |
| ---           | ---            | ---              | ---             | ---              | ---             | ---         | ---          | ---          | ---            | ---             | ---      | ---       | ---       | ---       | ---                 | ---           |
| pc1 1core     | 58.52          | 9379.31          | 8323.74         | 2157.58          | 2177.82         | 1169.83     | 779.89       | 2488.55      | 18.28          | 12.19           | 302372   | 86392     | 43196     | 431960    | 359.96              | 7199.13       |
| pc1 2core     | 115.13         | 6541.71          | 15319.03        | 1293.89          | 4227.58         | 1421.76     | 947.84       | 3030.68      | 22.21          | 14.81           | 301406   | 86116     | 43058     | 430580    | 358.80              | 7176.07       |
| pc1_vm1 1core | 50.10          | 4221.00          | 4955.26         | 1846.64          | 1833.36         | 581.83      | 387.89       | 1236.14      | 9.09           | 6.06            | 316092   | 90312     | 45156     | 451560    | 376.28              | 7525.63       |
| pc1_vm1 2core | 99.57          | 6735.93          | 8626.18         | 1364.52          | 3548.30         | 653.70      | 435.97       | 1384.07      | 10.21          | 6.81            | 317128   | 90608     | 45304     | 453040    | 377.51              | 7550.19       |

* memoryの単位: (MiB/sec)

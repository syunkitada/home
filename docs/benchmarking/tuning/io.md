# IO


## デバイスの確認
* hw_sector_size, logical_block_size, physical_block_sizeが一致することを確認する
* ファイルシステムのBlock sizeがsector_sizeの倍数であることを確認する
```
$ cat /sys/block/sdb/queue/hw_sector_size
512

$ cat /sys/block/sdb/queue/logical_block_size
512

$ cat /sys/block/sdb/queue/physical_block_size
512

$ cat /sys/block/sdb/queue/minimum_io_size
512

$ cat /sys/block/sdb/queue/optimal_io_size
0

$ sudo dumpe2fs /dev/sdb | grep 'Block size'
dumpe2fs 1.42.13 (17-May-2015)
Block size:               4096

$ sudo xf_info /dev/sdb | grep 'bsize'

$ sudo tune2fs -l /dev/vdb | grep 'Block size'
```


## scheduler
* SSDであればnoopがよい(ワークロードによってはdeadlineがよいかも?)

```
# schedulerの確認
$ cat /sys/block/sdb/queue/scheduler
[noop] deadline cfq

# schedulerの書き換え
$ sudo sh -c 'echo noop > /sys/block/sdb/queue/scheduler'

# scheduler benchmark
# Colorful SL500 320GB SATA SSD: http://www.links.co.jp/item/sl500-320g/
# noop                                deadline                             cfq
"jobname" : "seq-read-1m",            "jobname" : "seq-read-1m",             "jobname" : "seq-read-1m",           
"iops" : 242.26,                      "iops" : 241.53,                       "iops" : 243.39,                     
"jobname" : "seq-write-1m",           "jobname" : "seq-write-1m",            "jobname" : "seq-write-1m",          
"iops" : 342.47,                      "iops" : 198.10,                       "iops" : 152.71,                     
"jobname" : "rand-read-512",          "jobname" : "rand-read-512",           "jobname" : "rand-read-512",         
"iops" : 5311.66,                     "iops" : 5303.65,                      "iops" : 5235.26,                    
"jobname" : "rand-write-512",         "jobname" : "rand-write-512",          "jobname" : "rand-write-512",        
"iops" : 4301.80,                     "iops" : 3652.71,                      "iops" : 3647.44,                    
"jobname" : "rand-read-4k",           "jobname" : "rand-read-4k",            "jobname" : "rand-read-4k",          
"iops" : 4912.22,                     "iops" : 4866.39,                      "iops" : 4844.02,                    
"jobname" : "rand-write-4k",          "jobname" : "rand-write-4k",           "jobname" : "rand-write-4k",         
"iops" : 28827.69,                    "iops" : 18969.70,                     "iops" : 18735.44,                   
"jobname" : "rand-read-512k",         "jobname" : "rand-read-512k",          "jobname" : "rand-read-512k",        
"iops" : 417.90,                      "iops" : 423.42,                       "iops" : 407.81,                     
"jobname" : "rand-write-512k",        "jobname" : "rand-write-512k",         "jobname" : "rand-write-512k",       
"iops" : 615.21,                      "iops" : 424.08,                       "iops" : 511.02,                     
"jobname" : "rand-read-4k-qd8",       "jobname" : "rand-read-4k-qd8",        "jobname" : "rand-read-4k-qd8",      
"iops" : 21675.44,                    "iops" : 21633.24,                     "iops" : 21686.74,                   
"jobname" : "rand-write-4k-qd8",      "jobname" : "rand-write-4k-qd8",       "jobname" : "rand-write-4k-qd8",     
"iops" : 47848.72,                    "iops" : 39233.23,                     "iops" : 40285.84,                   
"jobname" : "rand-read-4k-qd32",      "jobname" : "rand-read-4k-qd32",       "jobname" : "rand-read-4k-qd32",     
"iops" : 33928.65,                    "iops" : 34082.21,                     "iops" : 33977.25,                   
"jobname" : "rand-write-4k-qd32",     "jobname" : "rand-write-4k-qd32",      "jobname" : "rand-write-4k-qd32",    
"iops" : 48096.11,                    "iops" : 40375.18,                     "iops" : 32274.46,                   
"jobname" : "rand-read-4k-qd32-j8",   "jobname" : "rand-read-4k-qd32-j8",    "jobname" : "rand-read-4k-qd32-j8",  
"iops" : 34080.27,                    "iops" : 33544.06,                     "iops" : 20992.58,                   
"jobname" : "rand-write-4k-qd32-j8",  "jobname" : "rand-write-4k-qd32-j8",   "jobname" : "rand-write-4k-qd32-j8", 
"iops" : 48009.63,                    "iops" : 32423.39,                     "iops" : 38668.88,                   
"jobname" : "rand-read-4k-qd32-j32",  "jobname" : "rand-read-4k-qd32-j32",   "jobname" : "rand-read-4k-qd32-j32", 
"iops" : 34299.64,                    "iops" : 34120.98,                     "iops" : 22145.21,                   
"jobname" : "rand-write-4k-qd32-j32", "jobname" : "rand-write-4k-qd32-j32",  "jobname" : "rand-write-4k-qd32-j32",
"iops" : 39592.68,                    "iops" : 40807.77,                     "iops" : 31353.79,                   
```

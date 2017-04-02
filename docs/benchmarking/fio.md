# fio

``` bash
$ fio --name=seqwrite --rw=write --bs=128k --size=122374m
seqwrite: (g=0): rw=write, bs=128K-128K/128K-128K/128K-128K, ioengine=sync, iodepth=1
fio-2.2.8
Starting 1 process
seqwrite: Laying out IO file(s) (1 file(s) / 122374MB)
fio: posix_fallocate fails: No space left on device
Jobs: 1 (f=1): [W(1)] [7.4% done] [0KB/298.7MB/0KB /s] [0/2388/0 iops] [eta 07m:08s]
fio: io_u error on file seqwrite.0.0: No space left on device: write offset=41087299584, buflen=102400
fio: pid=7023, err=28/file:io_u.c:1575, func=io_u error, error=No space left on device
Jobs: 1 (f=0): [W(1)] [32.0% done] [0KB/1536KB/0KB /s] [0/12/0 iops] [eta 06m:26s]
seqwrite: (groupid=0, jobs=1): err=28 (file:io_u.c:1575, func=io_u error, error=No space left on device): pid=7023: Sun Apr  2 06:50:48 2017
  write: io=39184MB, bw=221912KB/s, iops=1733, runt=180812msec
    clat (usec): min=22, max=5103.5K, avg=573.92, stdev=10515.57
     lat (usec): min=22, max=5103.5K, avg=575.68, stdev=10515.65
    clat percentiles (usec):
     |  1.00th=[   24],  5.00th=[   24], 10.00th=[   25], 20.00th=[   26],
     | 30.00th=[   27], 40.00th=[   29], 50.00th=[   31], 60.00th=[   34],
     | 70.00th=[   40], 80.00th=[   54], 90.00th=[  117], 95.00th=[  338],
     | 99.00th=[11584], 99.50th=[15552], 99.90th=[25984], 99.95th=[41216],
     | 99.99th=[183296]
    bw (KB  /s): min=  173, max=1545708, per=100.00%, avg=233684.37, stdev=156396.86
    lat (usec) : 50=77.85%, 100=9.91%, 250=6.81%, 500=0.58%, 750=0.07%
    lat (usec) : 1000=0.06%
    lat (msec) : 2=0.06%, 4=0.07%, 10=3.20%, 20=1.19%, 50=0.15%
    lat (msec) : 100=0.02%, 250=0.02%, 500=0.01%, 750=0.01%, 1000=0.01%
    lat (msec) : 2000=0.01%, >=2000=0.01%
  cpu          : usr=0.36%, sys=9.01%, ctx=14490, majf=1, minf=64
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.1%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued    : total=r=0/w=313480/d=0, short=r=0/w=8/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: io=39184MB, aggrb=221911KB/s, minb=221911KB/s, maxb=221911KB/s, mint=180812msec, maxt=180812msec

Disk stats (read/write):
  sda: ios=178/78994, merge=0/176, ticks=2568/25939574, in_queue=25954588, util=99.92%
```




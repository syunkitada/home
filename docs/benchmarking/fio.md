# fio

## Install
``` bash
# Install centos
$ yum install fio

# Install ubuntu
$ sudo apt-get install fio
```

## Run
* パラメータ
    * direct
    * rw
    * ioengine
    * iodepth
    * numjobs
    * bs
    * size


```
$ fio fiofile --section random-write
...

$ cat fiofile
[random-read]
rw=randread
size=1g
directory=/opt/sdb/fio
direct=1
group_reporting=1

[random-write]
rw=randwrite
blocksize=4k
size=1g
ioengine=sync
iodepth=1
numjobs=1
direct=1
directory=/opt/sdb/fio
group_reporting=1

[sequential-read]
rw=read
size=100m
directory=/opt/sdb/fio
direct=1
group_reporting=1

[sequential-write]
rw=write
size=100m
directory=/opt/sdb/fio
direct=1
group_reporting=1
```

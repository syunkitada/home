# fio
* IOのベンチマークツール
* flexible I/O testerの略
* 作者: [Jens Axboe](https://github.com/axboe)
    * Facebookに在籍してるらしい


## Contents
| Link | Description |
| --- | --- |
| [Install](#Install)               | |
| [Hello World](#Hello World)       | |
| [パラメータメモ](#パラメータメモ) | |
| [fio_job.ini](fio_job.ini)        | |
| [結果の見方](#結果の見方)         | |
| [参考](#参考)                     | |



## Install
``` bash
# Install centos
$ yum install epel-release
$ yum install fio

# Install ubuntu
$ sudo apt-get install fio
```


## Hello World
```
$ cat fio_job.ini
[global]
ioengine=libaio
iodepth=1
size=16g
direct=1
runtime=60
directory=/tmp
filename=fio-diskmark
stonewall

[seq-read-1m]
bs=1m
rw=read

# 基本
$ fio fio_job.ini

# 結果をjsonで出力させる
$ fio --output=fio_out.json --output-format=json fio_job.ini

# 特定jobのみ実行する場合
$ fio --output=fio_out.json --output-format=json --section=seq-read-1m fio_job.ini
```


## パラメータメモ
詳細は、man fioを見ること
* ioengine=<ioengine>
    * libaio
        * Linux nativeの非同期I/O（基本的にはこれを選べばOK)
* direct=<0, 1>
    * 1で有効にすると、non-buffered I/O (usually O_DIRECT)になる
    * 基本的なIOはバッファが利用されるが、結果がブレるのでバッファは無効(1で有効)にするのが良い
    * また、高いIOを必要とするデータベースのようなシステムは、基本的にOSのバッファを使わない
* rw=<read, write, randread, randwrite>
    * すべてのパターンで計測すべき
* iodepth=<int>
    * ファイルに対するIO書き込みのユニット数
    * 何パターンかで計測すべき
* numjobs=<int>
    * 何パターンかで計測すべき
* bs=<default: 4k>
    * ブロックサイズ
    * 何パターンかで計測すべき
* directory
    * 測定で利用するディレクトリ
    * 測定したいデバイスのディレクトリを指定する
* finename
    * 測定で利用するファイル(directoryの配下に作られる)
    * 適当でOK
* size
    * 測定で利用するファイルのサイズ
    * 適当に16g 取っておけばOK
* runtime
    * jobの最大実行時間
* stonewall
    * jobがエラーで終了すると残りのジョブも終了する
* clat_percentiles=<0, 1>
    * 1で有効にすると、clat(リクエスト送信してから終了までのLatency)の99 percentileを取る


## fio_job.ini
```
[global]
ioengine=libaio
direct=1
iodepth=1
numjobs=1
bs=4k
size=16g
directory=/opt/sdb/fio
filename=fio-diskmark
runtime=60
stonewall
clat_percentiles=1

[seq-read-1m]
bs=1m
rw=read

[seq-write-1m]
bs=1m
rw=write

[seq-read-1m-qd32]
iodepth=32
bs=1m
rw=read

[seq-write-1m-qd32]
iodepth=32
bs=1m
rw=write

[rand-read-512]
bs=512
rw=randread

[rand-write-512]
bs=512
rw=randwrite

[rand-read-4k]
bs=4k
rw=randread

[rand-write-4k]
bs=4k
rw=randwrite

[rand-read-512k]
bs=512k
rw=randread

[rand-write-512k]
bs=512k
rw=randwrite

[rand-read-4k-qd8]
iodepth=8
bs=4k
rw=randread

[rand-write-4k-qd8]
iodepth=8
bs=4k
rw=randwrite

[rand-read-4k-qd32]
iodepth=32
bs=4k
rw=randread

[rand-write-4k-qd32]
iodepth=32
bs=4k
rw=randwrite

[rand-read-4k-qd32-j8]
iodepth=32
numjobs=8
bs=4k
rw=randread

[rand-write-4k-qd32-j8]
iodepth=32
numjobs=8
bs=4k
rw=randwrite

[rand-read-4k-qd32-j32]
iodepth=32
numjobs=32
bs=4k
rw=randread

[rand-write-4k-qd32-j32]
iodepth=32
numjobs=32
bs=4k
rw=randwrite
```


## 結果の見方
* iops
    * 1秒あたりのアクセス数
    * 基本的にこれだけ見ればディスクのIO性能がわかる
        * bw、iopsから逆算できる(bw = bs * iops)
* clat(msec)
    * complettion latency(リクエスト送信から終了までのLatency)
    * 99 percentileを見ておく
        * 99.99までのLatencyが妙に離れていないか？
        * もし、離れていればディスク不良などのために、外れ値が多く混ざった可能性がある
* 上記の参考値をいくつかとっておき、基準を作り妥当性を検証できるようにするとよい
    * メーカが公表しているデータとも比較すべき
* もし、数値がおかしければ、disk_utilやcpu, ctxなどの情報も見ておかしいところがないかチェックする
* また、smartctlなどのdiskチェックツールでエラーが出ないか確認する


## 参考
* [fioコマンド] http://tasuku.hatenablog.jp/entry/2016/02/21/163903
    * [FIOコマンドで利用できるパラメータ](http://tasuku.hatenablog.jp/entry/2016/02/20/174537)

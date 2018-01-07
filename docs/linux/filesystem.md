# ファイルシステム


## ファイル
* ファイル読み書きのチャネル
    * ファイルをopenするとファイルディスクリプタ（ファイル記述子）を得る
* inode
    * ファイルがディスク上のどこにあるかを示す
    * その他のメタデータ
        * サイズ、使用ブロック数、リンク数のカウント、アクセス権限、UID、GID、タイムスタンプなど
    * inodeはディスク上にある(ファイルシステムによってはない)
        * これをメモリにキャッシュして使ってる
        * 基本的にはメモリ上にあるモノをinodeと呼んでいる
    * inodeは一つのファイルシステムごとに一意になる
    * inodeはstatコマンドで確認できる
        * 以下はその結果だが、ファイル名は実はinodeには保存されてない
        * ファイル名はディレクトリエントリで管理されている
```
$ stat README.md
  File: 'README.md'
  Size: 484             Blocks: 8          IO Block: 4096   騾壼ｸｸ繝輔ぃ繧､繝ｫ
Device: 801h/2049d      Inode: 1574959     Links: 1
Access: (0664/-rw-rw-r--)  Uid: ( 1000/   owner)   Gid: ( 1000/   owner)
Access: 2017-12-17 21:29:50.091897601 +0900
Modify: 2017-12-17 21:29:50.091897601 +0900
Change: 2017-12-17 21:29:50.091897601 +0900
 Birth: -
```
* ファイルに関するシステムコール
    * open
    * read
    * write
    * see


## ディレクトリとディレクトリエントリ(dentry)
* ディレクトリとはファイル整理のためのデータベース、実態はdentry
* dentry
    * 実態はディスク上にあり、メモリにキャッシュして利用している
    * ファイル名の情報を持っており、inodeが紐づいている
* パスの解決
    * dentryをたどるとパスを解決できる
    * 相対パスも絶対パスも開始地点が違うだけで、たどり方は同じ


## ファイルディスクリプタとファイルオブジェクト
* プロセスごとにファイルディスクリプタテーブルがつくられる
    * ファイルディスクリプタテーブルとは、ファイルディスクリプタとファイルの対応表
* 複数のファイルディスクリプタで同一のファイルを操作することも可能
* ファイルディスクリプタ
    * dentryやシーク位置やフラグを管理してる
    * ファイルオブジェクトに紐づけられる
    * ファイルオブジェクトの先にファイルシステムがある
* ファイルディスクリプタとclone
    * 子プロセスを生成すると
        * ファイルディスクリプタテーブルだけコピーされる
        * ファイルオブジェクトはコピーされない
    * スレッドを生成すると
        * (指定がなければ)ファイルディスクリプタテーブルも共有する
* lsof
    * プロセスがopenしてるファイルを表示する
    * /proc/[pid]/fd を見てる
* パイプ
    * パイプを使うとファイルディスクリプタが2つできて間にリングバッファができて読み書きできる
* ネットワーク（ソケット）通信
    * ファイルディスクリプタ（ソケット)の先がネットワークのプロトコルスタックになってる
    *ソケット経由でプロセスはネットワーク通信を行う



## ブロックデバイス
* ランダムアクセス可能なデバイスをブロックデバイスとして抽象化している
    * ブロックの「アドレス」を指定して読み書きが可能
* MAJ:MIN
    * デバイスのメジャーバージョンとマイナーバージョン
    * 必要なデバイスドライバは、このバージョンから特定される
```
$ lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda     8:0    0 238.5G  0 disk
 sda1   8:1    0 222.6G  0 part /
 sda2   8:2    0     1K  0 part
 sda5   8:5    0  15.9G  0 part [SWAP]

# -Sでscsi関連の情報が出せる
$ lsblk -S
NAME HCTL       TYPE VENDOR   MODEL             REV TRAN
sda  0:0:0:0    disk ATA      TOSHIBA THNSNJ25 0101 sata
```

## ブロックデバイスとファイルシステム
* ブロックデバイスを「ブロック」に分割
    * 512バイト、1024バイト、4096バイト(x86_64はこれが限界)
* ファイルとブロックの対応関係を管理する
    * 対応関係自体もブロックデバイス上に記録する
    * ファイルシステムごとに、これをどのように記録するかが異なる
* ext2の場合
    * 最初にブロックデバイス上にinodeの領域を確保する
    * bitmapを持ち、各ブロックが使ってるかどうかを、true, faulseのbitのマップで管理している
    * inodeには、ブロックデバイスのどのブロックを参照するかが書かれている
        * inodeの参照テーブルが枯渇する場合は、間接参照用のテーブルが確保されてそこからブロックを参照する


## ページキャッシュ
* ページキャッシュをio request queueへ接続
    * リクエストから一定時間たてばディスクに書く
    * ページキャッシュのdirtyが上がったら書き込む(dirty_raitio)
    * ページキャッシュが一定量上がったら書き込む(dirty_bytes)
    * dirty_raitioとdirty_bytesは排他
        * dirty_raitioを書いたらdirty_bytesは0が書き込まれて無効になる
        * dirty_bytesを書いたらdirty_raitioは0が書き込まれて無効になる
    * io elevator(io scheduler)によって、並んだ書き込みやリクエストをマージする
        * cfq, deadline, noop
    * デバイスが高速なら、マージはあまり意味はないので、noop or deadlineでよい
* iostat -x 1
    * rrqm, wreqmがマージされた数
    * ddしながら見てみるとよい
* キューの長さを変える
    * echo 1024 > /sys/block/sda/queue/max_sectors_kb
* メモリが枯渇していて、キャッシュが確保できない時は、確保できるまでプロセスが止められる
* mount option: async
    * キャッシュに書いたら完了にして、非同期に書き込む
* mount option: sync
    * 同期的に書き込む
* aio write
    * IOリクエストしたらキャッシュに書いた時点で書き込み完了
    * そして、非同期に書き込んで、その結果(成功、失敗）をシグナルで受け取る


## mount


## nfs


## iscsi


## devicemapper


## loopback device


## LVM
LVM（logical volume manager）とは，複数のハード・ディスクやパーティションにまたがった記憶領域を一つの論理的なディスクとして扱うことのできるディスク管理機能

### 仕組み
1. 物理ボリューム（PV）を数十Mバイトの多数の小さな領域、物理エクステンド（PE）に分割する

____________[PV]______________
 [PE][PE][PE][PE][PE][PE][PE]

2. PEをボリュームグループ（VG）に所属させる

____________[VG]______________
 [PE][PE][PE][PE][PE][PE][PE]

3. 必要な分のPEを論理ボリューム（LV）に割り当てる  
ボリュームグループを仮想的なディスクとするならば論理ボリュームは仮想的なパーティション(デバイス)と考えることができる

_____[LV]_____  ______[LV]_______
 [PE][PE][PE]    [PE][PE][PE][PE]

4. LVをディレクトリにマウントして利用

__[LV]__  __[LV]__
 /home      /var


### 利用手順
* 必要パッケージのインストール
``` bash
$ sudo yum install lvm2
$ service lvm2-lvmetad start
```

* ボリューム領域を作成する
ddで空ファイルを作成する  
もしくは、パーティションを切ってもよい
``` bash
$ dd if=/dev/zero of=/tmp/test-volume bs=1 count=0 seek=10G
```

* losetupでloopデバイスを作成したファイルと接続する
losetupは、loopデバイスを通常ファイルやブロックデバイスと接続・切断する
``` bash
# アタッチ
$ losetup /dev/loop2 /tmp/test-volume

# 確認
$ losetup /dev/loop2
/dev/loop2: []: (/tmp/test-volume)

# デタッチ
$ losetup -d /dev/loop2
```

* pvcreateでデバイスを初期化する
pvcreate は、物理ボリュームとして利用するブロックデバイスを初期化しPEに分割します。
``` bash
# デバイスを初期化
$ sudo pvcreate /dev/loop2
  Physical volume "/dev/loop2" successfully created

# 確認
$ sudo pvscan
  PV /dev/vda2    VG centos   lvm2 [31.51 GiB / 44.00 MiB free]
  PV /dev/loop2               lvm2 [1.00 GiB]
  Total: 2 [32.51 GiB] / in use: 1 [31.51 GiB] / in no VG: 1 [1.00 GiB]


# lvmdiskscanで物理ボリュームとして利用できるブロックデバイスをスキャンできます
$ sudo lvmdiskscan
  /dev/centos/root [      28.27 GiB]
  /dev/vda1        [     500.00 MiB]
  /dev/centos/swap [       3.20 GiB]
  /dev/loop2       [       1.00 GiB] LVM physical volume
  /dev/vda2        [      31.51 GiB] LVM physical volume
  2 disks
  1 partition
  0 LVM physical volume whole disks
  2 LVM physical volumes
```

* vgcreateでボリュームグループを作成
``` bash
$ sudo vgcreate volume00 /dev/loop2
  Volume group "volume00" successfully created

# ボリュームグループを設定ファイルに付け足す
$ vim /etc/lvm/lvm.conf
> volume_list = [ ..., "volume00" ]

# サービスをリスタート
$ service lvm2-lvmetad restart
```

* lvcreateでLVを作成する
``` bash
# LVを作成
$ sudo lvcreate -L 50M -n lv01 volume00
  Rounding up size to full physical extent 52.00 MiB
  Logical volume "lv01" created.

# 確認
$ sudo lvdisplay volume00
  --- Logical volume ---
  LV Path                /dev/volume00/lv01
  LV Name                lv01
  VG Name                volume00
  LV UUID                94LquW-xjcj-Ol35-5RQA-7QzZ-GV7O-6FbET3
  LV Write Access        read/write
  LV Creation host, time rabbit0, 2015-10-17 18:18:24 +0900
  LV Status              available
  # open                 0
  LV Size                52.00 MiB
  Current LE             13
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2
```

* LV通常のブロックデバイスと同様に利用できる
```
# フォーマット
$ sudo mkfs -t xfs /dev/volume00/lv01
[sudo] password for owner:
meta-data=/dev/volume00/lv01     isize=256    agcount=2, agsize=6656 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=0        finobt=0
data     =                       bsize=4096   blocks=13312, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=0
log      =internal log           bsize=4096   blocks=853, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

# マウント
$ sudo mount -t xfs /dev/volume00/lv01 /mnt

# 書き込みテスト
$ touch /mnt/helloworld
$ ls /mnt
```

* 後片付け
``` bash
# アンマウント
$ sudo umount /mnt

# LV, VG を削除
$ sudo lvremove lv01 volume00
  Volume group "lv01" not found
  Cannot process volume group lv01
Do you really want to remove active logical volume lv01? [y/n]: y
  Logical volume "lv01" successfully removed

$ sudo vgremove volume00

# loopデバイスからファイルをデタッチ
$ sudo losetup -d /dev/loop2

# ファイルを削除する
$ sudo rm /tmp/test-volume
```


## パーティション
```
$ sudo parted -l
Model: ATA TOSHIBA THNSNJ25 (scsi)
Disk /dev/sda: 256GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End    Size    Type      File system     Flags
 1      1049kB  239GB  239GB   primary   ext4            boot
 2      239GB   256GB  17.0GB  extended
 5      239GB   256GB  17.0GB  logical   linux-swap(v1)

$ mount
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
udev on /dev type devtmpfs (rw,nosuid,relatime,size=3842644k,nr_inodes=960661,mode=755)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
tmpfs on /run type tmpfs (rw,nosuid,noexec,relatime,size=1611440k,mode=755)
/dev/sda1 on / type ext4 (rw,relatime,errors=remount-ro,data=ordered)
...
```


## メモ
* procをマウントする
    * mount -t proc abc /tmp/abc
* hachoir tests
    * バイナリファイルに対するwireshark
* ioctl [ファイルディスクリプタ] [デバイス]
    * デバイスによって挙動がいろいろ
    * kvmもこれで呼ばれる
* 基本的にkernel自体はioをすることはない（すべきでもない）
    * 例外
        * core dumpぐらい
    * swap in, swap out
    * モジュール読み込み、modprobはモジュールをメモリに読み込んでからカーネルに渡すので、カーネルはIOしない
* ディスク性能を計測するときはキャッシュを消してから行う
    * echo 1 > /proc/sys/vm/drop_caches

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
  Size: 484             Blocks: 8          IO Block: 4096
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
    * ソケット経由でプロセスはネットワーク通信を行う



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
    * ページキャッシュに乗る
* mount option: sync
    * 同期的に書き込む
    * ユーザプロセス内のバッファとデバイスで直接データ転送する
    * ページキャッシュに乗らない
* aio write
    * IOリクエストしたら完了
    * そして、非同期に書き込んで、その結果(成功、失敗）をシグナルで受け取る
* aio read
    * IOリクエストしたら完了
    * そして、非同期に読み込んで、その結果(成功、失敗）をシグナルで受け取る
    * 通知時には、プロセスのバッファにデータが入っている


## ディスクとアドレッシング
* ハードディスクの構成要素
    * インターフェイス
        * SATA
    * スピンドル
        * 回転軸
    * プラッタ
        * 円盤状の記録版
        * プラッタは同心円状に並ぶトラックに分割され、さらにトラックはセクタに分割される
        * シリンダは、データが存在するトラックを表す
    * ヘッド
        * プラッタあたりに一つ存在し、読み書きをする
* CHS(シリンダ・ヘッド・セクタ)
    * ヘッドをシリンダ(データのあるトラック)に移動して、プラッタを回転してセクタ位置まで動かし、ヘッダが読み書きする
    * 昔はCHSアドレッシングにより読み書きを行っていた
* LBA(Logical Block Addresing)
    * CHSに対して、一意のブロック番号をマッピングし、ブロック番号からセクタを特定できるようにする
    * OSはこのブロック番号を使ってデバイスにアクセスする


## SSDとアドレッシング
* SSDの構成要素
    * インターフェイス
        * SATA
        * PCIe
            * PCIeスロット(x4) or M.2スロットで接続する
        * プロトコル
            * AHCI
                * Advanced Host Controller Interface
                * SATA SSDによって使用されるプロトコルと同じ
                * PCIe接続でもプロトコルはAHCIを利用してる場合もある
            * NVMe
                * Non Volatile-Memory Express
                    * SSDストレージ用に設計されたプロコル
                    * PCIe NVMe SSDは、ドライブに独自のNVMeストレージコントローラを組み込んでる
                * CPUを介さずにPCIeバス経由でDMA(直接メモリにアクセス)を利用する
                * 割り込みシステム
                    * 転送を保留するためのキューセットと完了ステータス用のキューセットを持つ循環キュー方式
                    * RDMA(リモートダイレクトメモリアクセス)をつかてこれらのコマンドキューを解析し、完了キューを応答ブロックで処理することで割り込みを効率的に集約
            * 独自プロトコル
                * OSに独自のドライバを入れて利用する独自プロトコルもある
                    * Fusion-io(今はないけど)
    * NANDメモリコントローラ
        * サポートする並列アクセス数により性能が大きく変わってくる
            * 16チャンネル並列アクセスから、32チャンネル並列アクセスになると理論上の速度は2倍になる
        * ウェアレベリング
            * 記録エリアごとに書き換え回数を常に監視し、その情報を管理することで同じエリアばかりにデータの記録が集中しないように平準化する機能
        * 不良ブロック管理
            * エラーが発生し、読み書きできなくなった記憶領域を管理リストに登録し、二度と使用しないようにする機能
        * エラー訂正機能
            * NANDメモリに記録したデータの信頼性を確保する機能
    * キャッシュメモリ
        * NANDメモリの管理情報の保管、データのキャッシュに利用される
    * NANDメモリチップ
        * TSOP(Thin Small Outline Package)タイプのNANDメモリチップを搭載してる製品が多い
        * 通常、コントr－らの並列アクセス数と同じ数、またはその2倍の数のチップを実装している
* アドレッシング
    * 読み書きを「ページ」と呼ばれる単位で行う
    * 消去は複数のページをまとめた「ブロック」という単位で行う
* データの上書き
    * NANDメモリではデータの上書き行えない
    * ページ内のデータを変更する処理(ブロックコピー)の流れ
        * そのページを含むブロック全体のデータを空きのあるブロックに退避させる
        * ブロックのデータに消去を行ったあとに変更したデータとともにブロック全体を書き戻す
* SLC、MLC、TLC、QLC
    * 1つのメモリセルに何bit記録するかでタイプ分けしている
        * 1bit(Single), 2bit(Multi), 3bit(Triple), 4bit(Quad)
    * メモリセルの容量、寿命、速度はトレードオフ
        * 1セルあたりのbit数が多いほど、大量量化しやすい(コストに対して容量を稼げる)
        * 1セルあたりbit数が多いほど、1bitあたりの書き込み回数の上限は低くなり、速度も落ちる
        * 書き込み回数の上限
            * SLC: 90000-100000
            * MLC: 8000-10000
            * TLC: 3000-5000
            * QLC: 1000


## アドレッシング
* VFSがデータを読み込むときの例
    * マッピングレイヤによって、データの物理的な位置を特定する
        * ファイルのブロック長、データ範囲、ブロック番号を求める
            * ファイルシステムのブロック長を求める
            * ファイル内ブロック番号の形式で、要求を受けたデータの範囲を計算する
            * ファイルは多くのブロックから形成されており、要求を受けたデータを含むブロック番号(ファイルの先頭からの相対位置)を求める
        * ファイルシステムから論理ブロック番号を求める
            * ファイルシステム固有の関数で、ファイルのiノードにアクセスして、要求を受けたデータの位置を論理ブロック番号として求める
            * 物理ディスクも多くのブロックから構成されており、要求を受けたデータを含むブロック番号(ディスクもしくはパーティションの先頭からの相対位置)を求める
            * ファイルは物理ディスク上の隣接したブロックに格納されているとは限らないため、inode内のデータ構造を用いて、ファイル内ブロック番号から論理ブロック番号への対応付を行っていく
    * 汎用ブロック層により、要求を受けたデータを転送するI/O操作を開始する
        * データが隣接していない場合は、その分だけI/O処理を実行する
    * IOスケジューラ層により、I/O操作の並び替えや、マージが行われる
    * デバイスドライバにより、I/O操作が行われる
        * デバイスドライバは、ディスクコントローラのハードウェアインターフェースに適切なコマンドを送ることで、データ転送を行う
* ストレージアクセス用のパラメータ
    * hw_sector_size, physical_block_size
        * デバイスが動作できる最小の内部ユニット
        * デバイスドライバはこのブロックの単位でデータ転送を行う
    * logical_block_size
        * デバイス上のアドレス指定で利用されるユニット
    * minimum_io_size
        * ランダムなI/Oに対して推奨のデバイス最小ユニット
    * optimal_io_size
        * ストリーミングI/Oに対して推奨のデバイスユニット
    * alignment_offset
        * 基礎となる物理的なアライメントのオフセットとなるLinuxブロックデバイス(パーティション/MD/LVMデバイス)の先頭部分のバイト数
    * minimum_io_size, optimal_io_sizeは、RAIDデバイスのチャンクサイズとストライプサイズに該当する

```
$ cat /sys/block/sdb/queue/hw_sector_size
512

$ cat /sys/block/sdb/queue/physical_block_size
512

$ cat /sys/block/sdb/queue/logical_block_size
512

$ cat /sys/block/sdb/queue/minimum_io_size
512

$ cat /sys/block/sdb/queue/optimal_io_size
0

$ cat /sys/block/sda/alignment_offset
0
```


## loopback device
* 一般的なファイルを、ブロックデバイスのように扱うための機能
* イメージファイルなどを直接操作したい場合に使う
    * 仮想イメージqcow2をrowに変換して、loopback deviceにアタッチして、loopback deviceをマウントして、中身を操作するなどできる


## devicemapper
* ブロックデバイスドライバおよびそれをサポートするライブラリ群
    * ブロック層の仮想化レイヤでありフレームワーク
    * LVM2でも利用されている
* コピーオンライト、スナップショットなどが可能
* device-mapperは仮想的なブロックデバイスを作成し、その仮想デバイスは受け取ったI/Oを処理する
* 物理的なブロックデバイスが行うべき処理を完全にemulateする
* 仮想デバイスは仮想デバイスの上に作成することも可能
    * このような特性からstacked deviceとも呼ばれる
    * さまざまなシンプルな機能を仮想デバイスとしてstackすることで、複雑な機能を持った仮想デバイスを実現することが可能


## LVM
* Logical Volume Manager
* 複数のハード・ディスクやパーティションにまたがった記憶領域を一つの論理的なディスクとして扱うことのできるディスク管理機能

* 仕組み

```
# 物理ボリューム（PV）を数十Mバイトの多数の小さな領域、物理エクステンド（PE）に分割する
____________[PV]______________
 [PE][PE][PE][PE][PE][PE][PE]

# PEをボリュームグループ（VG）に所属させる
____________[VG]______________
 [PE][PE][PE][PE][PE][PE][PE]

# 必要な分のPEを論理ボリューム（LV）に割り当てる
# ボリュームグループを仮想的なディスクとするならば論理ボリュームは仮想的なパーティション(デバイス)と考えることができる
_____[LV]_____  ______[LV]_______
 [PE][PE][PE]    [PE][PE][PE][PE]

# LVをディレクトリにマウントして利用

__[LV]__  __[LV]__
 /home      /var
```

* 利用手順

``` bash
# パッケージインストール
$ sudo yum install lvm2

# LVMサービスをスタート
$ service lvm2-lvmetad start

# ボリューム領域を作成する
# ddで空ファイルを作成する、もしくはパーティションを切ってもよい
$ dd if=/dev/zero of=/tmp/test-volume bs=1 count=0 seek=10G

# losetupでloopデバイスを作成したファイルと接続する
# losetupは、loopデバイスを通常ファイルやブロックデバイスと接続・切断する
# アタッチ
$ losetup /dev/loop2 /tmp/test-volume

# デタッチ
# $ losetup -d /dev/loop2

# 確認
$ losetup /dev/loop2
/dev/loop2: []: (/tmp/test-volume)

# pvcreateでデバイスを初期化する
# pvcreate は、物理ボリュームとして利用するブロックデバイスを初期化しPEに分割する
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

# vgcreateでボリュームグループを作成
$ sudo vgcreate volume00 /dev/loop2
  Volume group "volume00" successfully created

# ボリュームグループを設定ファイルに付け足す
$ vim /etc/lvm/lvm.conf
> volume_list = [ ..., "volume00" ]

# サービスをリスタート
$ service lvm2-lvmetad restart

# lvcreateでLVを作成する
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

* LVは通常のブロックデバイスと同様に利用できる

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


## マウントしているFSを調べる
* mount

```
$ mount
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
udev on /dev type devtmpfs (rw,nosuid,relatime,size=8162844k,nr_inodes=2040711,mode=755)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
tmpfs on /run type tmpfs (rw,nosuid,noexec,relatime,size=1637448k,mode=755)
/dev/sda1 on / type ext4 (rw,relatime,errors=remount-ro,data=ordered)
...
```

* df
```
df -a
Filesystem     1K-blocks      Used Available Use% Mounted on
sysfs                  0         0         0    - /sys
proc                   0         0         0    - /proc
udev             8162844         0   8162844   0% /dev
devpts                 0         0         0    - /dev/pts
tmpfs            1637448      9568   1627880   1% /run
/dev/sda1      229613780 143513692  74413332  66% /
...
```


## dumpe2fs
* ext2/ext3/ext4
```
$ sudo dumpe2fs /dev/sda1 | less
Filesystem volume name:   <none>
Last mounted on:          /
Filesystem UUID:          c5a29305-9548-4405-a4d2-5687eda29d87
Filesystem magic number:  0xEF53
Filesystem revision #:    1 (dynamic)
Filesystem features:      has_journal ext_attr resize_inode dir_index filetype needs_recovery extent flex_bg sparse_super large_file huge_file uninit_bg dir_nlink extra_isize
Filesystem flags:         signed_directory_hash
Default mount options:    user_xattr acl
Filesystem state:         clean
Errors behavior:          Continue
Filesystem OS type:       Linux
Inode count:              14589952
Block count:              58351872
Reserved block count:     2917593
Free blocks:              21537480
Free inodes:              10921380
First block:              0
Block size:               4096
Fragment size:            4096
Reserved GDT blocks:      1010
Blocks per group:         32768
Fragments per group:      32768
Inodes per group:         8192
Inode blocks per group:   512
Flex block group size:    16
Filesystem created:       Tue May  5 15:48:41 2015
Last mount time:          Sun Feb 25 20:28:31 2018
Last write time:          Sun Feb 25 20:28:30 2018
Mount count:              269
Maximum mount count:      -1
Last checked:             Tue May  5 15:48:41 2015
Check interval:           0 (<none>)
Lifetime writes:          11 TB
Reserved blocks uid:      0 (user root)
Reserved blocks gid:      0 (group root)
First inode:              11
Inode size:               256
Required extra isize:     28
Desired extra isize:      28
Journal inode:            8
First orphan inode:       3686347
Default directory hash:   half_md4
Directory Hash Seed:      e8aebce0-015c-4d7c-acac-9ed0558f5452
Journal backup:           inode blocks
Journal features:         journal_incompat_revoke
Journal size:             128M
Journal length:           32768
Journal sequence:         0x0048eda4
Journal start:            8573
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


## nfs



## iscsi



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

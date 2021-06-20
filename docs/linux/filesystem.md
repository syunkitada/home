# ファイルシステム

## ファイル

- ファイル読み書きのチャネル
  - ファイルを open するとファイルディスクリプタ（ファイル記述子）を得る
- inode
  - ファイルがディスク上のどこにあるかを示す
  - その他のメタデータ
    - サイズ、使用ブロック数、リンク数のカウント、アクセス権限、UID、GID、タイムスタンプなど
  - inode はディスク上に保存されている(ファイルシステムによってはない場合もある)
    - これをメモリにキャッシュして使ってる
    - 基本的にはメモリ上にあるモノを inode と呼んでいる
  - inode は一つのファイルシステムごとに一意になる
  - inode は stat コマンドで確認できる
    - 以下はその結果だが、ファイル名は実は inode には保存されてない
    - ファイル名はディレクトリエントリで管理されている

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

- ファイルに関するシステムコール
  - open
  - read
  - write
  - see

## ディレクトリとディレクトリエントリ(dentry)

- ディレクトリとはファイル整理のためのデータベース、実態は dentry
- dentry
  - 実態はディスク上にあり、メモリにキャッシュして利用している
  - ファイル名の情報を持っており、inode が紐づいている
- パスの解決
  - dentry をたどるとパスを解決できる
  - 相対パスも絶対パスも開始地点が違うだけで、たどり方は同じ

## ファイルディスクリプタとファイルオブジェクト

- プロセスごとにファイルディスクリプタテーブルがつくられる
  - ファイルディスクリプタテーブルとは、ファイルディスクリプタとファイルの対応表
- 複数のファイルディスクリプタで同一のファイルを操作することも可能
- ファイルディスクリプタ
  - dentry やシーク位置やフラグを管理してる
  - ファイルオブジェクトに紐づけられる
  - ファイルオブジェクトの先にファイルシステムがある
- ファイルディスクリプタと clone
  - 子プロセスを生成すると
    - ファイルディスクリプタテーブルだけコピーされる
    - ファイルオブジェクトはコピーされない
  - スレッドを生成すると
    - (指定がなければ)ファイルディスクリプタテーブルも共有する
- lsof
  - プロセスが open してるファイルを表示する
  - /proc/[pid]/fd を見てる
- パイプ
  - パイプを使うとファイルディスクリプタが 2 つできて間にリングバッファができて読み書きできる
- ネットワーク（ソケット）通信
  - ファイルディスクリプタ（ソケット)の先がネットワークのプロトコルスタックになってる
  - ソケット経由でプロセスはネットワーク通信を行う

## ブロックデバイス

- ランダムアクセス可能なデバイスをブロックデバイスとして抽象化している
  - ブロックの「アドレス」を指定して読み書きが可能
- MAJ:MIN
  - デバイスのメジャーバージョンとマイナーバージョン
  - 必要なデバイスドライバは、このバージョンから特定される

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

- ブロックデバイスを「ブロック」に分割
  - 512 バイト、1024 バイト、4096 バイト(x86_64 はこれが限界)
- ファイルとブロックの対応関係を管理する
  - 対応関係自体もブロックデバイス上に記録する
  - ファイルシステムごとに、これをどのように記録するかが異なる
- ext2 の場合
  - 最初にブロックデバイス上に inode の領域を確保する
  - bitmap を持ち、各ブロックが使ってるかどうかを、true, faulse の bit のマップで管理している
  - inode には、ブロックデバイスのどのブロックを参照するかが書かれている
    - inode の参照テーブルが枯渇する場合は、間接参照用のテーブルが確保されてそこからブロックを参照する

## ページキャッシュ

- ページキャッシュを io request queue へ接続
  - リクエストから一定時間たてばディスクに書く
  - ページキャッシュの dirty が上がったら書き込む(dirty_raitio)
  - ページキャッシュが一定量上がったら書き込む(dirty_bytes)
  - dirty_raitio と dirty_bytes は排他
    - dirty_raitio を書いたら dirty_bytes は 0 が書き込まれて無効になる
    - dirty_bytes を書いたら dirty_raitio は 0 が書き込まれて無効になる
  - io elevator(io scheduler)によって、並んだ書き込みやリクエストをマージする
    - cfq, deadline, noop
  - デバイスが高速なら、マージはあまり意味はないので、noop or deadline でよい
- iostat -x 1
  - rrqm, wreqm がマージされた数
  - dd しながら見てみるとよい
- キューの長さを変える
  - echo 1024 > /sys/block/sda/queue/max_sectors_kb
- メモリが枯渇していて、キャッシュが確保できない時は、確保できるまでプロセスが止められる
- mount option: async
  - キャッシュに書いたら完了にして、非同期に書き込む
  - ページキャッシュに乗る
- mount option: sync
  - 同期的に書き込む
  - ユーザプロセス内のバッファとデバイスで直接データ転送する
  - ページキャッシュに乗らない
- aio write
  - IO リクエストしたら完了
  - そして、非同期に書き込んで、その結果(成功、失敗）をシグナルで受け取る
- aio read
  - IO リクエストしたら完了
  - そして、非同期に読み込んで、その結果(成功、失敗）をシグナルで受け取る
  - 通知時には、プロセスのバッファにデータが入っている

## ディスクとアドレッシング

- ハードディスクの構成要素
  - インターフェイス
    - SATA
  - スピンドル
    - 回転軸
  - プラッタ
    - 円盤状の記録版
    - プラッタは同心円状に並ぶトラックに分割され、さらにトラックはセクタに分割される
    - シリンダは、データが存在するトラックを表す
  - ヘッド
    - プラッタあたりに一つ存在し、読み書きをする
- CHS(シリンダ・ヘッド・セクタ)
  - ヘッドをシリンダ(データのあるトラック)に移動して、プラッタを回転してセクタ位置まで動かし、ヘッダが読み書きする
  - 昔は CHS アドレッシングにより読み書きを行っていた
- LBA(Logical Block Addresing)
  - CHS に対して、一意のブロック番号をマッピングし、ブロック番号からセクタを特定できるようにする
  - OS はこのブロック番号を使ってデバイスにアクセスする
- 参考リンク
  - [HDD の構造と消耗、高密度プラッタが復旧難易度を上げてしまう理由](https://pc.watch.impress.co.jp/docs/column/storage/1231038.html)

## SSD とアドレッシング

- SSD の構成要素
  - インターフェイス
    - SATA
    - PCIe
      - PCIe スロット(x4) or M.2 スロットで接続する
    - プロトコル
      - AHCI
        - Advanced Host Controller Interface
        - SATA SSD によって使用されるプロトコルと同じ
        - PCIe 接続でもプロトコルは AHCI を利用してる場合もある
      - NVMe
        - Non Volatile-Memory Express
          - SSD ストレージ用に設計されたプロコル
          - PCIe NVMe SSD は、ドライブに独自の NVMe ストレージコントローラを組み込んでる
        - CPU を介さずに PCIe バス経由で DMA(直接メモリにアクセス)を利用する
        - 割り込みシステム
          - 転送を保留するためのキューセットと完了ステータス用のキューセットを持つ循環キュー方式
          - RDMA(リモートダイレクトメモリアクセス)を使ってこれらのコマンドキューを解析し、完了キューを応答ブロックで処理することで割り込みを効率的に集約
      - 独自プロトコル
        - OS に独自のドライバを入れて利用する独自プロトコルもある
          - Fusion-io(今はないけど)
  - SSD コントローラ
    - FTL(Flash Translation Layer)
      - OS は論理アドレスに対して、インターフェイスを通して、命令を送ってくるためこれを処理するレイヤ
    - キャッシュメモリ
      - 論理アドレスと物理アドレスのマッピングを管理している
    - ウェアレベリング
      - セルには書き換え回数に寿命があるため、記録エリアごとに書き換え回数を常に監視し、その情報を管理することで同じエリアばかりにデータの記録が集中しないように平準化する機能
    - 不良ブロック管理
      - エラーが発生し、読み書きできなくなった記憶領域を管理リストに登録し、二度と使用しないようにする機能
    - エラー訂正機能
      - NAND メモリに記録したデータの信頼性を確保する機能
    - ガベージコレクション
      - 保持すべきデータだけを別ブロックに書き直して、空きブロックを増やす処理のこと
      - ページの断片化を防ぐ効果もある
      - 通常は、読み出しや書き込みをしていない間にガベージコレクションを実行する
      - また、NAND フラッシュの空きスペースを計算し、Spare Block をバッファ領域として管理してるので、通常ガベージコレクションが SSD のパフォーマンスに影響を与えることはない
  - NAND メモリコントローラ
    - サポートする並列アクセス数により性能が大きく変わってくる
      - 16 チャンネル並列アクセスから、32 チャンネル並列アクセスになると理論上の速度は 2 倍になる
  - NAND メモリチップ
    - TSOP(Thin Small Outline Package)タイプの NAND メモリチップを搭載してる製品が多い
    - 通常、コントローラの並列アクセス数と同じ数、またはその 2 倍の数のチップを実装している
  - NAND メモリブロック
    - NAND セルを束ねたもの
    - NAND セル
      - データを実際に格納するところ
      - セルは、ControlGate(Gate)、Oxid、FloatingGate、TunnelOxid(トンネル障壁)、NPN(Source, GND, Drain)シリコンで構成される
        - データの保持は FloatingGate で行い、Oxid、TunnelOxid で挟まれており、電化は外に流れない状態となっている
        - Gate と Source に電圧をかけると、FloatingGate に電化が入り、Gate と Drain に電圧をかけると電化が抜ける
        - セルには寿命があり、データの出し入れをすると、TunnelOxide が劣化するため、データをうまく保存できなくなる(FloatingGate から電化が抜けてしまう)
        - 1 つのメモリセルに何 bit 記録するかでタイプ分けしている
          - 1bit(Single), 2bit(Multi), 3bit(Triple), 4bit(Quad)
        - メモリセルの容量、寿命、速度はトレードオフ
          - 1 セルあたりの bit 数が多いほど、大容量化しやすい(コストに対して容量を稼げる)
          - 1 セルあたり bit 数が多いほど、1bit あたりの書き込み回数の上限は低くなり、速度も落ちる
          - 書き込み回数の上限
            - SLC: 90000-100000
            - MLC: 8000-10000
            - TLC: 3000-5000
            - QLC: 1000
- アドレッシング
  - 読み書きを「ページ」と呼ばれる単位で行う
  - 消去は複数のページをまとめた「ブロック」という単位で行う
- データの上書き
  - NAND メモリではデータの上書きは行えない
  - ページ内のデータを変更する処理(ブロックコピー)の流れ
    - 空きブロックを用意しておく
    - 書き込み先のブロックから書き換えるセクタ以外のデータをそのままコピーする
    - 書き換えたいセクター（新しいデータ）を消去済みのブロックに書き込む
    - 書き込んだブロックを元のブロックと入れ替える（アドレステーブル更新)
    - 元のブロックを消去し、空きブロックにする
    - 空きブロックがないと
- fstrim
  - xfs などの FS ではファイルを削除する場合、論理的に削除するだけ(OS 上で削除してるように見えるだけ)で SSD 上ではそのブロックは削除されない
  - そこで、fstrim を実行することで、削除されたブロックをデバイスに通知することができる
  - SSD 側は、削除されたブロックを知ることができるので、ガベージコレクションが効率よく行えるようになる
  - fstrim の注意点
    - 実行中に空き領域を探索する理由から、一定の単位でロックをとるため、他のワークロードに影響がないかを確認しておくとよい
  - 大量のファイルが頻繁に作成、削除されるようなワークロードの場合、SSD 側の物理ブロックも断片化しやすいため定期的に fstrim をしておくとよい
  - 大きめのファイルを作成して、そこが頻繁に書き換えられるワークロードの場合は、断片化は起こりにくい
  - 基本的に空き容量を使いつぶすような運用をしなければ、空きブロックが不足するということもないので、fstrim は必須というわけではない

## アドレッシング

- VFS がデータを読み込むときの例
  - マッピングレイヤによって、データの物理的な位置を特定する
    - ファイルのブロック長、データ範囲、ブロック番号を求める
      - ファイルシステムのブロック長を求める
      - ファイル内ブロック番号の形式で、要求を受けたデータの範囲を計算する
      - ファイルは多くのブロックから形成されており、要求を受けたデータを含むブロック番号(ファイルの先頭からの相対位置)を求める
    - ファイルシステムから論理ブロック番号を求める
      - ファイルシステム固有の関数で、ファイルの i ノードにアクセスして、要求を受けたデータの位置を論理ブロック番号として求める
      - 物理ディスクも多くのブロックから構成されており、要求を受けたデータを含むブロック番号(ディスクもしくはパーティションの先頭からの相対位置)を求める
      - ファイルは物理ディスク上の隣接したブロックに格納されているとは限らないため、inode 内のデータ構造を用いて、ファイル内ブロック番号から論理ブロック番号への対応付を行っていく
  - 汎用ブロック層により、要求を受けたデータを転送する I/O 操作を開始する
    - データが隣接していない場合は、その分だけ I/O 処理を実行する
  - IO スケジューラ層により、I/O 操作の並び替えや、マージが行われる
  - デバイスドライバにより、I/O 操作が行われる
    - デバイスドライバは、ディスクコントローラのハードウェアインターフェースに適切なコマンドを送ることで、データ転送を行う
- ストレージアクセス用のパラメータ
  - hw_sector_size, physical_block_size
    - デバイスが動作できる最小の内部ユニット
    - デバイスドライバはこのブロックの単位でデータ転送を行う
  - logical_block_size
    - デバイス上のアドレス指定で利用されるユニット
  - minimum_io_size
    - ランダムな I/O に対して推奨のデバイス最小ユニット
  - optimal_io_size
    - ストリーミング I/O に対して推奨のデバイスユニット
  - alignment_offset
    - 基礎となる物理的なアライメントのオフセットとなる Linux ブロックデバイス(パーティション/MD/LVM デバイス)の先頭部分のバイト数
  - minimum_io_size, optimal_io_size は、RAID デバイスのチャンクサイズとストライプサイズに該当する

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

- 一般的なファイルを、ブロックデバイスのように扱うための機能
- イメージファイルなどを直接操作したい場合に使う
  - 仮想イメージ qcow2 を row に変換して、loopback device にアタッチして、loopback device をマウントして、中身を操作するなどできる

## devicemapper

- ブロックデバイスドライバおよびそれをサポートするライブラリ群
  - ブロック層の仮想化レイヤでありフレームワーク
  - LVM2 でも利用されている
- コピーオンライト、スナップショットなどが可能
- device-mapper は仮想的なブロックデバイスを作成し、その仮想デバイスは受け取った I/O を処理する
- 物理的なブロックデバイスが行うべき処理を完全に emulate する
- 仮想デバイスは仮想デバイスの上に作成することも可能
  - このような特性から stacked device とも呼ばれる
  - さまざまなシンプルな機能を仮想デバイスとして stack することで、複雑な機能を持った仮想デバイスを実現することが可能

## LVM

- Logical Volume Manager
- 複数のハード・ディスクやパーティションにまたがった記憶領域を一つの論理的なディスクとして扱うことのできるディスク管理機能

- 仕組み

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

- 利用手順

```bash
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

- LV は通常のブロックデバイスと同様に利用できる

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

- 後片付け

```bash
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

## マウントしている FS を調べる

- mount

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

- df

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

- ext2/ext3/ext4

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

## seq ファイルシステム

- /proc などに代表される仮想ファイルのためのフレームワーク的なファイルシステム
- seq ファイルシステムを利用した特殊なファイルに対して read システムコールを実行した際、通常はカーネル側で確保された PAGE_SIZE(基本は 4K)と同じ容量のバッファを経由して、read システムコールに指定されたユーザー空間側のバッファ領域にデータをコピーする
- /proc/net/tcp などのデータ量が多くなりがちなファイルを読もうとすると read を何度も実行することになる
  - strace /proc/net/tcp などするとその様子を見ることができる
  - このため、ss コマンドなどはネットワークの情報を取るときには netlink を利用している
- 参考
  - [netstat コマンドを高速化する](https://qiita.com/mutz0623/items/7b000a6ac0f75df5dafd)
  - [seq ファイルシステムについて](https://qiita.com/akachochin/items/98085494081b8bc39cbb)

## nfs

## iscsi

## メモ

- proc をマウントする
  - mount -t proc abc /tmp/abc
- hachoir tests
  - バイナリファイルに対する wireshark
- ioctl [ファイルディスクリプタ][デバイス]
  - デバイスによって挙動がいろいろ
  - kvm もこれで呼ばれる
- 基本的に kernel 自体は io をすることはない（すべきでもない）
  - 例外
    - core dump ぐらい
  - swap in, swap out
  - モジュール読み込み、modprob はモジュールをメモリに読み込んでからカーネルに渡すので、カーネルは IO しない
- ディスク性能を計測するときはキャッシュを消してから行う
  - echo 1 > /proc/sys/vm/drop_caches

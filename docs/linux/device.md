# Device

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


## 参考
* http://itpro.nikkeibp.co.jp/article/Keyword/20071012/284413/
* https://users.miraclelinux.com/technet/document/linux/training/2_2_3.html




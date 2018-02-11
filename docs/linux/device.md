# デバイス


## デバイスとは
* デバイスの種類
    * block-device
    * character stream device
    * network device
    * 時計とタイマ
* データ転送の種類
    * Direct Memory Access(DMA)
        * CPUを使わずにデータ転送
    * programmed I/O(PIO)
        * CPUを使ってデータ転送


## CPUとデバイスのやり取り
* デバイスコントローラとデバイスドライバ
    * 各I/O機器はそれぞれデバイスコントローラを持ち、デバイスコントローラとCPUが接続されている
        * 例外的にいくつかの機器が、ひとつのデバイスコントローラを共有する場合もある(例: SCSI)
    * デバイスコントローラは、データ用と制御用のいくつかのレジスタを持つ
    * 各デバイスコントローラに対して、OSはそのI/O機器用のデバイスドライバを持つ
    * デバイスドライバは、デバイスコントローラのレジスタの読み書きを通して、機器を制御する
* CPUは、番地(アドレス)を指定して、デバイスへのデータの読み書きする
* アドレス空間は以下の2種類がある
    * I/OマップドI/O
        * アドレス空間=I/O空間
        * 物理メモリ空間とは別のデバイスのI/O空間に割り当てられたポートに対して、CPUのI/O命令を実行してアクセスする
        * ポート(port)とは論理的な通信の接続点
    * メモリマップドI/O(現在主流)
        * アドレス空間=メモリ空間
        * I/Oもメモリの一部として扱い、メモリ空間の番地を割り当てる
        * 通常のメモリアクセス命令でアクセスする
* CPUとデバイスは、制御信号線、データバス、アドレスバスで接続されている
* メモリマップドI/O(あるプロセスが大量のデータを転送する場合の例)
    * プロセスは転送用のシステムコールを呼ぶと、カーネルモードに移行し、システムコール中でデバイスドライバを開始する
    * デバイスドライバはメモリ中の送信用メモリに転送データを書き、デバイスコントローラのコントロールレジスタにI/O機器への転送開始命令を書き込んで、システムコール終了
    * I/O機器のデバイスコントローラは(計算機本体のCPUを使わずに)バスの利用権を獲得し、メモリからデバイスのバッファにデータを取り込む
    * 終了後、デバイスドライバを(割り込みにて)起動(カーネルモードに移行)
    * デバイスドライバは次のデータを送信用のメモリに上書きし、デバイスコントローラのコントロールレジスタにI/O機器への転送開始命令を書き込みシステムコール終了
    * これの繰り返し
* I/Oの終了のチェック方法
    * 割り込み
        * I/O機器が終了を割り込みでCPUに知らせる
        * 割り込み処理プログラムが起動
        * 終了報告がある
    * ポーリング
        * CPUがI/O機器の状態を定期的にチェックする
        * I/Oの状態bitをチェックする
        * 終了を問い合わせる


* 以下のコマンドで、ioportのポートアドレスがわかる

```
$ cat /proc/ioports
0000-0cf7 : PCI Bus 0000:00
  0000-001f : dma1
  0020-0021 : pic1
  0040-0043 : timer0
  0050-0053 : timer1
  0060-0060 : keyboard
  0064-0064 : keyboard
  ...
```

* 以下のコマンドで、iomemのアドレスがわかる

```
cat /proc/iomem
00000000-00000fff : reserved
00001000-0009d7ff : System RAM
0009d800-0009ffff : reserved
000a0000-000bffff : PCI Bus 0000:00
000c0000-000ce5ff : Video ROM
000d0000-000d3fff : PCI Bus 0000:00
000d4000-000d7fff : PCI Bus 0000:00
000d8000-000dbfff : PCI Bus 0000:00
000dc000-000dffff : PCI Bus 0000:00
000e0000-000fffff : reserved
```

* lspciでそのデバイスのioports、iomem、IRQ番号などを確認できる
```
$ lspci -v
...
00:19.0 Ethernet controller: Intel Corporation Ethernet Connection (2) I218-V
        DeviceName:  Onboard LAN
        Subsystem: ASUSTeK Computer Inc. Ethernet Connection (2) I218-V
        Flags: bus master, fast devsel, latency 0, IRQ 26
        Memory at f7100000 (32-bit, non-prefetchable) [size=128K]
        Memory at f7138000 (32-bit, non-prefetchable) [size=4K]
        I/O ports at f040 [size=32]
        Capabilities: <access denied>
        Kernel driver in use: e1000e
        Kernel modules: e1000e
```


## ハードウェア情報を調べる
```
$ sudo lshw
owner-all-series
    description: Desktop Computer
    product: All Series (All)
    vendor: ASUS
    version: System Version
    serial: System Serial Number
    width: 64 bits
    capabilities: smbios-2.8 dmi-2.7 vsyscall32
    configuration: administrator_password=disabled boot=normal chassis=desktop family=ASUS MB frontpanel_password=disabled keyboard_password=disabled power-on_password=disabled sku=All uuid=6000AC1B-DAD7-DD11-928F-08626634CC08
  *-core
       description: Motherboard
       product: H97I-PLUS
       vendor: ASUSTeK COMPUTER INC.
       physical id: 0
       version: Rev X.0x
...
```

```
$ sudo lshw -short
sudo lshw -short
H/W path         Device       Class          Description
========================================================
                              system         All Series (All)
/0                            bus            H97I-PLUS
/0/0                          memory         64KiB BIOS
/0/3c                         memory         16GiB System Memory
/0/3c/0                       memory         8GiB DIMM DDR3 Synchronous 1333 MHz (0.8 ns)
/0/3c/1                       memory         8GiB DIMM DDR3 Synchronous 1333 MHz (0.8 ns)
/0/47                         processor      Intel(R) Pentium(R) CPU G3258 @ 3.20GHz
/0/47/48                      memory         128KiB L1 cache
/0/47/49                      memory         512KiB L2 cache
...
```

```
$ sudo fdisk -l
Disk /dev/ram0: 64 MiB, 67108864 bytes, 131072 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes


Disk /dev/ram1: 64 MiB, 67108864 bytes, 131072 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
...
```

```
$ sudo hdparm -i /dev/sda1

/dev/sda1:

 Model=TOSHIBA THNSNJ256GCSU, FwRev=JURA0101, SerialNo=359S10DDT7SW
 Config={ Fixed }
 RawCHS=16383/16/63, TrkSize=0, SectSize=0, ECCbytes=0
 BuffType=unknown, BuffSize=unknown, MaxMultSect=16, MultSect=off
 CurCHS=16383/16/63, CurSects=16514064, LBA=yes, LBAsects=500118192
 IORDY=on/off, tPIO={min:120,w/IORDY:120}, tDMA={min:120,rec:120}
 PIO modes:  pio0 pio3 pio4
 DMA modes:  mdma0 mdma1 mdma2
 UDMA modes: udma0 udma1 udma2 udma3 udma4 *udma5
 AdvancedPM=yes: unknown setting WriteCache=enabled
 Drive conforms to: Unspecified:  ATA/ATAPI-3,4,5,6,7

 * signifies the current active mode
```


## smartctl
* インストール
```
$ sudo yum install smartmontools
```

* デバイス情報を見る
```
$ sudo smartctl -i /dev/sda1
smartctl 6.5 2016-01-24 r4214 [x86_64-linux-4.4.0-59-generic] (local build)
Copyright (C) 2002-16, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Device Model:     TOSHIBA THNSNJ256GCSU
Serial Number:    359S10DDT7SW
LU WWN Device Id: 5 00080d 9103488e2
Firmware Version: JURA0101
User Capacity:    256,060,514,304 bytes [256 GB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    Solid State Device
Form Factor:      2.5 inches
Device is:        Not in smartctl database [for details use: -P showall]
ATA Version is:   ACS-2 (minor revision not indicated)
SATA Version is:  SATA 3.1, 6.0 Gb/s (current: 6.0 Gb/s)
Local Time is:    Sat Jan 27 23:05:14 2018 JST
SMART support is: Available - device has SMART capability.
SMART support is: Enabled
```

* デバイスのテストを行う
```
$ sudo /usr/sbin/smartctl -t short /dev/sda1
smartctl 6.5 2016-01-24 r4214 [x86_64-linux-4.4.0-59-generic] (local build)
Copyright (C) 2002-16, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF OFFLINE IMMEDIATE AND SELF-TEST SECTION ===
Sending command: "Execute SMART Short self-test routine immediately in off-line mode".
Drive command "Execute SMART Short self-test routine immediately in off-line mode" successful.
Testing has begun.
Please wait 2 minutes for test to complete.
Test will complete after Sat Jan 27 23:19:36 2018

Use smartctl -X to abort test.


$ sudo /usr/sbin/smartctl -l selftest /dev/sda
smartctl 6.5 2016-01-24 r4214 [x86_64-linux-4.4.0-59-generic] (local build)
Copyright (C) 2002-16, Bruce Allen, Christian Franke, www.smartmontools.org


$ sudo /usr/sbin/smartctl -l selftest /dev/sda
smartctl 6.5 2016-01-24 r4214 [x86_64-linux-4.4.0-59-generic] (local build)
Copyright (C) 2002-16, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF READ SMART DATA SECTION ===
SMART Self-test log structure revision number 1
Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
# 1  Short offline       Completed without error       00%      4758         -
```

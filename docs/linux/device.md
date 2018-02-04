# デバイス


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
        * アドレス空間=メモリ空間+I/O空間
        * 物理メモリ空間とは別のI/O空間に割り当てられたポートに対して、CPUのI/O命令を実行してアクセスする
    * メモリマップドI/O
        * アドレス空間=メモリ空間
        * I/Oもメモリの一部として扱い、メモリ空間の番地を割り当てる
        * 通常のメモリアクセス命令でアクセスする
* CPUとデバイスは、リード信号線、ライト信号線、データバス、アドレスバスで接続されている
* CPUがデバイスからデータを読み込む場合
    * CPUはアドレスバスでアクセスしたいデバイスの番地を指定しておき、リード信号を有効にする
    * アドレスバスで指定されている番地につながれているデバイスがデータバスにその内容を置く
    * CPUはリード信号の立ち上がりタイミングでデータバスの内容を取り込む
* CPUがデバイスにデータを書き込む場合
    * CPUはアドレスバスでアクセスしたいデバイスの番地を指定しておき、データバスに書き込みたい内容を置き、ライト信号を有効にする
    * アドレスバスで指定されている番地につながれているデバイスは、ライト信号の立ち上がりでデータバスにその内容をデバイスに取り込む

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

* 以下のコマンドで、iomemのアドレス範囲がわかる

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


$ lshw
```
sudo lshw -short
H/W path        Device           Class          Description
===========================================================
                                 system         All Series (All)
/0                               bus            H97I-PLUS
/0/0                             memory         64KiB BIOS
/0/3c                            memory         16GiB System Memory
/0/3c/0                          memory         8GiB DIMM DDR3 Synchronous 1333 MHz (0.8 ns)
/0/3c/1                          memory         8GiB DIMM DDR3 Synchronous 1333 MHz (0.8 ns)
/0/47                            processor      Intel(R) Pentium(R) CPU G3258 @ 3.20GHz
/0/47/48                         memory         128KiB L1 cache
/0/47/49                         memory         512KiB L2 cache
/0/47/4a                         memory         3MiB L3 cache
/0/100                           bridge         4th Gen Core Processor DRAM Controller
/0/100/1                         bridge         Xeon E3-1200 v3/4th Gen Core Processor PCI Express x16 Controller
/0/100/1/0                       display        NVIDIA Corporation
/0/100/1/0.1                     multimedia     NVIDIA Corporation
/0/100/14                        bus            9 Series Chipset Family USB xHCI Controller
/0/100/14/0     usb4             bus            xHCI Host Controller
/0/100/14/1     usb3             bus            xHCI Host Controller
/0/100/16                        communication  9 Series Chipset Family ME Interface #1
/0/100/19       eth0             network        Ethernet Connection (2) I218-V
/0/100/1a                        bus            9 Series Chipset Family USB EHCI Controller #2
/0/100/1a/1     usb1             bus            EHCI Host Controller
/0/100/1a/1/1                    bus            USB hub
/0/100/1b                        multimedia     9 Series Chipset Family HD Audio Controller
/0/100/1d                        bus            9 Series Chipset Family USB EHCI Controller #1
/0/100/1d/1     usb2             bus            EHCI Host Controller
/0/100/1d/1/1                    bus            USB hub
/0/100/1f                        bridge         9 Series Chipset Family H97 Controller
/0/100/1f.2                      storage        9 Series Chipset Family SATA Controller [AHCI Mode]
/0/100/1f.3                      bus            9 Series Chipset Family SMBus Controller
/0/1            scsi0            storage
/0/1/0.0.0      /dev/sda         disk           256GB TOSHIBA THNSNJ25
/0/1/0.0.0/1    /dev/sda1        volume         222GiB EXT4 volume
/0/1/0.0.0/2    /dev/sda2        volume         15GiB Extended partition
/0/1/0.0.0/2/5  /dev/sda5        volume         15GiB Linux swap / Solaris partition
/1                               power          To Be Filled By O.E.M.
/2              tap00163e5111f2  network        Ethernet interface
/3              veth5ff0278      network        Ethernet interface
/4              ns-br-local      network        Ethernet interface
```




lshw -short

sudo fdisk -l

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



## 参考
* http://www.cs.gunma-u.ac.jp/~nakano/OS16/io.html

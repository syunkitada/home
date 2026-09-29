# カーネルの場所と起動時の処理

## カーネルの場所

- Centos7 の/boot
  - config-3.10.0-514.10.2.el7.x86_64
    - Kernel ビルド時のオプション
  - initramfs-3.10.0-514.10.2.el7.x86_64.img
    - 起動時に使われる ram ファイルシステム
    - initrd の代わりに使われる
      - 単独でファイルシステムなので RAM ディスクが不要になった
      - その初期値が cpio で与えられるようになった
  - symvers-3.10.0-514.10.2.el7.x86_64.gz
    - モジュールのビルド時に利用
    - モジュールが組み込み先のカーネルとあったものかをチェックするために利用
      - このチェックする仕組みを「Module versioning」と呼ぶ
    - 仕組み
      - 「シンボルの C 言語のプロトタイプを CRC ハッシュ計算したもの」をカーネルとモジュールのそれぞれに保存しておく
        - シンボルの C 言語のプロトタイプとは、関数の返り値・引数のインターフェイス
        - このインターフェイスで、モジュールが利用できるかを保証できる
      - モジュールの読み込み時に両方が一致しないとモジュールの読み込みを拒否(disagrees about version of symbol [名前])する
      - CRC ハッシュ、シンボル、モジュールを 1 行にまとめたもの「0x013246d0 snd_hdac_ext_bus_parse_capabilities sound/hda/ext/snd-hda-ext-core EXPORT_SYMBOL_GPL」を並べて記述したもの
  - System.map-3.10.0-514.10.2.el7.x86_64
    - メモリ上でシンボル名とアドレスの対応関係を示す
      - シンボル名とは値もしくは関数名である場合が多い
      - シンボル名のアドレスまたはアドレスの示すシンボル名が必要とされるケースにおいて要求される
        - カーネルパニック
        - Linux kernel oops
          - Linux カーネルがエラーログを生成する、正常な動作からの逸脱状態のこと
          - その状態に陥った際に発せられるメッセージを指す場合もある
  - vmlinuz-3.10.0-514.10.2.el7.x86_64
    - カーネル本体
    - 圧縮されてる(z がついてる)
  - initramfs-3.10.0-514.10.2.el7.x86_64kdump.img
  - initramfs-0-rescue-df877a200226bc47d06f26dae0736ec9.img
  - vmlinuz-0-rescue-df877a200226bc47d06f26dae0736ec9
  - grub
  - grub2
- Ubuntu16 の/boot
  - config-4.4.0-59-generic
    - Centos と同上
  - initrd.img-4.4.0-59-generic
    - 起動時に使われる ram ディスク
    - ファイルシステムではなくディスクなので、ここに fs イメージを入れてそれをマウントして使う
  - System.map-4.4.0-59-generic
    - Centos と同上
  - vmlinuz-4.4.0-34-generic
    - Centos と同上
  - abi-4.4.0-59-generic
  - grub/
    - grub.cfg
    - grubenv
- Ubuntu18 の/boot
  - config-5.4.0-74-generic
  - initrd.img-5.4.0-74-generic
  - System.map-5.4.0-74-generic
  - vmlinuz-5.4.0-74-generic
  - grub/
    - grub.cfg
    - grubenv

## BIOSとUEFI

- BIOS（Basic Input/Output System）とUEFI（Unified Extensible Firmware Interface）は、コンピュータのマザーボードのファームウェアの種類です。
- ファームウェアは、PCの起動ディスク、起動方法、周辺機器の認識と管理などを行います。
- BIOSは古い方式で、UEFIは新しい方式です。
- UEFIはBIOSの後継として設計され、より高度な機能を提供します。

## MBRとGPT

- MBR（Master Boot Record）とGPT（GUID Partition Table）は、ディスクのパーティション形式の種類です。
- MBRは、BIOSで利用できる形式です。
  - MBRは古い方式で、最大2TBのディスクサイズをサポートし、最大4つのプライマリパーティションを持つことができます。
  - UEFIでもCSM（Compatibility Support Module）を有効化することでサポートされます。
  - CSMはUEFIの一部で、BIOS互換モードを提供しますが、セキュアブートなどのUEFIの高度な機能は利用できません。
- GPTは、UEFIで利用できる形式です。
  - GPTは新しい方式で、より大きなディスクサイズ（最大9.4ZB）をサポートし、理論上は無制限のパーティションを持つことができます。

### MBR

MBR方式は、以下のディスク構成をとります。

- MBR
  - ディスクの先頭512バイトの領域
  - ブートローダのコード(先頭の446バイト)
    - OSの起動に必要な最低限のコードが含まれます。
  - パーティションテーブル1（次の16バイト）
  - パーティションテーブル2（次の16バイト）
  - パーティションテーブル3（次の16バイト）
  - パーティションテーブル4（次の16バイト）
  - ブートシグネチャ（最後の2バイト）
    - 固定値(0xAA55)が含まれ、MBRが正しいことを示します。
    - このシグネチャがない場合、BIOSはMBRを無効とみなします。
- プライマリパーティション1
- プライマリパーティション2
- プライマリパーティション3
- プライマリパーティション4

プライマリパーティション1には、通常OSがインストールされています。

BIOSは、有効なMBRを検出すると、ブートローダのコードを実行し、ブートローダがOSを起動します。

### GPT

GPTは、以下のディスク構成をとります。

GPTはLogical Block Addressing(LBA)を使ってディスク内の位置を示します。

- LBA 0: Protective MBR
  - ディスクの先頭512バイトの領域
  - GPTをサポートしない古いシステムとの互換性のためにMBRと同様に512バイトのセクターを持ちます。
- LBA 1-33: Primary GPT
  - LBA 1: Primary GPT Header
    - ユーザが使用可能なディスクの範囲、パーティションテーブル内のパーティションエントリ数とサイズを定義している
  - LBA 2-33: Primary Partition Table
    - 最初の16バイトにパーティションの種類を示すGUIDが含まれ、次の8バイトにパーティションの最初のLBA、次の8バイトにパーティションの最後のLBA、次の8バイトにパーティションの属性が含まれます。
- LBA 34-N
  - Partition 1
  - Partition 2
  - Partition X
- LBA N+1(-34): Secondary GPT
  - LBA -33: Secondary Partition Table
    - Primary Partition Tableのバックアップデータ
  - LBA -1: Secondary GPT Header
    - Primary GPT Headerのバックアップデータ

#### EFI System Partition (ESP)

- UEFIシステムで使用されるパーティションで、ブートローダやドライバが格納されます。
- ESPをGUID（C12A7328-F81F-11D2-BA4B-00A0C93EC93B）で識別されます。
- UEFIは、ESPに格納されたブートローダを使用してOSを起動します。
- 参考
  - [UEFI Specification: GUID Partition Table (GPT) Disk Layout](https://uefi.org/specs/UEFI/2.10_A/05_GUID_Partition_Table_Format.html)

## ブートローダの仕組み

- ファームウェア(BIOS or UEFI)が grub をメモリにロードします。
- grub が/boot から vmlinuz と initramfs をメモリにロードします。
  - initramfs は初期起動時に利用する最低限のファイルシステムです。
    - isci など最低限のドライバが入っています。
    - initramfs の中のドライバモジュールを使ってルートファイルシステムが入ったディスクを読みこみます。
      - ルートファイルシステムがネットワーク上にある場合も、このような仕組みでロードできます。
    - 不要になったら、途中で本体のファイルシステムと入れ替えられます。
- カーネルの実行引数: /proc/cmdline
  - BOOT_IMAGE=/boot/vmlinuz-4.4.0-59-generic root=UUID=c5a29305-9548-4405-a4d2-5687eda29d87 ro hugepagesz=1G hugepages=8 default_hugepagesz=1G quiet splash vt.handoff=7
- 参考
  - [initramfs について](https://qiita.com/akachochin/items/d38b538fcabf9ff80531)

## カーネルモジュール

- カーネルの機能をモジュールとして分離したものです。
- モジュールは、/lib/modules/に配置されています。
- カーネルコンパイル時のオプションで標準で組み込こむか、組み込まないか、ユーザに有効・無効をゆだねるか、を指定できます。
  - 組み込むモジュールが多いと、その分ディスク・メモリリソースを使うので、明示的にモジュールを削っていくことが多いです。
- OS実行中にロード・アンロードが可能です。
  - insmod: ロード
  - rmmod: アンロード
  - modprobe: 依存関係を考慮したロード・アンロード
  - lsmod: 現在利用中のモジュール一覧表示
  - modinfo: 情報表示
  - depmod: 依存関係情報の生成
    - /lib/modules/[version]/modules.dep にモジュール間の依存関係が定義されている
      - depmod により自動生成される
    - 各モジュールの未解決のシンボル(関数や変数の名前)を追跡して、依存関係を検出する

## udev とデバイスの自動認識とモジュールの自動ロード

- udev(User Space Device Manager)
  - カーネル 2.6 で導入されたデバイスマネージャー
  - カーネルと連携してホットプラグ機能を提供する
  - udevd というユーザ空間で動作するデーモンが、カーネルからの uevent というイベント通知を受けて、ルールファイルに従ってデバイス関連の処理をする
    - udevadm monitor で uevent をリアルタイムで見れる
- デバイスの自動認識フロー
  - device manager がバスをスキャンしていて、デバイスを挿入すると、それを検知する
  - ドライバのアタッチ、初期化、devtmpfs によりデバイスファイルが作成される
  - ドライバコア部により、ソケット通信の一つである「netlink」プロトコルを使用して、uevent を生成し、udevd に通知する
    - この devtmpfs によるデバイスファイルは、カーネルにより名前が決定される(dev/sda, dev/sdb のように)
    - 任意のデバイスを永続的なデバイス名に紐図けておくには、udevd による名前変更が必要
  - udevd は、デバイスの ID を検知して対応するデバイスモジュールを検索して、modprobe でモジュールをロードする
    - modinfo の alias はデバイスドライバであることを意味しており、このデバイスに対応してると宣言してる
    - 同じデバイスに対応したモジュールが複数あり競合するケースもある
      - 不要なモジュールを blacklist に乗せてロードしないようにするなどの工夫が必要
  - udevd は、uevnet 通知を受けると udev のルールファイル(udev rules)を参照し、その情報とカーネルが提供している sysfs にあるデバイス情報を照らし合わせて、次に実行する動作を決定する
    - udev rules はデバイスの識別と処理をルールの形式で記述した設定ファイルのこと

## lspci

- PCI に接続されたカードの固有情報を取る

```
# そのままたたくと、人が見るように見やすくしたものが表示される
$ lspci
00:00.0 Host bridge: Intel Corporation 4th Gen Core Processor DRAM Controller (rev 06)
00:01.0 PCI bridge: Intel Corporation Xeon E3-1200 v3/4th Gen Core Processor PCI Express x16 Controller (rev 06)
00:02.0 VGA compatible controller: Intel Corporation Xeon E3-1200 v3/4th Gen Core Processor Integrated Graphics Controller (rev 06)
00:03.0 Audio device: Intel Corporation Xeon E3-1200 v3/4th Gen Core Processor HD Audio Controller (rev 06)
00:14.0 USB controller: Intel Corporation 9 Series Chipset Family USB xHCI Controller
00:16.0 Communication controller: Intel Corporation 9 Series Chipset Family ME Interface #1
00:19.0 Ethernet controller: Intel Corporation Ethernet Connection (2) I218-V
00:1a.0 USB controller: Intel Corporation 9 Series Chipset Family USB EHCI Controller #2
00:1b.0 Audio device: Intel Corporation 9 Series Chipset Family HD Audio Controller
00:1d.0 USB controller: Intel Corporation 9 Series Chipset Family USB EHCI Controller #1
00:1f.0 ISA bridge: Intel Corporation 9 Series Chipset Family H97 Controller
00:1f.2 SATA controller: Intel Corporation 9 Series Chipset Family SATA Controller [AHCI Mode]
00:1f.3 SMBus: Intel Corporation 9 Series Chipset Family SMBus Controller

# プログラムが読むのは以下のようなデータ
# バスのタイプ、ベンダID、デバイスIDが含まれてる
$ lscpi -n
00:00.0 0600: 8086:0c00 (rev 06)
00:01.0 0604: 8086:0c01 (rev 06)
00:02.0 0300: 8086:0402 (rev 06)
00:03.0 0403: 8086:0c0c (rev 06)
00:14.0 0c03: 8086:8cb1
00:16.0 0780: 8086:8cba
00:19.0 0200: 8086:15a1
00:1a.0 0c03: 8086:8cad
00:1b.0 0403: 8086:8ca0
00:1d.0 0c03: 8086:8ca6
00:1f.0 0601: 8086:8cc6
00:1f.2 0106: 8086:8c82
00:1f.3 0c05: 8086:8ca2
```

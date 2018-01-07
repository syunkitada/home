# Kernel

* perf_tools: http://www.brendangregg.com/Perf/linux_perf_tools_full.png
* Kernel Map: http://makelinux.net/kernel_map/
* Kernel Source(github tovals) : https://github.com/torvalds/linux
* アーカイブ: https://www.kernel.org/
* [linuxカーネルで学ぶＣ言語のマクロ](http://qiita.com/satoru_takeuchi/items/3769a644f7113f2c8040)
* [システムコールとLinuxカーネルのソース](http://www.coins.tsukuba.ac.jp/~yas/coins/os2-2012/2012-12-04/)
* https://kernelnewbies.org/LinuxVersions

## ディレクトリ構造(kernel 4.10.8)
* arch/
    * アーキテクチャ固有のカーネルコードが含まれている
    * 割り込み処理はほとんどすべてプロセッサ固有のものなので、この配下にある
        * arch/x86/kernel/irq.c
* include/
    * カーネルコードをビルドするのに必要なインクルードファイルが大量に含まれている
* init/
    * カーネルの初期化コードが含まれている、カーネルの動作の仕組みはここから。
* mm/
    * メモリ管理(memory management)コードが含まれている。
    * アーキテクチャ固有のメモリ管理コードは、arch/i386/mm/fault.c といった/arch/*/mmディレクトリ以下にある
    * ページフォルト処理コードはmm/memory.c
    * メモリマッピングとページキャッシュのコードはmm/filemap.c
* drivers/
    * システム上のデバイスドライバ（device drivers)
    * /block: ブロックデバイスドライバ
    * /char: ttyやシリアルポート、マウスなどのキャラクタベースのデバイスがある
    * /cdrom: CD-ROMのコード
    * /pci: PCI仮想ドライバのコード(システム全体の定義はinclude/linux/pci.h にある)
    * /scsi: SCSIのコード
    * /net: ネットワークデバイスドライバが見つかる場所
    * /sound: サウンドカードドライバが見つかる場所
* ipc/
    * カーネルのプロセス間通信(inter-process communications)に関するコードが含まれている
    * 共有メモリは、ipc/shm.c
    * セマフォはipc/sem.c
* fs/
    * ファイルシステム(file system)
    * /xfs, /ext4 などサポートするファイルシステムごとに分かれている
* kernel/
    * 主要なカーネルコードが置かれている。
    * アーキテクチャ固有のカーネルコードは arch/*/kernelにある
    * スケジューラはkernel/sched
    * forkはkernel/fork.c
* net/
    * ネットワーク
    * その大部分のincludeファイルはinclude/netにある
    * net/socker.c
    * net/ipv4
* block/
* certs/
* crypto/
* firmware/
* lib/
    * カーネルのライブラリ
    * アーキテクチャ固有のライブラリは、arch/*/libで見つけることができる
* samples/
* scripts/
    * カーネルを設定するときに使用されるスクリプト（awk, tkなど）
* security/
* sound/
* tools/
* usr/
* virt/
    * kvm/
    * lib/

# Kernel

- perf_tools: http://www.brendangregg.com/Perf/linux_perf_tools_full.png
- Kernel Map: http://makelinux.net/kernel_map/
- Kernel Source(github tovals) : https://github.com/torvalds/linux
- アーカイブ: https://www.kernel.org/
- [linux カーネルで学ぶＣ言語のマクロ](http://qiita.com/satoru_takeuchi/items/3769a644f7113f2c8040)
- [システムコールと Linux カーネルのソース](http://www.coins.tsukuba.ac.jp/~yas/coins/os2-2012/2012-12-04/)
- https://kernelnewbies.org/LinuxVersions

## ディレクトリ構造(kernel 4.10.8)

- arch/
  - アーキテクチャ固有のカーネルコードが含まれている
  - 割り込み処理はほとんどすべてプロセッサ固有のものなので、この配下にある
    - arch/x86/kernel/irq.c
- include/
  - カーネルコードをビルドするのに必要なインクルードファイルが大量に含まれている
- init/
  - カーネルの初期化コードが含まれている、カーネルの動作の仕組みはここから。
- mm/
  - メモリ管理(memory management)コードが含まれている。
  - アーキテクチャ固有のメモリ管理コードは、arch/i386/mm/fault.c といった/arch/\*/mm ディレクトリ以下にある
  - ページフォルト処理コードは mm/memory.c
  - メモリマッピングとページキャッシュのコードは mm/filemap.c
- drivers/
  - システム上のデバイスドライバ（device drivers)
  - /block: ブロックデバイスドライバ
  - /char: tty やシリアルポート、マウスなどのキャラクタベースのデバイスがある
  - /cdrom: CD-ROM のコード
  - /pci: PCI 仮想ドライバのコード(システム全体の定義は include/linux/pci.h にある)
  - /scsi: SCSI のコード
  - /net: ネットワークデバイスドライバが見つかる場所
  - /sound: サウンドカードドライバが見つかる場所
- ipc/
  - カーネルのプロセス間通信(inter-process communications)に関するコードが含まれている
  - 共有メモリは、ipc/shm.c
  - セマフォは ipc/sem.c
- fs/
  - ファイルシステム(file system)
  - /xfs, /ext4 などサポートするファイルシステムごとに分かれている
- kernel/
  - 主要なカーネルコードが置かれている。
  - アーキテクチャ固有のカーネルコードは arch/\*/kernel にある
  - スケジューラは kernel/sched
  - fork は kernel/fork.c
- net/
  - ネットワーク
  - その大部分の include ファイルは include/net にある
  - net/socker.c
  - net/ipv4
- block/
- certs/
- crypto/
- firmware/
- lib/
  - カーネルのライブラリ
  - アーキテクチャ固有のライブラリは、arch/\*/lib で見つけることができる
- samples/
- scripts/
  - カーネルを設定するときに使用されるスクリプト（awk, tk など）
- security/
- sound/
- tools/
- usr/
- virt/
  - kvm/
  - lib/

wget https://vault.centos.org/7.9.2009/updates/Source/SPackages/kernel-3.10.0-1160.25.1.el7.src.rpm
mv kernel-3.10.0-1160.25.1.el7.src.rpm kernel-3.10.0-1160.25.1/
rpm2cpio kernel-3.10.0-1160.25.1.el7.src.rpm| cpio -id
tar xf linux-3.10.0-1160.25.1.el7.tar.xz

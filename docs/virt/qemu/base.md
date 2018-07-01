# 基礎


## QEMU
* Quick Emulator
* CPU、ディスク、NICなどのハードウェアをすべてエミュレートする仮想マシンエミュレータ
    * QEMUはすべてのハードウェアをエミュレート(完全仮想化)できるのが、これは処理が多くなり効率的ではない
    * そのため、CPUはkvmや仮想支援機構を利用してCPU上で仮想マシンのコードを直接実行したり、ネットワーク処理はカーネルの機能に任せるなど、すべてを仮想化せずに一部エミュレートする(準仮想化)


## CPUのエミュレーション
* リングプロテクション
    * リングプロテクションとは、CPUの特権レベルのことで0～3まである。このレベルによって利用できるCPUの命令が異なる
    * ユーザプロセスはリング3で動き利用できる命令に制限があり、kernelはリング0で動き命令の制限がない
* センシティブ命令
    * CPUの命令には、計算だけでなく、IOなどハードウェアを使う、センシティブ命令がある
    * 仮想マシンでセンシティブ命令が実行された場合、CPUはこれをフックしてQEMUなどのエミュレータがこれを適切にエミュレートする必要がある
* 仮想化支援機構とKVM
    * 従来の仮想マシンは、リング3で動いていた
        * 仮想マシンはあくまでユーザプロセスなので、リング3で動かす必要があった
        * そこで、OSを修正したり、VMM(仮想マシンモニタ)が命令を修正したりしてリング3で動くようにしていた
    * 仮想化支援機構(Intel VT-x AMD AMD-V)
        * CPUで仮想マシン用の実行モードをサポートすることで、仮想マシンのコードがリングプロテクションのもとで実行され、センシティブ命令時にはこれをトラップしてエミュレートできるようにした
        * CPUの実行モードには、通常のリングプロテクションの実行モード(VMX rootモード)のほかに、仮想マシン実行用のモード(VMX nonrootモード)が追加された
        * 仮想マシンのコードが実行されるときは、CPUをVMX nonrootモードに切り替え(VM Enter)、CPUで仮想マシンのコードを直接実行する
            * 仮想マシンのkernelはVMX nonrootモードのリング0で実行され、ユーザプロセスはVMX nonrootモードのリング3で実行される
        * センシティブな命令が実行された場合には、いったんVMX rootモードになって(VM Exit)、kvmがその制御を行う
            * kvmは、ネットワークなどのI/O処理はカーネル空間上で処理が完結させるが、ディスクI/Oなどはkvmでは扱えず、QEMUなどのエミュレータに処理を依頼する
            * kvmが処理を完了すると、VMX nonrootモードに復帰して(VM Enter)、仮想マシンのコードが再び実行される
    * KVM
        * Kernel-based Virtual Machine
        * 仮想化支援機構を使って仮想マシン機能を提供するカーネルモジュール
* VMの実行時間(guest時間)
    * ホスト側からmpstatを実行すると確認できる
        * QEMUがセンシティブ命令などをエミュレートしてる時間がuser時間
        * kernel(kvmなど)の実行時間がsys時間
        * VMX non-rootモードでVMが実行してる時間がguest時間
* VMのsteal time
    * VM側からmpstatを実行すると確認できる
    * VMがプロセスをスケジュールするとき、vcpuにCPU時間を割り当てるが、実際にこれが実行されるのは、ホストがvcpuに実CPUの時間を割り当てられる時である
    * このとき、実際に実行されたcpuの時間と、VMが実行しようとしたvcpuの時間の差分が、steal timeとなる
    * steal timeは、vcpuのmsrレジスタ経由で情報をkvm.koから受け取り計算される
        * msrレジスタは、雑多な処理をするためのレジスタ


## KVM
* /dev/kvm
    * KVMのインターフェイスになる特殊デバイス
    * ioctl()で様々な機能を提供
* 仮想マシン作成の流れ
    * /dev/kvmで仮想マシンを作成すると、kvm-vmファイル記述子が返される
    * kvm-vmを使って、メモリを割り当てる
    * kvm-vmを使って、vcpuをつくると、kvm-vcpuというファイル記述子が返され、1つのvcpuごとにvcpuスレッド作成して管理する
    * kvm-vcpuを使って、vcpuのレジスタ(pcなど)に値をセットする
    * kvm-vcpuを使って、センシティブ命令(I/O)発生時のハンドラをセットする
    * kvm-vcpuを使って、vcpuをスタートする
    * keyboard入力などの割り込みを発生させる場合は、kvm-vmを使って、kvm-vmが適切なvcpuに割り込みを入れる
        * ioctl(kvm-vm, KVM_IRQ_LINE_STATUS, 割り込み番号, {{irq=11, status=1}, ...)

```
$ sudo lsof -p 8988 | grep kvm
qemu-syst 8988 root   12u      CHR             10,232         0t0      425 /dev/kvm
qemu-syst 8988 root   13u  a_inode               0,11           0     7994 kvm-vm
qemu-syst 8988 root   18u  a_inode               0,11           0     7994 kvm-vcpu
qemu-syst 8988 root   19u  a_inode               0,11           0     7994 kvm-vcpu
```


## 仮想マシンのメモリ管理
* VMでもOSがページテーブルを管理しており、仮想アドレスを物理アドレスに変換している
* しかし、VMの物理アドレスというのは、QEMUで管理している仮想メモリ空間である実際のメモリアドレスとは異なるため、VMの物理アドレスをホストの物理アドレスに変換する仕組みが必要である
* シャドウページング
    * ホストはシャドウページテーブルという仮想アドレスと物理アドレスを変換できるページテーブルを作る
    * これとVMのページテーブルを同期させることで、VMからのメモリアクセスを可能にする
    * しかし、メモリの読み書きにいちいち同期をとる必要があるパフォーマンスがよくない
* EPT(Extended Page Table: Intel)、NPT(Nested Page Table: AMD)
    * EPTはMMUの拡張機能で、VM物理アドレスをホスト物理アドレスに変換する機能をプロセッサレベルで提供する
        * EPTはVM物理アドレス(GPA)からホスト物理アドレス(HPA)への変換を行う4段のページテーブル
        * 仕組みは通常のページテーブル機構とほぼ同じで、TLBも使うし、ページサイズが大きくなればページウォーク数も減る
    * まだテーブルにマッピングされていないアドレスへのアクセスが発生した場合EPT Violationが発生しVMExitしてページフォルトが発生する
    * VM物理アドレスと物理アドレスをマッピングした情報はVMCSのEPTP(EPT Pointer)に登録しておき、MMUがこれを使って物理メモリにアクセスする
    * VMが仮想アドレスにアクセスすると、MMUがページテーブルによりVM物理アドレスに変換し、MMUがEPTにより物理アドレスに変換して物理アドレスに変換する
* THPの利用による高速化
    * ホストでTHPを有効にしておくと、QEMUがページを確保する際に2Mのページサイズとなる
    * EPTでのページウォーク数も4から3になり、EPTでのTLBヒット率も上がり、ページテーブルのサイズも節約される
    * THPのデメリット
        * ページサイズを2Mにすると、ページフォルト時のページ初期化に時間がかかる
        * 仮想メモリのサイズが肥大化しやすい(実サイズは肥大化しないから問題ない?)
* Hugetlbfsによる高速化
    * THPが2M固定なのに対して、2Mもしくは1Gのページサイズを割り当てることができる
    * ページサイズを1Gにすれば、EPTでのページウォーク数も4から2になり、EPTでのTLBヒット率も上がり、ページテーブルサイズも節約される
    * THPとの使い分け
        * Hugetlbfsは通常のメモリ空間とは隔離され、スワップアウトできず、ブート時に静的に確保しないといけない
        * 稼働させようとしているVM数とそのメモリ利用量が見積れて、余裕があるならHugetlbfsを使うのが良い
        * そうでないなら、THPのほうがメモリの融通が利くので、THPのほうが良い
* 参考
    * [Red Hat: Transparent Hugepage Support](https://www.linux-kvm.org/images/9/9e/2010-forum-thp.pdf)
        * THPの説明、THPの有効/無効時、EPT有効/無効時のベンチマークが乗ってる


## IOのエミュレーション
1. VM: VMのデバイスへのIOが実行される
2. VM: IOの実行にフックしてVMExitが発生
3. ホスト: アクセス先のデバイス、アクセス幅、アクセス方向、書き込み先、読み込み元などを特定
4. ホスト: デバイスIOのエミュレーション処理を行う
5. ホスト: VMEnterしてゲストを再開させる
6. VM: IO実行の次の命令から実行再開


## eventfd
* パイプをデータを転送するのではなく、イベントの発生を通知するために使うことができる
* イベントの例
    * シグナルの受信
    * 非同期IOの完了
* 送信側: 書き出し側のパイプ記述子経由で1バイトだけ書き出すことでイベントの発生を通知する
* 受信側: 読み込み側のパイプ記述子をreadかpoll/selectして、待ち、書き込みがあると起床して1バイト読んで捨てる
* eventfdシステムコール
    * パイプをイベントを通知するという目的に特化したファイルオブジェクトを作成するシステムコール
    * ファイルオブジェクトの中に64bitの整数値(N)を一つ保持できる
    * EFS_SEMAPHOREを指定しなかった場合の動作
    * 通知側: writeシステムコールを呼び出すとNを増やす
    * 受信側: readシステムコールを呼び出したときN>0だとNを一つ減らしてリターン、N == 0だとwaitキューにならび、Nが増えるのを待つ
* qemuも

```
$ sudo lsof -p 8988 | grep eventfd
qemu-syst 8988 root    6u  a_inode               0,11          0     7994 [eventfd]
qemu-syst 8988 root    8u  a_inode               0,11          0     7994 [eventfd]
qemu-syst 8988 root    9u  a_inode               0,11          0     7994 [eventfd]
qemu-syst 8988 root   14u  a_inode               0,11          0     7994 [eventfd]
qemu-syst 8988 root   15u  a_inode               0,11          0     7994 [eventfd]
qemu-syst 8988 root   22u  a_inode               0,11          0     7994 [eventfd]
qemu-syst 8988 root   23u  a_inode               0,11          0     7994 [eventfd]
qemu-syst 8988 root   24u  a_inode               0,11          0     7994 [eventfd]
qemu-syst 8988 root   25u  a_inode               0,11          0     7994 [eventfd]
```



## virtio
* VMとホストで共有できるリングバッファを所持しており、ここに適切に情報を詰めることで、ゲストホスト間でデータを転送する
    * 例えば、コントロール用、TX用、RX用のリングバッファがあればNICみたいな動作もできる
* virtioはvirtデバイスを提供しており、これがNIC、ブロックデバイスなどのIO形のPCIデバイスとしてゲストOSから認識され、virtioドライバを介してアクセスされる
* I/OするデータがVMとホスト双方で共有で見えているので、データ受け渡しの際にvmexit、vmenterが不要になる
* evnetfd(irqfd, ioeventfd)を使って、vitioスレッドが割り込みや、イベント通知を受け取る
* VMにはvitioドライバが、NICやディスクのIOデバイスのドライバとして扱われる
* irqfd
    * eventfdを使って、vmexitさずにホストからVMへ割り込みを行うための機構
        * eventfdの一端をkvm.koとする
        * 割り込みの種類ごとのirqfdで割り込みを通知する
        * ホストが、write(irqfd, ...)で書き込み、vCPUが割り込まれる
* ioeventfd
    * eventfdを使って、vmexitせずにゲストからOutput命令を受信するための機構
    * IO先ごとのioeventfdでセンシティブ命令の実行を通知する
    * vmexitしない

* 参考
    * [KVM irqfd and ioeventfd](http://blog.allenx.org/2015/07/05/kvm-irqfd-and-ioeventfd)
    * [irqfd patch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=721eecbf4fe995ca94a9edec0c9843b1cc0eaaf3)
    * [ioeventfd](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=d34e6b175e61821026893ec5298cc8e7558df43a)

```
$ lspci
00:00.0 Host bridge: Intel Corporation 440FX - 82441FX PMC [Natoma] (rev 02)
00:01.0 ISA bridge: Intel Corporation 82371SB PIIX3 ISA [Natoma/Triton II]
00:01.1 IDE interface: Intel Corporation 82371SB PIIX3 IDE [Natoma/Triton II]
00:01.2 USB controller: Intel Corporation 82371SB PIIX3 USB [Natoma/Triton II] (rev 01)
00:01.3 Bridge: Intel Corporation 82371AB/EB/MB PIIX4 ACPI (rev 03)
00:02.0 Ethernet controller: Red Hat, Inc Virtio network device
00:03.0 Unclassified device [00ff]: Red Hat, Inc Virtio memory balloon


$ cat /proc/interrupts  | grep virtio
 11:          1          0   IO-APIC-fasteoi   uhci_hcd:usb1, virtio1
 24:          0          0   PCI-MSI-edge      virtio0-config
 25:         19       4690   PCI-MSI-edge      virtio0-input.0
 26:          1          0   PCI-MSI-edge      virtio0-output.0
```

ゲストがホストにデータを転送してほしい場合、
ゲストはIOポートを使ってエミュレータ(vitio server)をキック
ホスト リングバッファにデータを入れる
ホストがゲストの割り込みハンドラ(IRQ、MSI-X)をキック


## ネットワークIOのエミュレーション
* vhost-net
    * 昔は、ネットワークデバイスもvirtio-serverを用いてパケットの入出力を行っていた
    * しかし、virtio-serverを通してパケット処理するのは無駄なので(ユーザ空間の処理が入る)、カーネルのvhost-netモジュールによってホスト・ゲストのパケット入出力を制御するようになった
    * NICドライバ -> bridge -> tapドライバ -> vhost-net -> kvm -> 割り込み -> virtioドライバ -> VMのネットワークスタック
    * zero copy
        * 
* LinuxBridge
    * Linuxに標準でついてるブリッジ
    * 機能自体はただのL2で動作するソフトウェアブリッジ
* OpenvSwitch
    * openflowに準拠したブリッジ
    * L2のブリッジ機能に加え、フロー制御やQOS制御ができる
* PCIパススルー
    * PCIデバイスをゲストOSに直接見せて利用する
* SR-IOV
    * NICが仮想NIC(VF: Virtual Function)を提供し、これをゲストOSに直接見せて利用する
* DPDK+OVS
    * vhost-netとovsがlinux socket(vhost-net=client, ovs=server)でつながるため、ovsが落ちるとvhost-netはつなぎなおしてくれない
        * 2.6系以上で導入されたovs=clientモードにすると、ovsがつなぎなおせるようになる
    * 処理フロー
        * NICにパケットが到着(リングバッファに保存)
        * NICがメモリにパケットを書き込む(ハードウェア割り込みは入らない)
        * PMD(Poll Mode Driver)がメモリを定期的に取得し、パケットをDPDKを介して参照渡しする
        * OVSがパケットをルーティングし、宛先のVMのvhost-userに私、vcpuに割り込む
        * VMもネットワークスタック


## 参考
* https://lwn.net/Articles/658511/
* [Linux KVMのコードを追いかけてみよう] (http://www.slideshare.net/ozax86/linux-kvm?qid=fb99f565-8ae4-44d3-9b58-8d8487197566&v=&b=&from_search=26)
* [ハイパーバイザの作り方](http://syuu1228.github.io/howto_implement_hypervisor/)
* [KVMの中身](http://rkx1209.hatenablog.com/entry/2016/01/01/101456)
* [Asynchronous page fault解析](http://d.hatena.ne.jp/kvm/20110702/1309604602)

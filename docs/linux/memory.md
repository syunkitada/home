# メモリ


## ページ/VSS/RSS/PageFault/デマンドページング/SegmentationFault
* Linuxでは、メモリを「ページ」と呼ばれる単位で管理している
* Linuxでは基本的に4Kバイトのページサイズを使用しており、4Kバイト単位でメモリページをプロセスに割り当てている
    * プロセスは、メモリが必要になるとOSにmmapを発行し、仮想アドレス(VSS)の使い方（処理方法）を指定する
    * それを受けてOSのメモリ管理機構(以降MM)は新たな仮想アドレス域をプロセスに割り当てる
    * この仮想アドレスにプロセスがアクセスすると、まだページが存在しない場合(初めてアクセスしたときなど)、PageFaultという例外が発生する
    * OSは、ユーザプログラムのアクセス先を調べて、mmapによって得た仮想アドレス息の場合には先ほどのmmapの指定に従ってメモリを割り当てる
    * この実際に割り当てられた物理アドレスがRSSとなる
    * このような実際にメモリーが必要になった際に動的にメモリーを割り当てる方法を「デマンドページング」という
* SegmentationFault
    * プロセスが仮想アドレスにアクセスしたとき、アクセス先を調べた際に、mmapによって得た仮想アドレスでなかった場合、SegmentationFaultという例外が発生し、OSはプロセスにシグナル(SIGSEGV)を送信する
    * このような状態は、OS側では対応できないので、プロセス側にその後の処理を決めてもらう、たいていのプロセスはこれを受け取ると終了する


## file mapとanon
* VSZ, RSSに含まれるメモリーは、file map域とanonymous域に大別されます
* file map域はファイルの内容をメモリに張り付けた領域
    * プログラムや共有ライブラリ、データファイルなどをメモリー張り付ける際に使用
* anonymouse域はファイルとは無関係の領域
    * ヒープ(mallocで得られるメモリー）やスタックに使います


## numa_map
* numa_mapによりプロセスのメモリーマップ状態を詳しく確認できる
* cat自体のnuma_mapを確認してみる
    * file=... がfile_map域、そうでないのがanonymous域
    * mapped=, anon= はページフォルトの発生によりマップされたページ数を表している
    * file_mapなのにanonがカウントされてる個所は、ファイルの中身をanonymous域にコピーしてから、マッピングしていることを表している
        * ファイルを読むだけなら、ファイルをメモリにマップして読めばいい
        * しかし、プライベートの書き込みを行う場合は、そのまま書き込むとファイルを変更してしまうので、いったんanonymous域にコピーしてからコピー先に書き込む
        * このような、「書き込み時にコピーする」ような仕組みをCopy On Write(COW)と呼ぶ
            * COWの仕組みはメモリに限らずファイルシステムにおけるスナップショットや仮想マシンイメージ(qcow2など)にも利用されている
``` bash
$ cat /proc/self/numa_maps
00400000 default file=/usr/bin/cat mapped=7 N0=7 kernelpagesize_kB=4
0060b000 default file=/usr/bin/cat anon=1 dirty=1 N0=1 kernelpagesize_kB=4
0060c000 default file=/usr/bin/cat anon=1 dirty=1 N0=1 kernelpagesize_kB=4
0145f000 default heap anon=3 dirty=3 N0=3 kernelpagesize_kB=4
7f25e17da000 default file=/usr/lib/locale/locale-archive mapped=12 mapmax=7 N0=12 kernelpagesize_kB=4
7f25e7d03000 default file=/usr/lib64/libc-2.17.so mapped=83 mapmax=27 N0=83 kernelpagesize_kB=4
7f25e7eb9000 default file=/usr/lib64/libc-2.17.so
7f25e80b9000 default file=/usr/lib64/libc-2.17.so anon=4 dirty=4 N0=4 kernelpagesize_kB=4
7f25e80bd000 default file=/usr/lib64/libc-2.17.so anon=2 dirty=2 N0=2 kernelpagesize_kB=4
7f25e80bf000 default anon=3 dirty=3 N0=3 kernelpagesize_kB=4
7f25e80c4000 default file=/usr/lib64/ld-2.17.so mapped=27 mapmax=26 N0=27 kernelpagesize_kB=4
7f25e82da000 default anon=3 dirty=3 N0=3 kernelpagesize_kB=4
7f25e82e2000 default anon=1 dirty=1 N0=1 kernelpagesize_kB=4
7f25e82e3000 default file=/usr/lib64/ld-2.17.so anon=1 dirty=1 N0=1 kernelpagesize_kB=4
7f25e82e4000 default file=/usr/lib64/ld-2.17.so anon=1 dirty=1 N0=1 kernelpagesize_kB=4
7f25e82e5000 default anon=1 dirty=1 N0=1 kernelpagesize_kB=4
7ffca3575000 default stack anon=3 dirty=3 N0=3 kernelpagesize_kB=4
...
```


## reclaim処理(メモリ回収)
* アプリケーションやカーネルはメモリが必要になると、メモリの割り当てをMMに要求する
* 未使用のメモリが十分にあれば、MMはそこからメモリを割り当てる
* メモリが不十分な場合は、使用中のメモリを回収して割り当てようとする
* メモリーの回収とは使用中のメモリページを一つ一つ調べて、可能な場合にはそれを未使用の状態に戻す処理のこと。これをreclaim(回収)処理という
* MMは、2種類のreclaim処理を行う
    * background reclaim
        * バックグラウンドで動き、kswapdというカーネルデーモンが、この処理を実行する
        * kswapdは「Low」(低)「High」という2つの閾値をもっていて未使用メモリーの量がLowを下回ると起動し、Highを上回るまでreclaim処理を続ける
    * direct reclaim
        * メモリーの割り当て要求の発行元に、セルフサービスでメモリー回収を行うように指示する
        * そして、メモリーの割り当て要求を出したスレッドがそのまま、reclaim処理を実施してメモリーを回収し、割り当てを試みます
        * background reclaimでは間に合わない場合があるので、用意されている


## reclaim処理(メモリ回収)の流れ
* Linuxでは割り当て可能なページが足りなくなってくるとrecliaim処理を実行する
* reclaim処理は利用中のページリストをスキャンし、メモリ回収が可能か否かの判断する
    * MMがアクセス履歴を調査し、ページが"最近"使われたように見える場合には回収しない仕組みになっている
    * メモリー獲得の勢いが強いとreclaim処理の実施サイクルが詰まって判定が頻繁に行われるようになる
    * その結果、"最近"という時間の長さがより短くなります。
* メモリー回収方法は、ページがfileなのか、anonなのか、あるいはカーネル(slab)なのか、ページの内容によって異なる
* ページがfileの場合
    * ファイルキャッシュとして使われている場合は、そのページをキャッシュの管理構造から外すことによってメモリを回収する
    * 場合によっては、キャッシュの内容をハードディスク（ＨＤＤ）に書き出す必要がある、その場合はIO処理が終わるのを待ってから回収する
* ページがanonの場合
    * その内容をswapに書き込むことによって追い出す(swap in)
    * 追い出した後にデータが必要になった際は、swapの内容を読みこむ(swap out)
* ページがslabの場合
    * slabと呼ばれるカーネルがメモリ上に作るオブジェクトの一部も回収の対象となる
    * メモリ上のオブジェクトがどこからも参照されない状態にであれば回収する
    * また、何らかのキャッシュとして動作しているオブジェクトは、各自のアルゴリズムによって管理されており、必要に応じて回収処理が動作する
* 回収処理の流れ
    1. anonは最初、Activeリストに追加される
    2. fileは基本的には、最初はInactiveリストに追加される
    3. reclaim処理でInactiveリストがスキャンされた際、ページがまだ使われてそうならActiveリストにいれる、そうでなければ回収する
    4. reclaim処理でAcriveリストがスキャンされた際、ページがまだ使われそうならリスト末尾に戻し、そうでなければInactiveリストに入れる
* reclaim処理が走ると遅くなる場合
    * 回収可能なメモリがほとんどなかったり、メモリー回収時にディスクへの書き込みが必要となり処理に時間がかかったりすることもある
    * reclaim処理に時間がかかると、メモリ獲得処理で遅延が発生するのみならず、kswapdによってCPU負荷も増大する
    * このような状態を「メモリ不足」と呼ぶことが多い
* reclaim処理から除外されるページ
    * 以下のページはUnevictableリストに追加され、reclaim処理の対象外となる
        * ramfs が所有するページ
        * 共有メモリロックのメモリリージョンにマッピングされているページ
        * VM_LOCKED フラグがセットされたメモリリージョンにマッピングされているページ
    * また、mlock()というシステムコールでメモリーを固定するできる
        * これはMlockedリストに追加される


## メモリ不足を確認したり、予兆を把握するにはどうすればよいか？
* /proc/meminfoで状況を把握
    * MemTotal: 実際に搭載されているDIMMの容量より少し少ない値になる(BIOSが使用する分や、メモリー管理が起動する前に使われた分など、OSのメモリー管理下にないメモリーが存在するため)
    * MemFree: 未使用メモリ量、kswapdはこの量を監視して動作する
    * Buffers: 一時的にI/Oと紐づいている量
    * Cached: ファイルキャッシュ量(メモリー不足時にswapに追い出すべきtmpfsなどのページも含まれている)
    * SwapCached: スワップのキャッシュ
        * Inactive(anon)、Active(anon)
    * Active(anon) + Inactive(anon): anonのメモリ量、追い出し先はswap
        * swap freeがないと追い出せないので注意
    * Active(file) + Inactive(file): fileのメモリ量、追い出し先はswap以外
    * Slab: slabの合計
        * カーネルメモリのうちslabという定型のメモリアロケータを使うもの
        * Active, Inactiveには合算されないので、これはこれで見る必要がある
    * SReclaimable: slabの中で、回収可能なメモリ
    * SUnreclaim: slabの中で、回収不可なめもり

* メモリ不足かどうかの判断基準
    * swap in/outが頻発は、性能が大きく低下するのでこれは避けなければならない
    * しかし、anonをswap域に追い出してもアクセスが生じなければ、性能への影響はない
    * ファイルキャッシュについても捨てると性能が大きく低下する場合もあるし、そうでないこともある
    * この辺は、ケースバイケースだが、基本的にはanonは考慮せずにファイルキャッシュ分を空きメモリと捉えてよい
        * 体感的な空きメモリ = MemFree + (Inactive(file) + Active(file) + Sreclaimable) * 0.7-0.9(係数はシステムに依存)
    * 単純なメモリー使用量で判断でき場合は、直近のメモリ量以外の統計情報（IO量やアプリケーションのレイテンシ、kswapdの稼働時間など）を加味して判断するとよい


## メモリの自動監視
* メモリの自動監視向けのインターフェイス[vmpressure]がカーネル3.10以降含まれている
* reclaim処理が回収した量/reclaim処理がスキャンした量の比を計算し、直近のメモリー回収にかかったコストがどの程度なのかを監視プログラム（デーモン)に通知する
* この数値が下がるとメモリの使用状況が悪化したと判断し、カーネルから監視デーモンに通知を行います。
* 通知を受けた監視デーモンはアプリケーションにメモリを解散させたり、強制終了させたり、ネットワークデータのキャッシュを破棄したりして、未使用メモリ領域を増やそうとします
* 仮想マシンと連携してバルーニングする（ある仮想マシンからメモリを強制的に解放する)ことも考えられます。


## ライトバック
* ファイルキャッシュについては、ディスクに書き戻してから回収する
* このディスクに書き戻す処理をライトバックと呼ぶ
* ライトバックのアルゴリズムや設定がアプリケーション性能に大きく影響する
* ファイルキャッシュとライトバック
    * データをCPUの近く（高速にアクセスできる場所）に置くことを「キャッシュする」という
    * キャッシュにデータがあるとread()はディスクアクセスを回避できる
    * 書き込み時、write()はキャッシュに書き、キャッシュからディスクへ適宜ライトバックされる
        * キャッシュ上のデータを改変した場合、それをストレージに反映させる処理が必要になる（これをライトバックと呼ぶ）
        * キャッシュ上で改変されたためにストレージにライトバックする必要があるものを「ダーティーなキャッシュ」と呼ぶ
        * ライトバックしなくてよいものを「クリーンなキャッシュ」と呼ぶ
* Linuxのライトバックでは、プロセスによるキャッシュへの書き込み速度とカーネルによるストレージへの書き込み速度を観測し、その結果をもとにプロセスによるキャッシュへの書き込み速度やライトバック頻度を調整している
    * 書き込み速度を調整するわけ
        * 空きメモリーができるだけキャッシュとして有効に使われつつ、かつメモリー獲得処理の邪魔にならないように、うまくコントロールする必要がある
        * メモリ獲得時に未使用のメモリが少ないと、ファイルキャッシュの追い出しが必要になることがあります
        * そして、キャッシュの追い出しをするには、キャッシュの情報がストレージに反映されている状態（クリーンな状態）であることが必要
* ライトバックの問題点
    * ライトバック自体の処理にメモリが必要なこと
    * ストレージへのI/O発行にメモリーが必要、NFSなどではネットワーク通信にメモリが必要
    * クリーンなページ、つまりすぐにReclaim処理ができるページを安定した量確保しておくことは、メモリ獲得処理が安定して動作することにつながる
    * メモリがダーティなものばかりになると、I/Oを特に行っていないプロセスまで、I/Oを発行しているプロセスの影響を受けがちになる
        * このような状態になると、I/Oをしていないプロセスでもメモリ獲得時のReclaim処理でライトバックのためのI/O待ちで遅延することがある
* ライトバック速度を調整するための設定値
    * background_dirty_raito
        * ライトバックを行うカーネルスレッド「flusher」を起動するしきい値
        * システムの「回収可能なメモリー」に対して、ダーティーなキャッシュの比率がbackground_dirty_raitoを超えた場合にカーネルスレッドを起動する
        * カーネルスレッドの起動タイミングは、この数値が小さいと早めに、大きいと遅めになる
    * dirty_raito
        * システム上のダーティメモリ量を制限する閾値
        * 回収可能なメモリに対して、ダーティなキャッシュの比率がこの値を超えないように、write()を行うプログラムの速度を調整する
        * このdirty raitoの挙動はカーネル3.2から大きく変更された
            * カーネル3.1以前の動作はwrite()発行時にダーティ量とdirty_raitoを比較し、dirty_raitoを上回っている場合はwrite()をしばらく止めて寝かせる
                * 一定のところまでは好きなだけ書かせておいて一定値まで到達したらいきなり（ひょっとしたら長時間）寝ることになる
            * 3.2以降は、ダーティの量が増加するにしたがってこまめにwaitを入れ、write()の速度をコントロールするようになっている
                * これにより従来よりもwrite0を行うアプリケーションが「長く寝る」ことが少なくなっている
            * 3.1以前は閾値にぶつかったところで、メモリ管理から直接ライトバック処理を呼び出す処理が動作し、これが効率的なI/Oを阻害する要因になっていた
            * 3.2以降は、この処理が取り除かれて、I/Oは基本的にflusherスレッドが行うため、従来よりも効率的にI/Oを行えるようになった
        * タスクごとにコントロール
            * dirty raitoにはタスクごとのコントロールやブロックデバイスごとの設定項目もある
                * /var/logのあるブロックデバイスのdirty raito制限を緩和し、遅くてdirtyがたまりがちなUSBドライブのdirty raitoを下げるといった設定が可能
                * これらのチューニングでダーティ・ライトバック量を制御することでメモリ獲得コストや一度に出るI/Oの量を下げてシステムの安定性を高められる可能性がある


## アウトオブメモリー
* メモリーを十分に回収できず、MMが要求されたメモリを割り当てられないような状態をOOM(Out Of Memory)と呼ぶ
    * reclaim処理で解放できるメモリ容量には限界がある
* メモリを十分に回収できない状態
    * Anonばかりで追い出せない
        * スワップデバイスがないシステムは、Anonをスワップに追い出せません。
        * このようなシステムで回収可能なメモリはファイルキャッシュに限られる
        * つまりユーザプログラムが大容量のメモリ割り当てを要求すると、ファイルキャッシュを追い出し切った時点で回収可能なメモリがなくなり、OOMに陥る
        * スワップデバイスがあっても、スワップ領域を使い切ってしまうと、OOMになることがある
    * Anonに加えてファイルやカーネルが相当量ある場合でも、I/Oが待ちが長く、ファイルキャッシュがダーティな状態のページばかりになるとOOMが発生することがある
        * dirty_raito を低くするとOOMが生じにくくなるので、性能要件と空きメモリを見ながら適切にチューニングするとよい
    * NUMAによるOOM
        * 最適化の観点から「特定のノードからのみメモリーを割り当てる」という設定を行っていると、(他のノードでメモリが余っていても)ノードのメモリを割り当てられなくてOOMが生じる
    * mlockや共有メモリのロックによってメモリを大量に固定したために、メモリを回収できなくなってOOM
    * ブートパラメータやsysctlによるhugetlbfsの容量設定のミスによって大量のメモリがHugetlbfsに張り付いてしまいOOM
    * fork()を連発してメモリのほとんどがカーネルメモリとして消費されてしまいOOM
    * 共有メモリーを数千ものプロセスから共有したためにページテーブルが多くなってOOM
* OOM状態に陥った際にプロセスを自動的に削除(Kill)してメモリを強制的に開放する仕組みをOOM Killerと呼ぶ
    * 各プロセスのスコアを計算し、最も高いプロセスを選ぶ。
    * スコアは、メモリ使用量（物理メモリー使用量+ページテーブルサイズ+スワップ使用量)が高いと高くなり、
    * これに、係数(oom_score_adj)がついて最終的なスコアとなる
    * oom_score_adjを-1000に設定しておくと、絶対にkillされなくなる
        * sshdなどのデーモンの中には自分でこの値を設定するものがある
* OOM killerではどうにもならない場合
    * 例えば、fork()の連発でOOMになるケースはkillしたとたんに新しいプロセスがfork()されたり、共有メモリのページテーブルに絡むトラブルの場合はプロセスを多少Killしても焼け石に水
* OOM Killerの強制開放後の状況予測が難しいことから、クラスタを組んでる場合には、OOM発生時にOOM Killerをどうさせせずにカーネルパニックを起こすように設定するケースもある
    * 「vm.panic_on_oom」の値を「1」にする
    * OOM Killerで必要なアプリケーションがまともに動作しない状況になる可能性があるなら、システムをカーネルパニックをフェイルオーバーさせたほうがよい


## ページとTLB
* メモリ上のデータ位置はアドレスで示される
    * メモリーモジュール(DIMM)にアクセスする際のアドレスを物理アドレスと呼ぶ
* カーネルは、論理アドレスと物理アドレスの対応表であるページテーブルを作成し、それをCPUに伝える
    * ページサイズはプロセサの仕様で決まる
    * x86-64系では、4Kバイト、2Mバイト、1Gバイトのサイズのページが利用できる
* CPUキャッシュ
    * CPUは、メモリにアクセスする際に、CPUキャッシュにアクセスする
    * キャッシュがヒットすれば、そのまま読む
    * キャッシュがヒットしなければ(ミス)、メモリから読みだしてCPUに供給します
    * また、次回のアクセス時に利用できるように読みだしたデータをCPUキャッシュ保持します
    * キャッシュへのアクセスは物理アドレスでアクセスされる
    * ページテーブルの読み出しでもメモリアクセスが3-4回発生する
        * これがCPUキャッシュにヒットするかどうかも性能に大きく影響する
* TLB(Translation Lookaside Buffer)
    * 論理アドレスと物理アドレスの対応表(1対1のハッシュテーブル)を保持する少量の高速キャッシュメモリ
    * アクセスしようとした論理アドレスがTLBに乗っていれば即座に変換が行われ、CPUキャッシュにアクセスができる
    * TLBにヒットしなかった場合の処理はCPUに依存する
        * TLB例外を発行し、指定した論理アドレスに対する物理アドレスの情報(TLBエントリー）を作成するようにOSに依頼する
        * もしくは、あらかじめOSから渡されたページテーブルをCPUが読み込んで、CPUが自動的にTLBにエントリーを作る
            * x86は後者の方法を採用している
    * TLBのエントリ数が512の場合、ページサイズが4Kバイトなら2Mバイトの空間のアドレス変換表を保持できる
    * 2Mバイトのページなら1Gバイト、1Gバイトのページなら512Gバイトの空間のアドレス変換表をCPUに保持できる
* Linuxカーネルのカーネル域の一部では1Gバイトのページを使っている
    * カーネルは全メモリ域を扱うので1Gバイト以上の連続するアドレスを用いることが多い


## THP(Transparent Huge Page)
* アプリケーションに対してはページサイズを4Kバイトに見せつつ勝手に(x86-64なら)2Mバイトのページサイズのページテーブルに変換するもの
* THPの量は/proc/meminfoに記載されている
    * AnonHugePages:    274432 kB
* ヒープやスタック領域などのAnonに割り当てられる
* THPは連続的に使用する論理アドレスがある場合に2Mバイトのページを割り当てるほか、ばらばらの4Kバイトのページが並んでる場合でも整理、並べ替えを行って2Mバイトのページサイズのページテーブルに変換する
    * カーネルのkhugepagedスレッドが実行時にメモリーを動的に割り当てる
* THPのメリット
    * 2Mのページとなるため、ページテーブルエントリが減り、TLBのヒット率も上がるため、アプリケーションのパフォーマンスが向上する
* THPのデメリット
    * メモリ割り当てが4Kではなく2Mになるため遅い
    * 小さいメモリで十分な場合にも2Mの割り当てとなるため、メモリの無駄遣いとなる場合がある
    * メモリをデフラグするため重い
* ワークロードによってはTHPは無効のほうがよい
    * HadoopやCassandraやデータベースなどでは無効にしているケースが多い
* HugePageを使えるならTHPはいらない
    * HugePageを利用できるならTHPを無効にしても、ページテーブルエントリやTLBのメリットを受けることができる


## ダイレクトI/OとCOW
プロセスがファイルを読み込む際には、ディスクから読みだしたデータがOSの動きによってシステムメモリにキャッシュされます。

しかし、データベースなどのようなディスクへデータ記憶を主眼に置いたアプリケーションの場合は、自らデータのキャッシュ管理を行うので、OSのキャッシュ機構は邪魔な存在です。
アプリケーションのメモリとディスの間で直接データをやり取りする「ダイレクトIO」という仕組みが用意されています

ダイレクトI/Oの処理の流れ
read()はファイルキャッシュにデータがあるかどうかを確認し、もし存在するならキャッシュのデータをユーザのバッファにコピーする
キャッシュに存在しない場合、OSがファイルシステムを経由してその下のブロックデバイスからデータを獲得します。
そして、そのデータをファイルキャッシュに入れた後に、そこからユーザーバッファにコピーします

ダイレクトI/Oの場合、read()ではファイルキャッシュにデータがあるかを確認しない。
単に、ファイルシステムやデバイスにユーザバッファの場所を指定して、そこにデータを読み込みます。
このデータ転送は、基本的にはOSがデバイスにデータ転送先の物理アドレスを教えることによって、行われます。
データ転送がおわるまで、OSはデータ転送先のAnonメモリが解放されたり、スワップアウトされたりしないよう、メモリ監視をする。

COW
プロセスを複製するfork()で使われている
fork()が実行されると、OSはスレッドや利用しているメモリー、オープン中のファイル情報などを複製し、新たなプロセスを生成する。
複製なのでメモリも複製するわけですが、単純にコピーするとfork()の処理時間が長くなっるし、fork()したあと、execve()によって別プログラムを起動する場合にはメモリーをすべて捨てることになるので、全コピーは無駄となる。
メモリーの実態はコピーせずに、fork()時にはページテーブルのみをコピーする。
そして、複数されたプロセス間でメモリを共有します
その後、どちらかのプロセスからメモリへのデータ書き込みが発生した時点でメモリの内容を実際にコピーし、ページテーブルが指す物理アドレスを分離します。

この書き込みの発生を捕まえるために、fork()時にページテーブルをコピーする際、親プロセスと子プロセスともにAnonメモリーをリードオンリーでマップする。
リードオンリーのメモリに対して書き込みが発生すると、CPUからイベントが通知される
OSはその通知を受け、メモリをコピーします
その後、親プロセスと子プロセスともにAnonメモリーを今度はリードライトでマップする。
つまり、fork()時はメモリーをコピーせずに、必要になったときにはじめてページ単位でコピーされる。



ダイレクトIOとCOW
1. プロセスがダイレクトI/Oのreadを発行、それを受けてカーネルがブロックデバイス層に対してデータ転送の実施を依頼
2. プロセスがforkを発行
3. 親プロセスが何らかの理由で、(1)でreadを出していたバッファと同じページに書き込みを実施し、それに伴い、COWでメモリがコピーされる
4. データ転送が完了

3.で親プロセスが書き込みを実施したことにより、新たなページが割り当てられる
つまり、1でread()のデータ転送先になっていたページとは、物理アドレスが異なるページが3において親プロセスに割り当てられる
1で生じたデータ転送は古いページに対して行われるので、子プロセス側のバッファに転送されて、親プロセスはread()が終わったと思ってバッファを見に行っても正しいデータは転送されない
つまり、ダイレクトI/Oをしている間にforkをする場合にはデータの整合性が保証されなくなるので注意が必要

ダイレクトIOでない場合は、この問題は発生しない
プロセスの論理アドレスを利用してデータがコピーされるため、親プロセスの新バッファに正しく読み込まれる


## メモリマイグレーション
* メモリのマッピングは、一度作られた後にずっと固定された状態にあり続けるとは限らない
* 主に次の2つの場合に、最初のマッピング情報を破棄して、仮想アドレスと物理アドレスのマッピングを再構築する
    * メモリーをスワップに送る
        * OSのメモリ不足を解消するために、最近使用されていないメモリを回収する
    * ページを移動する
        * 連続メモリーを作る
            * 処理によっては4Kのページでは足りず、連続したページの物理メモリが必要になるため、メモリの中身を移動して整理し、連続したメモリ域を作り出す
        * メモリをCPUの近くに置く
            * NUMA構成の場合、各CPUの下にメモリ(DIMM)が接続されるため、メモリまでの距離が一定ではない
        * NUMA構成の場合プロセスのCPUとメモリを近くに配置することによって性能が高まる

ページテーブルのエントリ
ページテーブルの各エントリには握手情報が含まれている
    ページが存在するかを示すビット(Present Bit)、ページのマッピング属性を示す数ビットの情報、ページの部地理アドレスを示す数値
64ビットアーキテクチャの場合、物理アドレスは64ビットです
ページサイズは4Kバイトなので、マッピング情報も4Kバイト単位になる、
エントリの下位12ビットをページの情報に、上位52ビットをページの位置情報に使用する

present bit = 1の場合はページが存在するので、CPUアーキテクチャごとに決められたフォーマットで、ページの物理アドレスと属性情報を記載する。
一方、「present bit = 0」は、ページが存在しないことを意味する
その場合は残り63ビットを自由に使ってよい

スワップ情報を示すスワップエントリでは、present bit = 0となり、残りの63ビットにスワップタイプとスワップ位置の情報を書き込んでいます。
ただし、これはCPUアーキテクチャによって規定されているフォーマットというわけではありません。Present Bit = 0のときは、OSの都合でどんな書き方をしてもよい。
Linuxでは、5ビットをスワップタイプに、58ビットをスワップ位置情報に使っている。

全ビットが0の場合は、無効なエントリとして扱う
スワップタイプはもともと、スワップタイプはもともと、スワップデバイスの番号を格納するためのものでした。
しかし、32個(5ビット)もスワップデバイスを付ける人がいないことから、いくつか拡張された使い方に利用されるようになった。
その利用方法の一つがページマイグレーションです。


ページマイグレーションの流れ
1. ページテーブルエントリをマイグレーションエントリに置き換える
    Present Bit = 0になるので、CPUは仮想アドレスに対応する物理メモリがないと判断する
    この状態でユーザプロセスが仮想アドレスにアクセスすると、対応する物理メモリがないのでページフォルトという例外処理が発生する
    ユーザ処理はページマイグレーションが終えるまで待たされる
2. カーネルは別のページにメモリの内容をコピーする
3. 新しいページの情報をページテーブルに書き込む
4. Present Bit = 1に戻してユーザからのアクセスを可能にして完了

ページマイグレーションを利用したデフラグ
連続したページを確保できるように、デフラグする機能がある
以前は、連続したページを確保するために、強制的にメモリをスワップアウトしていた
HugeTLBの利用においても2Mの連続メモリが必要なため、自動デフラグ機能は重要になってくる


NUMA対応のメモリアロケータ
Linuxは、メモリアロケータがメモリをノードごとに分割する
CPUスケジューラもノードを意識して階層構造になっている。
基本的にスレッドにはそのスレッドが動作しているCPUの所属ノード内のメモリを割り当てる
そして、割り当てに失敗した場合にもう片方のノードからメモリを割り当てる
メモリのアクセス速度は、当然同じノード上のメモリ方法が早く、他ノードのメモリアクセスはその倍時間がかかる
このため、NUMA環境では、プロセスとそのメモリ配置がノードごとによるように固定するとよい
これは、numactlというコマンドや、mempolicyというシステムコールで設定できます
また、numadというカーネルデーモンを使うことで、自動配置を調整するような仕組みもある
しかし、動的なページマイグレーションにはペナルティがあるので、できるだけ静的に設定するとよい

reclaim処理もノード単位で行われる
カーネルスレッドのkswapdなどもノード単位で動作する
zone_reclaim_mode を有効にする必要がある


CPUやメモリのハイツを操作する
cpusetは、CPUやメモリ、根とワークなどのリソースをグループ単位に割り当てたりできる「cgroup」の機能の一つです。
プロセスに割り当てたCPUやメモリの配置をユーザが外部から操作できるAPIを備えています。
cpusetは、ファイルシステムとしてマウントして使用します。
cpusetを用いて配置を操作する際は、コントロールファイルと呼ばれるファイルに書き込みます。

```
$ mount
cgroup on /sys/fs/cgroup/systemd type cgroup (rw,nosuid,nodev,noexec,relatime,xattr,release_agent=/lib/systemd/systemd-cgroups-agent,name=systemd)
cgroup on /sys/fs/cgroup/devices type cgroup (rw,nosuid,nodev,noexec,relatime,devices)
cgroup on /sys/fs/cgroup/freezer type cgroup (rw,nosuid,nodev,noexec,relatime,freezer)
cgroup on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,blkio)
cgroup on /sys/fs/cgroup/perf_event type cgroup (rw,nosuid,nodev,noexec,relatime,perf_event,release_agent=/run/cgmanager/agents/cgm-release-agent.perf_event)
cgroup on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,cpuset,clone_children)
cgroup on /sys/fs/cgroup/pids type cgroup (rw,nosuid,nodev,noexec,relatime,pids,release_agent=/run/cgmanager/agents/cgm-release-agent.pids)
cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,cpu,cpuacct)
cgroup on /sys/fs/cgroup/hugetlb type cgroup (rw,nosuid,nodev,noexec,relatime,hugetlb,release_agent=/run/cgmanager/agents/cgm-release-agent.hugetlb)
cgroup on /sys/fs/cgroup/net_cls,net_prio type cgroup (rw,nosuid,nodev,noexec,relatime,net_cls,net_prio)
cgroup on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,memory)

$ ls /sys/fs/cgroup/cpuset
cgroup.clone_children  cpuset.cpu_exclusive   cpuset.effective_mems  cpuset.memory_migrate           cpuset.memory_spread_page  cpuset.sched_load_balance        notify_on_release
cgroup.procs           cpuset.cpus            cpuset.mem_exclusive   cpuset.memory_pressure          cpuset.memory_spread_slab  cpuset.sched_relax_domain_level  release_agent
cgroup.sane_behavior   cpuset.effective_cpus  cpuset.mem_hardwall    cpuset.memory_pressure_enabled  cpuset.mems                machine/                         tasks
```

あるプロセスのCPUやメモリの配置を操作するとします。
まずは、cpusetの操作用ディレクトリを作る、すると、ディレクトリ内に自動的に各種コントロールファイルがつくられる
/sys/fs/cgroup/cpuset/Group_A

このうち、「cgroup.procs」というファイルに操作するプロセスのIDを書き込む
cat /sys/fs/cgroup/cpuset/machine/kubernetes-centos7-1.libvirt-qemu/vcpu0/cgroup.procs
10607

そして、cpuset.cpusに利用するCPU, cpuset.memsにノード(今後このノードからリソースの割り当てを得る)を設定できる
cat /sys/fs/cgroup/cpuset/machine/kubernetes-centos7-1.libvirt-qemu/vcpu0/cpuset.cpus
0-1
cat /sys/fs/cgroup/cpuset/machine/kubernetes-centos7-1.libvirt-qemu/vcpu0/cpuset.mems
0

メモリの割り当ては少し注意が必要で、値を書き込んで設定を変更しても、その効果は新たに割り当てられるノードにしか恩恵は受けられない
すでに使用中のメモリを移動させるには「cpuset.memory_migrate」に1を設定しておく
これにより、cpuset.memsに値を書き込んだ際に必要に応じてメモリマイグレーションが発生し、使用中のメモリがすべて指定ノードに移動される

このcpusetを利用してメモリ配置を自動調整するサービスがnumadです。
numadは、プロセスのCPUやメモリーを必要に応じて適切に配置なおしてくれるデーモン。
numadは一定時間ごと(15秒ごと)にシステムをスキャンし、次の2種類のシステム情報を入手する
* ノードごとのCPUアイドル率
    * /proc/stats から取得
    * 各CPUごとのフィールド4番目にシステム起動時からの通算アイドル時間が10ミリ秒単位で表示される
    * これを繰り返し取得し、前回スキャン時からのアイドル時間の差分を差分を計算する
    * この結果を経過時間で割ると、直近のCPUのアイドル率が求まる
    * これをCPU_FREEとする
* ノードごとの空きメモリ情報
    * /sys/devices/system/node/node0/meminfo
    * このMemFreeの値をMEM_FREEとする
* CPU_FREE * MEM_FREE の値をノードが持つリソースの余裕を評価する値として利用する
* 全プロセスをスキャンして/proc/プロセスID/statファイルから「CPU使用量」および「メモリ使用量」を入手する
    * これらを掛け合わせてスコアを出し、高い順にソートする
リストの上位から順に、各プロセスのノード配置を変更するかどうか判定していく
判定では、/proc/[pid]/numa_mapsを開き、各プロセスがどのノードでどれだけのメモリを利用しているのかチェックする
得られた（プロセスの)各ノードでのメモリー使用量をMEM_FREEの値に加味し、
magnitude=CPU_FREE*MEM_FREE
という式を使って各ノードのリソース空き状態を評価する
このmagnitudeという値をもとに、利用するノードの優先度を決める
現状の利用ノードが優先度の高いノードとは異なっていた場合、プロセスのCPUやメモリを再配置する
再配置は、cpuset.memory_migrateに1を設定したうえで、cpuset.cpusファイルにCPU、cpuset.memsにノードの値をセットすることで行われる
プロセスを1つ移動したら、同じプロセスを何度も行ったり来たりさせないように最低5秒待ってから次回のスキャンを行います


# 自動NUMAバランス
2012-2013にかけて、カーネル側で自動的にアプリケーションのメモリアクセスを追跡し、CPUとメモリの配置をチューニング（バランス)する仕組みが開発された
CPUの移動とスケジューラ
プロセスが実際にメモリが割り当てられるのは、プロセスが仮想メモリに実際にアクセスしたときです。
この時、OSはメモリアクセスを実施したCPUにもとっも近いノードからメモリを割り当てる。
しかし、スケジューラの都合によってプロセスが動作するCPUが別のNUMAノードに代わると、メモリが遠くなってしまう。

プロセススケジューラはシステム全体を見ながら空いているCPUにプロセスを移動しようと、常に監視を続けています。
移動の際、現在のCPUが属すNUMAノード内の別のCPUを優先するよう配慮します。

カーネルによるNUMA自動バランシングでは、メモリマイグレーションを利用して、自動的にCPUの位置とメモリの位置を調整します。
カーネルのスケジューラにプロセスとメモリの位置を追跡し、必要に応じてメモリを移動したり、（プロセスがスケジュールされるべきNUMAノードを覚えておいて）チャンスがあれば元の位置にプロセスを戻したりする機能が付加されました。
これは自動で有効化されているため、無効化する場合は numa_balancing=disableをセットする


アクセス時のメモリ移動
プロセスにメモリページが割り当てられた際、ページの位置がプロセスのページテーブルに登録される。
メモリアクセスの追跡に置いてもページテーブルが利用される。
numa_balancingが有効の場合、一定時間ごとにプロセスのメモリをスキャンして、メモリマッピングを一時的に引きはがす処理が行われます
このとき、ページマイグレーションの場合と同じようにページテーブルのPresentBitを0にし、ページテーブルには「NUMA情報収集のために、一時的にページを外した」ことを記録しておきます。
こうしておくと、プロセスがメモリをアクセスした際に、PageFaultが発生し、OSがメモリアクセスを補足できる。
PageFaultが起こると、カーネルはプロセスが現在動作しているCPUと引きはがしたページ位置(NUMAノード)を比較し、
それらが異なるNUMAノードに置かれている場合にはページマイグレーションを発生させて、メモリをCPUのあるNUMAノードに移動させます。


プロセスのアクセス追跡
ページマイグレーションにはオーバヘッドがあるので、頻繁に行うわけにはいかない。
そこで、カーネルは、どのNUAノードでPageFaultが起こったかを記録した統計データを集めて活用しています。
この統計情報には、ページが単一のスレッドからアクセスされたのか、複数のスレッドから共有アクセスされたのか、ページマイグレーションが発生したのかなどが記録される
numa_balancingの統計情報は/proc/vmstat で参照できる
```
$ cat /proc/vmstat | grep numa
numa_hit 6400786
numa_miss 0
numa_foreign 0
numa_interleave 23049
numa_local 6400786
numa_other 0
numa_pte_updates 0             # numa_balancingが変えたPate Table Entryの数
numa_huge_pte_updates 0        # numa_balancingが変えたHuge Pate Table Entryの数
numa_hint_faults 0             # 上記PTEへのPageFaultの総数
numa_hint_faults_local 0       # numa_hint_faultsのうち、元のメモリのノード位置とページフォルト時のノード位置が同じだった数
numa_pages_migrated 0          # ページマイグレーションの成功数
```
スケジューラは統計データをもとに主に二つの判断を下す。
一つはページスキャンの頻度です。
例えば、複数のスレッドから共有アクセスされるページの場合、それらスレッドが複数のNUMAノードに分散していると、最適なノードを決められない。
このようなページが多い場合は、スキャンの頻度を下げる。
逆に、ページが単一のスレッドからアクセスされメモリマイグレーションが多く発生している場合はスキャンの頻度を高めて、CPUとメモリのバランスを改善できる

もう一つは、プロセスが動作するCPUの決定に使われる。
CPUがすべて空いていれば、メモリに近いCPUでスレッドを走らせればよいが、そうでない場合は適切なCPUを割り出す
場合によっては、プロセスを最適なCPUに移動する


## キャッシュと複数CPU
CPUコアが増えた場合、複数のCPUコアから同時にアクセスされる可能性のあるメモリ領域の取り扱い。
PER CPUメモリの仕組みを見てみる

CPUキャッシュとライン
CPUからメモリへのアクセスを高速化するために、CPUにはキャッシュが搭載されている。
CPUの仕組みにも依存するが、あるCPUが数バイトのメモリを読み出すと、まずメモリからキャッシュにひと固まりのデータ(ラインと呼ぶ)がロードされる。
そして、CPUがキャッシュから必要なデータを読み出す。
書き込む際は、いったんキャッシュを収め(write-allocate)、キャッシュラインに変更を加えた後、適切なタイミングでメモリに書き戻します(write-back)

キャッシュ操作はライン単位で実施される。
キャッシュラインのサイズは、Intel CPUでは64バイトと考えてよいようです。


CPU0とCPU1の二つのCPUがあるとする
CPU0がデータXに書き込んだ後、CPU1が同じデータXに書き込んだ場合を考えてみる。
まず、CPU0がデータXを含むラインをメモリから読みだしてキャッシュに収め、キャッシュラインに改変を加える。
この後、CPU1が同じデータXに改変を加えるわでだが、メモリ上のデータXはCPU0のキャッシュラインにあるデータXよりも古くなっている。

そこで、CPU0のキャッシュラインをCPU1に移します。
その際、CPU0側のキャッシュを消して、CPU1がデータXを独占的に書き換えられるようにします。
なお、CPU0とCPU1がいずれもデータXを読み出すだけで書き換えない場合は、CPU0およびCPU1のキャッシュに同じラインが乗っていることもあります。

False Sharing
前述のように、米Intel社製CPUではラインが64バイトもあるので、同じデータへのアクセスではなく、近くにあるデータにアクセスした場合にもキャッシュ間でのライン移動が生じる可能性があります。
例えば、longが8バイトだとして、その一次元配列を定義し、その並列に各CPUが異なるインデックスをアクセスした場合、8CPU(64/8)分のデータが同じラインに乗ることになる。
各CPUがそれぞれのインデクスのデータを書き換えるたびに、ラインの移動が発生し動作が極めて遅くなる。
このような状況をFalse Sharingと呼ぶ。

キャッシュへのアクセスを最適化するため、Linuxカーネルは各CPU固有のデータ域を作成する「PER CPUメモリ」という機能を持っている
PER CPUメモリはついとなるCPU自身からしか書き換えないという"お約束"のもとに利用できるカーネルメモリです。
各CPUを占有することにより、フォールすシェアリングを回避できるとともに、メモリアクセスに置いてロックなどの排他制御が不要になる
使い方は、まず次のようなオブジェクトを作成する。
```
x = aloc_percpu
```
this_cpu(x)で各CPUのローカルデータに、またper_cpu(x, cpu)で各CPU固有のデータ息にアクセスする。
各CPUのデータは、実際にはCPUごとにまとまった個別のメモリ域に配置され、this_cpu()などによってアドレス位置を計算した上でアクセスされる

* PER_CPUカウンタ
各CPU固有のメモリ域にカウンタを持たせることで、精度を犠牲にしてキャッシュラインの相次ぐ移動を避けてSMP性能を引き上げる機能です。
```
int counter;
per_cpu int pcp_counter;
```
各CPUはpcp_counterを更新し、その絶対値が閾値以上になったらcounterに反映します。
例えば、1ずつカウントアップするcounterにおいて閾値が16ならcounterへのアクセスを1/16に減らすことができる。
このケースでCPU数が16の場合には、最大で240の誤差がでる。
/procから読み取れるデータの中には、こうした仕組みで算出されてるものもあるので、値が必ずしも正確とは限らない。
CPUが多い場合には、OSが見せる細かい数値の「正確さ」にはこだわらないようにしましょう。


## リソースコントローラ
プロセスに割り当てるCPUやメモリの量、I/Oやネットワーク帯域を、ユーザからの指示を受けて制御する機能を「リソースコントローラ」と呼ぶ。
Linuxカーネルには、プロセス群のリソースを管理する「cgroup」という仕組みが備わっている。

memory cgroup
ユーザプロセスのメモリやファイルキャッシュ、カーネルメモリの一部などを管理できる。
各memory cgroupはカウンタを一つ持っている。そして、ページ獲得要求を受けた際のメモリ獲得制限に、そのカウンタの値を使う。
例えば、memory cgroupのリミットが4Gバイトで、ここに3プロセスが所属していてそれぞれが1Gバイトづつ(合計3Gバイト)利用していたとする。
この場合、あと1Gバイトのメモリは獲得できる。
しかし、1Gバイトを超えて獲得しようとした場合には、このmemory cgroupないで保持しているページ(各プロセスのファイルキャッシュやユーザメモリ)からメモリ回収を試みます。
また、swapも同じmemory cgroupでlimitをかけることができる。
つまり、最大のlimitは、メモリ + swapのトータルとなる。
これは、カーネルのメモリ管理機構が行うスワップアウトに干渉しない。(kwsapdなどのシステム全体をメンテナンスするプルグラムの動作には極力干渉しないようにするため)

memory cgroup単位でのメモリ回収と、システム全体でのメモリ回収が両立するように、memory cgroupを組み込んだ場合のメモリ回収用LRU(Least Recentry Used: 最も長期間使われていないプロックを割り出すアルゴリズム)には工夫が凝らされている。
基本的には、memory cgroup単位にLRUを保持しており、システム全体からメモリ回収を行う場合にあhすべてのmemory cgroupを順番にスキャンする。
memocy cgroupがある場合は、それらを一つづつ調べて、それぞれのLRUから回収するメモリを見つける。
そして、各memory cgroupが持つページ数や直近のアクセス動向をベースに、メモリを回収すべきかを決定する。
memocy cgroupがない場合は、各NUMAノードが持つメモリのLRUリストから回収するメモリを見つける。

カウンタの工夫
memory cgroupメモリ量を数えるカウンタを持っている。
普通に数えると、性能のボトルネックになるので、PER CPUカウンタのような作りになっている。
このため、memory.usageに表示されるメモリ使用量の精度には最大128Kバイトほどの誤差が生じる。
とはいえ、タスクスイッチ時に誤差を解消するようなコードになってるので、あまり気にする必要はない。



## sysctl
* reclaim関連
```
vm.swapiness=1
# 1 でページアウトよりページキャッシュ解放を優先させる

vm.overcommit_memory=2
# 2 でオーバーコミットしないようにする

vm.overcommit_ratio=80
# 仮想メモリ割り当てをメモリサイズ + スワップ領域のサイズ * 80%にする

vm.min_free_kbytes=524288
# デフォルト(動的に算出される)より大きめに設定して余裕をもってページ回収する
# 512MB に設定すると、空きメモリが640MB(low pages)を下回ると kswapd がページ回収を開始し、768MB(high pages)を超えるとやめる
# 空きメモリが 512MB を下回るとプロセスがメモリ要求時に同期でページ回収が実行される(direct reclaim)。

vm.extra_free_kbytes=1048576
# kernel 3.5以降
# low pages、high pages に 1GB 加算し direct reclaim が発生しにくくする
# メモリ使用率監視閾値(アラート)が 90% なら、low pages がメモリの 10%+a くらいにすると良さげ

vm.zone_reclaim_mode = 0
# numaノードごとでkswapdが動作する
```

* dirty関連
```
vm.dirty_background_bytes = 0
vm.dirty_background_ratio = 10
vm.dirty_bytes = 0
vm.dirty_expire_centisecs = 3000
vm.dirty_ratio = 20
vm.dirty_writeback_centisecs = 500
vm.dirtytime_expire_seconds = 43200
```


## vmstat
http://linuxinsight.com/proc_vmstat.html
``` bash
$ vmstat
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 1  0    736 6376312 384324 7006248    0    0     6   263  120  102 10  2 89  0  0

$ vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 2  0    736 6244880 384288 7006204    0    0     6   264  119  101 10  2 89  0  0
 0  0    736 6245036 384288 7006236    0    0     0     0  269  611  1  0 99  0  0
 0  0    736 6245548 384288 7006236    0    0     0     0  304  604  1  0 99  0  0
```



## メモリの情報
/proc/meminfo
/proc/sys/vm/...


## ページ
http://www.coins.tsukuba.ac.jp/~yas/coins/os2-2010/2011-01-11/


## buddy
* 「Buddy システム」は、Linux で使われている外部フラグメンテーションを起こしにくいメモリ割当てアルゴリズム。
* 利用可能なメモリ・ブロックのリストを管理する
* メモリ・ページを「ゾーン」と呼ばれる領域に分割して管理する
* ZONE_DMA: DMAでアクセス可能なページ・フレーム x86では0-16M
* ZONE_NOMAL: DMAではアクセスできないが、カーネルの仮想アドレス空間に常にマップされてる。x86では16M-896M
* NONE_HIGMEM: 普段はカーネルの仮想アドレス空間にマップされていない。使うときにはマップして使い、使い終わったらアンマップする。x86では896Mより大きいところ
* buddyinfoで現在の空き情報が確認できる
``` bash
#                         4K     8k     16k    32k    64k   128k   256k   512k     1M     2M     4M
$ cat /proc/buddyinfo
Node 0, zone      DMA      0      1      1      0      2      1      1      0      1      1      3
Node 0, zone    DMA32    710    596    407    454    362    241     89     14      7      0      0
Node 0, zone   Normal    106    486    327    178    135     56     40      7      4      0      0
```


## pmap -x [PID]
メモリにはfile mapとanonがある
file mapはプログラムファイルや共有ライブラリタの内容を読み込んだメモリ領域
anonymouseはファイルとは無関係の領域で、ヒープ（mallocで得られるメモリ）やスタックに使う
``` bash
$ sudo pmap -x 23572
[sudo] password for owner:
23572:   /usr/bin/qemu-system-x86_64 -name centos7 -S -machine pc-i440fx-trusty,accel=kvm,usb=off -cpu Nehalem,+invpcid,+erms,+fsgsbase,+abm,+rdtscp,+pdpe1gb,+rdrand,+osxsave,+xsave,+tsc-deadline,+movbe,+pcid,+pdcm,+xtpr,+tm2,+est,+vmx,+ds_cpl,+monitor,+dtes64,+pclmuldq,+pbe,+tm,+ht,+ss,+acpi,+ds,+vme -m 12192 -realtime mlock=off -smp 2,sockets=2,cores=1,threads=1 -uuid ab775a1c-10cc-5010-7523-010f517993ed -nographic -no-user-config -nodefaults -chardev socket,id=charmonitor,path=/var/lib/libvirt/qemu/centos7.moni
Address           Kbytes     RSS   Dirty Mode  Mapping
00007fcc32000000 12484608 8425204 8418308 rw---   [ anon ]
00007fcf2c000000    1240     136     100 rw---   [ anon ]
00007fcf2c136000   64296       0       0 -----   [ anon ]
...
00007fcf4a160000    4800    1588       0 r-x-- qemu-system-x86_64
00007fcf4a810000     896      44      44 r---- qemu-system-x86_64
00007fcf4a8f0000     324      24      24 rw--- qemu-system-x86_64
...
```

## hugepage
http://dpdk.org/doc/guides-16.04/sample_app_ug/vhost.html
https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/7/html/Virtualization_Tuning_and_Optimization_Guide/sect-Virtualization_Tuning_Optimization_Guide-Memory-Tuning.html

```
# デフォルトを確認
$ cat /proc/meminfo
AnonHugePages:     81920 kB
HugePages_Total:    2048
HugePages_Free:     2048
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB

# hugepage を1G * 8page 確保
$ sudo vim /etc/default/grub
GRUB_CMDLINE_LINUX="hugepagesz=1G hugepages=8"

$ sudo grub-mkconfig -o /boot/grub/grub.cfg
$ reboot

# 確認
$ cat /proc/meminfo
AnonHugePages:     53248 kB
HugePages_Total:      13
HugePages_Free:       13
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:    1048576 kB

# hugepageサイズ
$ cat /proc/sys/vm/nr_hugepages
13

$ vim /etc/fstab
hugetlbfs   /mnt/huge   hugetlbfs defaults,pagesize=1G 0 0

$ sudo mount -a

# mount確認
# デフォルトで、kvmも/run/hugepages/kvm にhugetlbfsをマウントしてるマウントしてる？
$ mount
hugetlbfs-kvm on /run/hugepages/kvm type hugetlbfs (rw,mode=775,gid=125)
hugetlbfs on /mnt/huge type hugetlbfs (rw,pagesize=1G)

# hugepageをバッキングメモリにして2GのVMを起動すると、hugepageから確保される
$ sudo pmap 5150
5150:   /usr/bin/qemu-system-x86_64 -name centos7 -S -machine pc-i440fx-trusty,accel=kvm,usb=off -cpu Nehalem,+invpcid,+erms,+fsgsbase,+abm,+rdtscp,+pdpe1gb,+rdrand,+osxsave,+xs
ave,+tsc-deadline,+movbe,+pcid,+pdcm,+xtpr,+tm2,+est,+vmx,+ds_cpl,+monitor,+dtes64,+pclmuldq,+pbe,+tm,+ht,+ss,+acpi,+ds,+vme -m 1954 -mem-prealloc -mem-path /run/hugepages/kvm/l
ibvirt/qemu -realtime mlock=off -smp 2,sockets=1,cores=2,threads=1 -uuid 2c28f6ae-5fb4-11e6-95b5-cce1d540d3fa -nographic -no-user-config -nodefaults -chardev socket
00007f8980000000 2097152K rw--- qemu_back_mem.pc.ram.ZedopK (deleted)
00007f8a34000000   1144K rw---   [ anon ]
0

```


## hugetlb



## /proc/[PID]/smaps
```
$ sudo cat /proc/23572/smaps | less
7fcc32000000-7fcf2c000000 rw-p 00000000 00:00 0
Size:           12484608 kB
Rss:             8429404 kB
Pss:             5329099 kB
Shared_Clean:        528 kB
Shared_Dirty:    3487568 kB
Private_Clean:      6388 kB
Private_Dirty:   4934920 kB
Referenced:      8257668 kB
Anonymous:       8429404 kB
AnonHugePages:   1107968 kB
Swap:            1996964 kB
KernelPageSize:        4 kB
MMUPageSize:           4 kB
Locked:                0 kB
VmFlags: rd wr mr mw me dc ac sd hg mg
7

# 2Gなので2ページ分消費された
$ cat /proc/meminfo
HugePages_Total:      13
HugePages_Free:       11
HugePages_Rsvd:        0
HugePages_Surp:        0
```



## kswapd



## malloc()


## kmalloc()


## slub
* カーネルは、メモリの利用効率を高めるために、カーネル空間内のさまざまな メモリ資源を、資源ごとにキャッシュしている領域
* もし、slubのメモリが断片化してしまうとパフォーマンスにも影響が出てくる
* スラブの利用量はslubtopで確認できる

```
Active / Total Objects (% used)    : 1343215 / 1352019 (99.3%)
 Active / Total Slabs (% used)      : 35104 / 35104 (100.0%)
 Active / Total Caches (% used)     : 66 / 98 (67.3%)
 Active / Total Size (% used)       : 193251.77K / 194863.62K (99.2%)
 Minimum / Average / Maximum Object : 0.01K / 0.14K / 15.88K

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
295152 295152 100%    0.10K   7568       39     30272K buffer_head
238770 238620  99%    0.19K  11370       21     45480K dentry
150848 148349  98%    0.06K   2357       64      9428K kmalloc-64
128860 127969  99%    0.02K    758      170      3032K fsnotify_event_holder
125696 124665  99%    0.03K    982      128      3928K kmalloc-32
 98304  97251  98%    0.01K    192      512       768K kmalloc-8
 69003  68498  99%    0.08K   1353       51      5412K selinux_inode_security
 58368  58368 100%    0.02K    228      256       912K kmalloc-16
```

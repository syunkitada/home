# メモリ

## ページ/VSS/RSS/PageFault/デマンドページング/SegmentationFault

- Linux では、メモリを「ページ」と呼ばれる単位で管理している
- Linux では基本的に 4K バイトのページサイズを使用しており、4K バイト単位でメモリページをプロセスに割り当てている
  - プロセスは、メモリが必要になると OS に mmap を発行し、仮想アドレス(VSS)の使い方（処理方法）を指定する
  - それを受けて OS のメモリ管理機構(以降 MM)は新たな仮想アドレス域をプロセスに割り当てる
  - この仮想アドレスにプロセスがアクセスすると、まだページが存在しない場合(初めてアクセスしたときなど)、PageFault という例外が発生する
  - OS は、ユーザプログラムのアクセス先を調べて、mmap によって得た仮想アドレスの場合には先ほどの mmap の指定に従ってメモリを割り当てる
  - この実際に割り当てられた物理アドレスが RSS となる
  - このような実際にメモリーが必要になった際に動的にメモリーを割り当てる方法を「デマンドページング」という
- SegmentationFault
  - プロセスが仮想アドレスにアクセスしたとき、アクセス先を調べた際に、mmap によって得た仮想アドレスでなかった場合、SegmentationFault という例外が発生し、OS はプロセスにシグナル(SIGSEGV)を送信する
  - このような状態は、OS 側では対応できないので、プロセス側にその後の処理を決めてもらう、たいていのプロセスはこれを受け取ると終了する
- CPU キャッシュ
  - CPU は、メモリにアクセスする前に、CPU キャッシュにアクセスする
  - キャッシュがヒットすれば、そのまま読む
  - キャッシュがヒットしなければ(ミス)、メモリから読みだして CPU に供給する
  - また、次回のアクセス時に利用できるように読みだしたデータを CPU キャッシュ保持する
  - キャッシュへのアクセスは物理アドレスでアクセスされる

## 仮想アドレスと物理アドレスとページテーブルと TLB

- ページテーブルは、仮想アドレスの「ページ」を物理アドレスに変換するためのテーブル
  - 変換は、MMU(Memory Management Unit)が行う
    - MMU は CPU の内部にある
- 各プロセスには仮想アドレス空間とページテーブルが存在し、プロセスが実行されるときに、プロセスのページテーブルを CR3 レジスタにセットする
- プロセスが仮想アドレスにアクセスすると、MMU は CR3 レジスタにセットされたページテーブルを使って、仮想アドレスを物理アドレスに変換して物理メモリにアクセスする
- ページテーブルには、そのプロセスのメモリのほかに、kernel のメモリも乗っている
  - ページテーブルには、割り当て情報以外にアクセス権の情報も入ってるので、kernel のメモリはシステムコールなどで kernel モードになっていなければアクセスできない
  - KPTI(Kernel Page-Table Isolation)を有効にした場合は、プロセスのページテーブルと kernel のページテーブルは分離されるようになる
- メモリに関するシステムコールとライブラリ
  - システムコール
    - execve(): メモリ中のプログラムを入れ替え、アドレス空間を作る
    - mmap(): ファイルをメモリにマップする
    - brk(), sbrk(): ヒープメモリを増やす
    - mprotect(): メモリの保護モードを変更する
    - mlock(): メモリをページアウトされないようにする(pinning)
    - munlock(): mlock()で pinning した状態を解除する
  - ライブラリ
    - malloc(): ヒープメモリからメモリを割り当てる(ヒープは、mmap(), brk(), sbrk()で得る)
    - free(): malloc()で割り当てたメモリを開放する
  - その他
    - スタックの自動拡張(許された範囲で(ulimit -s))、自動的にスタックを大きくする
- プログラムは、起動すると仮想メモリ空間を作成し、そこに以下の情報をマッピングする(32bit の例)
  - カーネル空間(0xffffffff-0xc0000000、1G を固定で高い番地から低い番地へ固定で割り当てられる)
  - 引数、環境変数(カーネル空間に続いて、高い番地から低い番地へ固定で割り当てられる)
  - スタック(引数、環境変数の空間に続いて、高い番地から低い番地へ割り当てられ拡張されていく)
    - スタックポインタが指すところ
  - ヒープ(BSS 空間に続いて、低い番地から高い番地へ割り当てられ拡張されていく)
    - スタックとヒープのメモリ空間は連続していないので、互いに拡張できる
  - BSS(データに続いて、低い番地から高い番地へ固定で割り当てられる)
    - 初期値なしの静的変数(OS が勝手に初期化する)
  - データ(プログラムファイルに続いて、低い番地から高い番地へ固定で割り当てられる)
    - 初期値ありの静的変数
  - プログラムファイル(0 番値付近を空けて、低い番地から高い番地へ固定で割り当てられる)
    - 読み込み専用の機械語
    - PC がこの先頭を指し、プログラムが実行される
  - 0 番地(0x00000000)付近はメモリを割り当てないことが一般的
    - 割り込みのエントリポイントになってたりする?
- 仮想アドレス空間の大きさ
  - 32 ビットシステムで、0x00000000-0xffffffff
  - 64 ビットシステムで、0x00000000-0xffffffffffffffff (実際には、 もう少し小さい。0x00ffffffffffff くらい)
- 仮想アドレスから物理アドレスへの変換の仕組み
  - ページサイズを 4KB とする
    - 仮想アドレスは、上位(セグメントセレクタ)と下位(オフセット)からなる
      - 仮想アドレスを論理アドレスと言ったりもする
    - セグメントセレクタは MMU がページテーブルを使って変換し、物理メモリのページを指定するアドレスとして使われる
    - オフセット(1 ページの 4KB)は、変換されずにそのままアドレスを、物理メモリのページ内を指定するオフセットとして使われる
    - 32 ビットシステムの場合は、
      - 上位 20 ビットがページテーブルにより変換され、下位 12 ビットがそのまま使われる
  - ページテーブルは、多段の変換テーブルになっている
  - 32bit の場合
    - 1 ページ(4KB)を 1024 のテーブルにしてこれを 1 エントリ(PTE: Page Table Entry)とし 4MB のエントリを作る
    - PTE を 1024 のテーブル(PDT: Page Directory Table)として 4GB の仮想メモリ空間を扱えるようにしている
  - 64bit の場合
    - 32bit の PDT の上に、PDPT(Page Directory Pointer Table)、PML4(Page Map Level4 Table)が追加されて 256TB の仮想メモリ空間を扱えるようにしている
    - PTE が 1 ページ(4KB)を 512 エントリで管理し(2MB)、PDT が PTE を 512 エントリ管理し(1GB)、PDPT が PDT を 512 エントリ管理し(512GB)、PML4 が PDPT を 512 エントリ管理する(256TB)
  - ページテーブルを参照してページをたどることをページウォークと呼ぶ
  - ページウォークしても物理ページが見つからない場合、ページフォールトを発生し、例外ハンドラが必要な処理を行う
    - 通常は物理ページを割り当てる(デマンドページング)
- TLB
  - Translation Lookaside Buffer: アドレス変換バッファ
    - 仮想アドレスと物理アドレスの変換をページテーブルでやっていては時間がかかるので、一度行ったアドレス変換をキャッシュしている
    - TLB は、仮想アドレスと物理アドレスの 1 対 1 の変換表になっている
  - MMU は、仮想アドレスを受け取ると、それに対応する物理アドレスがあるかを TLB を検索して、物理アドレスがあれば(TLB ヒット)、その物理アドレスでメモリにアクセスする
  - 見つからない場合は(TLB ミス)、ページテーブルを参照してセグメントセレクタを変換し、その結果を TLB に保存する
  - TLB はコンテキストスイッチの際などにクリアされる
  - TLB はキャッシュと同様多層化されており、アクセス速度、容量が異なる
    - Skylake
      - L1
        - ITLB: 4KB (128), 2MB/4MB (8/thread) の 2 種類
        - DTLB: 4KB (64), 2MB/4MB (32), 1GB (4) の 3 種類
      - L2
        - STLB: 4KB と 2MB/4MB の共有 (1536), 1GB (16) の 2 種類
- HugePage
  - Linux では 4KB を超えるページを HugePage と呼ぶ(OS によって SuperPage, LargePage と呼ばれることもある)
  - デフォルトのページサイズは 4KB だが、2M、1G バイトのページサイズも扱うことができる
  - 大きいページサイズを扱うことで、ページウォークの回数が 2M なら 1 段、1G なら 2 段省略できる
  - また、TLB のエントリ数も少なくなるため TLB のヒット率も上がる
  - 参考
    - https://gist.github.com/shino/5d9aac68e7ebf03d4962a4c07c503f7d
    - https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/7/html/Virtualization_Tuning_and_Optimization_Guide/sect-Virtualization_Tuning_Optimization_Guide-Memory-Tuning.html
- THP(Transparent Huge Page)
  - アプリケーションに対してはページサイズを 4K バイトに見せつつ勝手に(x86-64 なら)2M バイトのページサイズのページテーブルに変換するもの
  - THP の量は/proc/meminfo に記載されている
    - AnonHugePages: 274432 kB
  - ヒープやスタック領域などの Anon に割り当てられる
  - THP は連続的に使用する論理アドレスがある場合に 2M バイトのページを割り当てるほか、ばらばらの 4K バイトのページが並んでる場合でも整理、並べ替えを行って 2M バイトのページサイズのページテーブルに変換する
    - カーネルの khugepaged スレッドが実行時にメモリーを動的に割り当てる
  - THP のメリット
    - 2M のページとなるため、ページテーブルエントリが減り、TLB のヒット率も上がるため、アプリケーションのパフォーマンスが向上する
  - THP のデメリット
    - メモリ割り当て速度が 4K ではなく 2M になるため遅い
    - 小さいメモリで十分な場合にも 2M の割り当てとなるため、メモリの無駄遣いとなる場合がある
    - メモリをデフラグするため重い
  - ワークロードによっては THP は無効のほうがよい
    - Hadoop や Cassandra やデータベースなどでは無効にしているケースが多い
  - HugePage を使えるなら THP はいらない
    - HugePage を利用できるなら THP を無効にしても、ページテーブルエントリや TLB のメリットを受けることができる

## file map と anon

- VSZ, RSS に含まれるメモリーは、file map 域と anonymous 域に大別されます
- file map 域はファイルの内容をメモリに張り付けた領域
  - プログラムや共有ライブラリ、データファイルなどをメモリー張り付ける際に使用
- anonymouse 域はファイルとは無関係の領域
  - ヒープ(malloc で得られるメモリー）やスタックに使います

## numa_map

- numa_map によりプロセスのメモリーマップ状態を詳しく確認できる
- cat 自体の numa_map を確認してみる
  - file=... が file_map 域、そうでないのが anonymous 域
  - mapped=, anon= はページフォルトの発生によりマップされたページ数を表している
  - file_map なのに anon がカウントされてる個所は、ファイルの中身を anonymous 域にコピーしてから、マッピングしていることを表している
    - ファイルを読むだけなら、ファイルをメモリにマップして読めばいい
    - しかし、プライベートの書き込みを行う場合は、そのまま書き込むとファイルを変更してしまうので、いったん anonymous 域にコピーしてからコピー先に書き込む
    - このような、「書き込み時にコピーする」ような仕組みを Copy On Write(COW)と呼ぶ
      - COW の仕組みはメモリに限らずファイルシステムにおけるスナップショットや仮想マシンイメージ(qcow2 など)にも利用されている

```bash
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

## reclaim 処理(メモリ回収)

- アプリケーションやカーネルはメモリが必要になると、メモリの割り当てを MM に要求する
- 未使用のメモリが十分にあれば、MM はそこからメモリを割り当てる
- メモリが不十分な場合は、使用中のメモリを回収して割り当てようとする
- メモリの回収とは使用中のメモリページを一つ一つ調べて、可能な場合にはそれを未使用の状態に戻す処理のこと
  - これを reclaim(回収)処理という
- MM は、2 種類の reclaim 処理を行う
  - background reclaim
    - バックグラウンドで動き、kswapd というカーネルデーモンが、この処理を実行する
    - kswapd は「Low」(低)「High」という 2 つの閾値をもっていて未使用メモリーの量が Low を下回ると起動し、High を上回るまで reclaim 処理を続ける
  - direct reclaim
    - メモリーの割り当て要求の発行元に、セルフサービスでメモリー回収を行うように指示する
    - そして、メモリーの割り当て要求を出したスレッドがそのまま、reclaim 処理を実施してメモリーを回収し、割り当てを試みます
      - 当然アプリケーションは reclaim の処理時間分待たされることになるのでパフォーマンス低下の要因となる
    - background reclaim では間に合わない場合があるので、用意されている

## reclaim 処理(メモリ回収)の流れ

- Linux では割り当て可能なページが足りなくなってくると recliaim 処理を実行する
- reclaim 処理は利用中のページリストをスキャンし、メモリ回収が可能か否かの判断する
  - MM がアクセス履歴を調査し、ページが"最近"使われたように見える場合には回収しない仕組みになっている
  - メモリー獲得の勢いが強いと reclaim 処理の実施サイクルが詰まって判定が頻繁に行われるようになる
  - その結果、"最近"という時間の長さがより短くなる
- メモリー回収方法は、ページが file なのか、anon なのか、あるいはカーネル(slab)なのか、ページの内容によって異なる
- ページが file の場合
  - ファイルキャッシュとして使われている場合は、そのページをキャッシュの管理構造から外すことによってメモリを回収する
  - 場合によっては、キャッシュの内容をハードディスク(HDD)に書き出す必要がある、その場合は IO 処理が終わるのを待ってから回収する
- ページが anon の場合
  - その内容を swap に書き込むことによって追い出す(swap in)
  - 追い出した後にデータが必要になった際は、swap の内容を読みこむ(swap out)
- ページが slab の場合
  - slab と呼ばれるカーネルがメモリ上に作るオブジェクトの一部も回収の対象となる
  - メモリ上のオブジェクトがどこからも参照されない状態にであれば回収する
  - また、何らかのキャッシュとして動作しているオブジェクトは、各自のアルゴリズムによって管理されており、必要に応じて回収処理が動作する
- 回収処理の流れ
  1. anon は最初、Active リストに追加される
  2. file は基本的には、最初は Inactive リストに追加される
  3. reclaim 処理で Inactive リストがスキャンされた際、ページがまだ使われてそうなら Active リストにいれる、そうでなければ回収する
  4. reclaim 処理で Active リストがスキャンされた際、ページがまだ使われそうならリスト末尾に戻し、そうでなければ Inactive リストに入れる
- reclaim 処理が走ると遅くなる場合
  - 回収可能なメモリがほとんどなかったり、メモリー回収時にディスクへの書き込みが必要となり処理に時間がかかったりすることもある
  - reclaim 処理に時間がかかると、メモリ獲得処理で遅延が発生するのみならず、kswapd によって CPU 負荷も増大する
  - このような状態を「メモリ不足」と呼ぶことが多い
- reclaim 処理から除外されるページ
  - 以下のページは Unevictable リストに追加され、reclaim 処理の対象外となる
    - ramfs が所有するページ
    - 共有メモリロックのメモリリージョンにマッピングされているページ
    - VM_LOCKED フラグがセットされたメモリリージョンにマッピングされているページ
  - また、mlock()というシステムコールでメモリーを固定するできる
    - これは Mlocked リストに追加される

## メモリ不足を確認したり、予兆を把握するにはどうすればよいか？

- /proc/meminfo で状況を把握
  - MemTotal: 実際に搭載されている DIMM の容量より少し少ない値になる(BIOS が使用する分や、メモリー管理が起動する前に使われた分など、OS のメモリ管理下にないメモリーが存在するため)
  - MemFree: 未使用メモリ量、kswapd はこの量を監視して動作する
  - Buffers: 一時的に I/O と紐づいている量
  - Cached: ファイルキャッシュ量(メモリー不足時に swap に追い出すべき tmpfs などのページも含まれている)
  - SwapCached: スワップのキャッシュ
    - Inactive(anon)、Active(anon)
  - Active(anon) + Inactive(anon): anon のメモリ量、追い出し先は swap
    - swap free がないと追い出せないので注意
  - Active(file) + Inactive(file): file のメモリ量、追い出し先は swap 以外
  - Slab: slab の合計
    - カーネルメモリのうち slab という定型のメモリアロケータを使うもの
    - Active, Inactive には合算されないので、これはこれで見る必要がある
  - SReclaimable: slab の中で、回収可能なメモリ
  - SUnreclaim: slab の中で、回収不可なメモリ
  - CommitLimit: プロセスが確保できるメモリの制限値
  - Commited_AS: プロセスが割り当て要求の総量(使用量ではない)
- メモリ不足かどうかの判断基準
  - swap が利用されていても in/out が頻発していない場合は問題ない
    - anon を swap 域に追い出してもアクセスが生じなければ、性能への影響はない
    - swap in/out が頻発する場合は、性能が大きく低下するのでこれは避けなければならない
  - ファイルキャッシュについても捨てると性能が大きく低下する場合もあるし、そうでないこともある
  - この辺は、ケースバイケースだが、基本的には anon は考慮せずにファイルキャッシュ分を空きメモリと捉えてよい
    - 体感的な空きメモリ = MemFree + (Inactive(file) + Active(file) + Sreclaimable) \* 0.7-0.9(係数はシステムに依存)
  - 単純なメモリー使用量で判断できない場合は、直近のメモリ量以外の統計情報（IO 量やアプリケーションのレイテンシ、kswapd の稼働時間など）を加味して判断するとよい

## メモリの自動監視

- メモリの自動監視向けのインターフェイス[vmpressure]がカーネル 3.10 以降含まれている
- reclaim 処理が回収した量/reclaim 処理がスキャンした量の比を計算し、直近のメモリー回収にかかったコストがどの程度なのかを監視プログラム（デーモン)に通知する
- この数値が下がるとメモリの使用状況が悪化したと判断し、カーネルから監視デーモンに通知を行います。
- 通知を受けた監視デーモンはアプリケーションにメモリを解散させたり、強制終了させたり、ネットワークデータのキャッシュを破棄したりして、未使用メモリ領域を増やそうとします
- 仮想マシンと連携してバルーニングする（ある仮想マシンからメモリを強制的に解放する)ことも考えられる

## ライトバック

- ファイルキャッシュについては、ディスクに書き戻してから回収する
- このディスクに書き戻す処理をライトバックと呼ぶ
- ライトバックのアルゴリズムや設定がアプリケーション性能に大きく影響する
- ファイルキャッシュとライトバック
  - データを CPU の近く（高速にアクセスできる場所）に置くことを「キャッシュする」という
  - キャッシュにデータがあると read()はディスクアクセスを回避できる
  - 書き込み時、write()はキャッシュに書き、キャッシュからディスクへ適宜ライトバックされる
    - キャッシュ上のデータを改変した場合、それをストレージに反映させる処理が必要になる（これをライトバックと呼ぶ）
    - キャッシュ上で改変されたためにストレージにライトバックする必要があるものを「ダーティーなキャッシュ」と呼ぶ
    - ライトバックしなくてよいものを「クリーンなキャッシュ」と呼ぶ
- Linux のライトバックでは、プロセスによるキャッシュへの書き込み速度とカーネルによるストレージへの書き込み速度を観測し、その結果をもとにプロセスによるキャッシュへの書き込み速度やライトバック頻度を調整している
  - 書き込み速度を調整するわけ
    - 空きメモリーができるだけキャッシュとして有効に使われつつ、かつメモリー獲得処理の邪魔にならないように、うまくコントロールする必要がある
    - メモリ獲得時に未使用のメモリが少ないと、ファイルキャッシュの追い出しが必要になることがある
    - そして、キャッシュの追い出しをするには、キャッシュの情報がストレージに反映されている状態（クリーンな状態）であることが必要
- ライトバックの問題点
  - ライトバック自体の処理にメモリが必要なこと
  - ストレージへの I/O 発行にメモリーが必要、NFS などではネットワーク通信にメモリが必要
  - クリーンなページ、つまりすぐに Reclaim 処理ができるページを安定した量確保しておくことは、メモリ獲得処理が安定して動作することにつながる
  - メモリがダーティなものばかりになると、I/O を特に行っていないプロセスまで、I/O を発行しているプロセスの影響を受けがちになる
    - このような状態になると、I/O をしていないプロセスでもメモリ獲得時の Reclaim 処理でライトバックのための I/O 待ちで遅延することがある
- ライトバック速度を調整するための設定値
  - background_dirty_raito
    - ライトバックを行うカーネルスレッド「flusher」を起動するしきい値
    - システムの「回収可能なメモリー」に対して、ダーティーなキャッシュの比率が background_dirty_raito を超えた場合にカーネルスレッドを起動する
    - カーネルスレッドの起動タイミングは、この数値が小さいと早めに、大きいと遅めになる
  - dirty_raito
    - システム上のダーティメモリ量を制限する閾値
    - 回収可能なメモリに対して、ダーティなキャッシュの比率がこの値を超えないように、write()を行うプログラムの速度を調整する
    - この dirty raito の挙動はカーネル 3.2 から大きく変更された
      - カーネル 3.1 以前の動作は write()発行時にダーティ量と dirty_raito を比較し、dirty_raito を上回っている場合は write()をしばらく止めて寝かせる
        - 一定のところまでは好きなだけ書かせておいて一定値まで到達したらいきなり（ひょっとしたら長時間）寝ることになる
      - 3.2 以降は、ダーティの量が増加するにしたがってこまめに wait を入れ、write()の速度をコントロールするようになっている
        - これにより従来よりも write0 を行うアプリケーションが「長く寝る」ことが少なくなっている
      - 3.1 以前は閾値にぶつかったところで、メモリ管理から直接ライトバック処理を呼び出す処理が動作し、これが効率的な I/O を阻害する要因になっていた
      - 3.2 以降は、この処理が取り除かれて、I/O は基本的に flusher スレッドが行うため、従来よりも効率的に I/O を行えるようになった
    - タスクごとにコントロール
      - dirty raito にはタスクごとのコントロールやブロックデバイスごとの設定項目もある
        - /var/log のあるブロックデバイスの dirty raito 制限を緩和し、遅くて dirty がたまりがちな USB ドライブの dirty raito を下げるといった設定が可能
        - これらのチューニングでダーティ・ライトバック量を制御することでメモリ獲得コストや一度に出る I/O の量を下げてシステムの安定性を高められる可能性がある

## アウトオブメモリー

- メモリーを十分に回収できず、MM が要求されたメモリを割り当てられないような状態を OOM(Out Of Memory)と呼ぶ
  - reclaim 処理で解放できるメモリ容量には限界がある
- メモリを十分に回収できない状態
  - Anon ばかりで追い出せない
    - スワップデバイスがないシステムは、Anon をスワップに追い出せない
      - 明示的にスワップを作らない場合はよくある
    - このような場合、回収可能なメモリはファイルキャッシュに限られる
    - つまりユーザプログラムが大容量のメモリ割り当てを要求すると、ファイルキャッシュを追い出し切った時点で回収可能なメモリがなくなり、OOM に陥る
    - スワップデバイスがあっても、スワップ領域を使い切ってしまうと、OOM になることがある
  - Anon に加えてファイルやカーネルが相当量ある場合でも、I/O 待ちが長く、ファイルキャッシュがダーティな状態のページばかりになると OOM が発生することがある
    - dirty_raito を低くすると OOM が生じにくくなるので、性能要件と空きメモリを見ながら適切にチューニングするとよい
  - NUMA による OOM
    - 最適化の観点から「特定のノードからのみメモリーを割り当てる」という設定を行っていると、(他のノードでメモリが余っていても)ノードのメモリを割り当てられなくて OOM が生じる
  - mlock や共有メモリのロックによってメモリを大量に固定したために、メモリを回収できなくなって OOM
  - ブートパラメータや sysctl による hugetlbfs の容量設定のミスによって大量のメモリが Hugetlbfs に張り付いてしまい OOM
  - fork()を連発してメモリのほとんどがカーネルメモリとして消費されてしまい OOM
  - 共有メモリーを数千ものプロセスから共有したためにページテーブルが多くなって OOM
- OOM 状態に陥った際にプロセスを自動的に削除(Kill)してメモリを強制的に開放する仕組みを OOM Killer と呼ぶ
  - 各プロセスのスコアを計算し、最も高いプロセスを選ぶ。
  - スコアは、メモリ使用量（物理メモリー使用量+ページテーブルサイズ+スワップ使用量)が高いと高くなり、
  - これに、係数(oom_score_adj)がついて最終的なスコアとなる
  - oom_score_adj を-1000 に設定しておくと、絶対に kill されなくなる
    - sshd などのデーモンの中には自分でこの値を設定するものがある
- OOM killer ではどうにもならない場合
  - 例えば、fork()の連発で OOM になるケースは kill したとたんに新しいプロセスが fork()されたり、共有メモリのページテーブルに絡むトラブルの場合はプロセスを多少 Kill しても焼け石に水
- OOM Killer の強制開放後の状況予測が難しいことから、クラスタを組んでる場合には、OOM 発生時に OOM Killer をどうさせせずにカーネルパニックを起こすように設定するケースもある
  - 「vm.panic_on_oom」の値を「1」にする
  - OOM Killer で必要なアプリケーションがまともに動作しない状況になる可能性があるなら、システムをカーネルパニックで落としてフェイルオーバーさせたほうがよい

## ダイレクト I/O と COW

- プロセスがファイルを読み込む際に、ディスクから読みだしたデータが OS によってシステムメモリにキャッシュされる
- しかし、データベースなどのようなディスクへデータ記憶を主眼に置いたアプリケーションの場合は、自らデータのキャッシュ管理を行うので、OS のキャッシュ機構を利用しない場合もある
  - アプリケーションのメモリとディスクの間で直接データをやり取りする「ダイレクト IO」という仕組みが用意されています
- ダイレクト I/O の処理の流れ
  - read()はファイルキャッシュにデータがあるかどうかを確認し、もし存在するならキャッシュのデータをユーザのバッファにコピーする
  - キャッシュに存在しない場合、OS がファイルシステムを経由してその下のブロックデバイスからデータを獲得する
  - そして、そのデータをファイルキャッシュに入れた後に、そこからユーザーバッファにコピーする
  - ダイレクト I/O の場合、read()ではファイルキャッシュにデータがあるかを確認しない
  - 単に、ファイルシステムやデバイスにユーザバッファの場所を指定して、そこにデータを読み込む
  - このデータ転送は、基本的には OS がデバイスにデータ転送先の物理アドレスを教えることによって、行われる
  - データ転送がおわるまで、OS はデータ転送先の Anon メモリが解放されたり、スワップアウトされたりしないよう、メモリ監視をする
- COW
  - プロセスを複製する fork()で使われている
  - fork()が実行されると、OS はスレッドや利用しているメモリー、オープン中のファイル情報などを複製し、新たなプロセスを生成する
  - 複製なのでメモリも複製するわけだが、単純にコピーすると fork()の処理時間が長くなるし、fork()したあと、execve()によって別プログラムを起動する場合にはメモリーをすべて捨てることになるので、全コピーは無駄となる
  - メモリーの実態はコピーせずに、fork()時にはページテーブルのみをコピーする
  - そして、複数されたプロセス間でメモリを共有する
  - その後、どちらかのプロセスからメモリへのデータ書き込みが発生した時点でメモリの内容を実際にコピーし、ページテーブルが指す物理アドレスを分離する
  - この書き込みの発生を捕まえるために、fork()時にページテーブルをコピーする際、親プロセスと子プロセスともに Anon メモリーをリードオンリーでマップする
    - リードオンリーのメモリに対して書き込みが発生すると、CPU からイベントが通知される
    - OS はその通知を受け、メモリをコピーします
  - その後、親プロセスと子プロセスともに Anon メモリーを今度はリードライトでマップする
  - つまり、fork()時はメモリーをコピーせずに、必要になったときにはじめてページ単位でコピーされる
- ダイレクト IO と COW
  - 流れ
    1. プロセスがダイレクト I/O の read を発行、それを受けてカーネルがブロックデバイス層に対してデータ転送の実施を依頼
    2. プロセスが fork を発行
    3. 親プロセスが何らかの理由で、(1)で read を出していたバッファと同じページに書き込みを実施し、それに伴い、COW でメモリがコピーされる
    4. データ転送が完了
  - 3.で親プロセスが書き込みを実施したことにより、新たなページが割り当てられる
  - つまり、1 で read()のデータ転送先になっていたページとは、物理アドレスが異なるページが 3 において親プロセスに割り当てられる
  - 1 で生じたデータ転送は古いページに対して行われるので、子プロセス側のバッファに転送されて、親プロセスは read()が終わったと思ってバッファを見に行っても正しいデータは転送されない
  - つまり、ダイレクト I/O をしている間に fork をする場合にはデータの整合性が保証されなくなるので注意が必要
  - ダイレクト IO でない場合は、この問題は発生しない
  - プロセスの論理アドレスを利用してデータがコピーされるため、親プロセスの新バッファに正しく読み込まれる

## メモリマイグレーション

- メモリのマッピングは、一度作られた後にずっと固定された状態にあり続けるとは限らない
- 主に次の 2 つの場合に、最初のマッピング情報を破棄して、仮想アドレスと物理アドレスのマッピングを再構築する
  - メモリーをスワップに送る
    - OS のメモリ不足を解消するために、最近使用されていないメモリを回収する
  - ページを移動する
    - 連続メモリーを作る
      - 処理によっては 4K のページでは足りず、連続したページの物理メモリが必要になるため、メモリの中身を移動して整理し、連続したメモリ域を作り出す
    - メモリを CPU の近くに置く
      - NUMA 構成の場合、各 CPU の下にメモリ(DIMM)が接続されるため、メモリまでの距離が一定ではない
    - NUMA 構成の場合プロセスの CPU とメモリを近くに配置することによって性能が高まる
- ページテーブルのエントリ
  - ページテーブルの各エントリには各種情報が含まれている
  - ページが存在するかを示すビット(Present Bit)、ページのマッピング属性を示す数ビットの情報、ページの部地理アドレスを示す数値
  - 64 ビットアーキテクチャの場合、物理アドレスは 64 ビットです
  - ページサイズは 4K バイトなので、マッピング情報も 4K バイト単位になる、
  - エントリの下位 12 ビットをページの情報に、上位 52 ビットをページの位置情報に使用する
  - present bit = 1 の場合はページが存在するので、CPU アーキテクチャごとに決められたフォーマットで、ページの物理アドレスと属性情報を記載する
    - 一方、「present bit = 0」は、ページが存在しないことを意味する
    - その場合は残り 63 ビットを自由に使ってよい
  - スワップ情報を示すスワップエントリでは、present bit = 0 となり、残りの 63 ビットにスワップタイプとスワップ位置の情報を書き込んでいます
  - ただし、これは CPU アーキテクチャによって規定されているフォーマットというわけではありません
  - Present Bit = 0 のときは、OS の都合でどんな書き方をしてもよい
  - Linux では、5 ビットをスワップタイプに、58 ビットをスワップ位置情報に使っている
  - 全ビットが 0 の場合は、無効なエントリとして扱う
  - スワップタイプはもともと、スワップタイプはもともと、スワップデバイスの番号を格納するためのものでした
  - しかし、32 個(5 ビット)もスワップデバイスを付ける人がいないことから、いくつか拡張された使い方に利用されるようになった
  - その利用方法の一つがページマイグレーションです
- ページマイグレーションの流れ
  1. ページテーブルエントリをマイグレーションエントリに置き換える
  - Present Bit = 0 になるので、CPU は仮想アドレスに対応する物理メモリがないと判断する
  - この状態でユーザプロセスが仮想アドレスにアクセスすると、対応する物理メモリがないのでページフォルトという例外処理が発生する
  - ユーザ処理はページマイグレーションが終えるまで待たされる
  2. カーネルは別のページにメモリの内容をコピーする
  3. 新しいページの情報をページテーブルに書き込む
  4. Present Bit = 1 に戻してユーザからのアクセスを可能にして完了
- ページマイグレーションを利用したデフラグ
  - 連続したページを確保できるように、デフラグする機能がある
  - 以前は、連続したページを確保するために、強制的にメモリをスワップアウトしていた
  - HugeTLB の利用においても 2M の連続メモリが必要なため、自動デフラグ機能は重要になってくる
- NUMA 対応のメモリアロケータ
  - Linux は、メモリアロケータがメモリをノードごとに分割する
  - CPU スケジューラもノードを意識して階層構造になっている
  - 基本的にスレッドにはそのスレッドが動作している CPU の所属ノード内のメモリを割り当てる
  - そして、割り当てに失敗した場合にもう片方のノードからメモリを割り当てる
  - メモリのアクセス速度は、当然同じノード上のメモリの方が早く、他ノードのメモリアクセスはその倍時間がかかる
  - このため、NUMA 環境では、プロセスとそのメモリ配置がノードごとによるように固定するとよい
  - これは、numactl というコマンドや、mempolicy というシステムコールで設定できます
  - また、numad というカーネルデーモンを使うことで、自動配置を調整するような仕組みもある
  - しかし、動的なページマイグレーションにはペナルティがあるので、できるだけ静的に設定するとよい
- reclaim 処理もノード単位で行われる
- カーネルスレッドの kswapd などもノード単位で動作する
  - zone_reclaim_mode を有効にする必要がある

## CPU やメモリの配置を操作する

- cpuset は、CPU やメモリ、根とワークなどのリソースをグループ単位に割り当てたりできる「cgroup」の機能の一つ
- プロセスに割り当てた CPU やメモリの配置をユーザが外部から操作できる API を備えている
- cpuset は、ファイルシステムとしてマウントして使用する
- cpuset を用いて配置を操作する際は、コントロールファイルと呼ばれるファイルに書き込みます

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

```
# あるプロセスの CPU やメモリの配置を操作するとします
# まずは、cpuset の操作用ディレクトリを作る、すると、ディレクトリ内に自動的に各種コントロールファイルがつくられる
/sys/fs/cgroup/cpuset/Group_A

# このうち、「cgroup.procs」というファイルに操作するプロセスの ID を書き込む
cat /sys/fs/cgroup/cpuset/machine/kubernetes-centos7-1.libvirt-qemu/vcpu0/cgroup.procs
10607

# そして、cpuset.cpus に利用する CPU, cpuset.mems にノード(今後このノードからリソースの割り当てを得る)を設定できる
cat /sys/fs/cgroup/cpuset/machine/kubernetes-centos7-1.libvirt-qemu/vcpu0/cpuset.cpus
0-1
cat /sys/fs/cgroup/cpuset/machine/kubernetes-centos7-1.libvirt-qemu/vcpu0/cpuset.mems
0
```

- メモリの割り当ては少し注意が必要で、値を書き込んで設定を変更しても、その効果は新たに割り当てられるノードにしか恩恵は受けられない
- すでに使用中のメモリを移動させるには「cpuset.memory_migrate」に 1 を設定しておく
- これにより、cpuset.mems に値を書き込んだ際に必要に応じてメモリマイグレーションが発生し、使用中のメモリがすべて指定ノードに移動される
- この cpuset を利用してメモリ配置を自動調整するサービスが numad です。
  - numad は、プロセスの CPU やメモリーを必要に応じて適切に配置なおしてくれるデーモン
  - numad は一定時間ごと(15 秒ごと)にシステムをスキャンし、次の 2 種類のシステム情報を入手する
- ノードごとの CPU アイドル率
  - /proc/stats から取得
  - 各 CPU ごとのフィールド 4 番目にシステム起動時からの通算アイドル時間が 10 ミリ秒単位で表示される
  - これを繰り返し取得し、前回スキャン時からのアイドル時間の差分を差分を計算する
  - この結果を経過時間で割ると、直近の CPU のアイドル率が求まる
  - これを CPU_FREE とする
- ノードごとの空きメモリ情報
  - /sys/devices/system/node/node0/meminfo
  - この MemFree の値を MEM_FREE とする
- CPU_FREE \* MEM_FREE の値をノードが持つリソースの余裕を評価する値として利用する
- 全プロセスをスキャンして/proc/プロセス ID/stat ファイルから「CPU 使用量」および「メモリ使用量」を入手する
  - これらを掛け合わせてスコアを出し、高い順にソートする
  - リストの上位から順に、各プロセスのノード配置を変更するかどうか判定していく
  - 判定では、/proc/[pid]/numa_maps を開き、各プロセスがどのノードでどれだけのメモリを利用しているのかチェックする
  - 得られた（プロセスの)各ノードでのメモリー使用量を MEM_FREE の値に加味し、
  - magnitude=CPU_FREE\*MEM_FREE という式を使って各ノードのリソース空き状態を評価する
  - この magnitude という値をもとに、利用するノードの優先度を決める
  - 現状の利用ノードが優先度の高いノードとは異なっていた場合、プロセスの CPU やメモリを再配置する
  - 再配置は、cpuset.memory_migrate に 1 を設定したうえで、cpuset.cpus ファイルに CPU、cpuset.mems にノードの値をセットすることで行われる
  - プロセスを 1 つ移動したら、同じプロセスを何度も行ったり来たりさせないように最低 5 秒待ってから次回のスキャンを行う

## 自動 NUMA バランス

- 2012-2013 にかけて、カーネル側で自動的にアプリケーションのメモリアクセスを追跡し、CPU とメモリの配置をチューニング（バランス)する仕組みが開発された
- CPU の移動とスケジューラ
  - プロセスが実際にメモリが割り当てられるのは、プロセスが仮想メモリに実際にアクセスしたときです
  - この時、OS はメモリアクセスを実施した CPU にもとっも近いノードからメモリを割り当てる
  - しかし、スケジューラの都合によってプロセスが動作する CPU が別の NUMA ノードに代わると、メモリが遠くなってしまう
  - プロセススケジューラはシステム全体を見ながら空いている CPU にプロセスを移動しようと、常に監視を続けています
  - 移動の際、現在の CPU が属す NUMA ノード内の別の CPU を優先するよう配慮します
  - カーネルによる NUMA 自動バランシングでは、メモリマイグレーションを利用して、自動的に CPU の位置とメモリの位置を調整します
  - カーネルのスケジューラにプロセスとメモリの位置を追跡し、必要に応じてメモリを移動したり、（プロセスがスケジュールされるべき NUMA ノードを覚えておいて）チャンスがあれば元の位置にプロセスを戻したりする機能が付加されました
  - これは自動で有効化されているため、無効化する場合は numa_balancing=disable をセットする
- アクセス時のメモリ移動
  - プロセスにメモリページが割り当てられた際、ページの位置がプロセスのページテーブルに登録される
  - メモリアクセスの追跡においてもページテーブルが利用される
  - numa_balancing が有効の場合、一定時間ごとにプロセスのメモリをスキャンして、メモリマッピングを一時的に引きはがす処理が行われます
  - このとき、ページマイグレーションの場合と同じようにページテーブルの PresentBit を 0 にし、ページテーブルには「NUMA 情報収集のために、一時的にページを外した」ことを記録しておきます。
  - こうしておくと、プロセスがメモリをアクセスした際に、PageFault が発生し、OS がメモリアクセスを補足できる
  - PageFault が起こると、カーネルはプロセスが現在動作している CPU と引きはがしたページ位置(NUMA ノード)を比較し、
  - それらが異なる NUMA ノードに置かれている場合にはページマイグレーションを発生させて、メモリを CPU のある NUMA ノードに移動させます
- プロセスのアクセス追跡
  - ページマイグレーションにはオーバヘッドがあるので、頻繁に行うわけにはいかない
  - そこで、カーネルは、どの NUMA ノードで PageFault が起こったかを記録した統計データを集めて活用している
  - この統計情報には、ページが単一のスレッドからアクセスされたのか、複数のスレッドから共有アクセスされたのか、ページマイグレーションが発生したのかなどが記録される
  - numa_balancing の統計情報は/proc/vmstat で参照できる

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

- スケジューラは統計データをもとに主に二つの判断を下す
  - 一つはページスキャンの頻度です
    - 例えば、複数のスレッドから共有アクセスされるページの場合、それらスレッドが複数の NUMA ノードに分散していると、最適なノードを決められない
    - このようなページが多い場合は、スキャンの頻度を下げる
    - 逆に、ページが単一のスレッドからアクセスされメモリマイグレーションが多く発生している場合はスキャンの頻度を高めて、CPU とメモリのバランスを改善できる
  - もう一つは、プロセスが動作する CPU の決定に使われる
    - CPU がすべて空いていれば、メモリに近い CPU でスレッドを走らせればよいが、そうでない場合は適切な CPU を割り出す
    - 場合によっては、プロセスを最適な CPU に移動する

## キャッシュと複数 CPU

- CPU コアが増えた場合、複数の CPU コアから同時にアクセスされる可能性のあるメモリ領域の取り扱い
- PER CPU メモリの仕組みを見てみる
- CPU キャッシュとライン
  - CPU からメモリへのアクセスを高速化するために、CPU にはキャッシュが搭載されている
  - CPU の仕組みにも依存するが、ある CPU が数バイトのメモリを読み出すと、まずメモリからキャッシュにひと固まりのデータ(ラインと呼ぶ)がロードされる
  - そして、CPU がキャッシュから必要なデータを読み出す
  - 書き込む際は、いったんキャッシュを収め(write-allocate)、キャッシュラインに変更を加えた後、適切なタイミングでメモリに書き戻します(write-back)
  - キャッシュ操作はライン単位で実施される
  - キャッシュラインのサイズは、Intel CPU では 64 バイトと考えてよいようです
- CPU0 と CPU1 の二つの CPU があるとする
  - CPU0 がデータ X に書き込んだ後、CPU1 が同じデータ X に書き込んだ場合を考えてみる
  - まず、CPU0 がデータ X を含むラインをメモリから読みだしてキャッシュに収め、キャッシュラインに改変を加える
  - この後、CPU1 が同じデータ X に改変を加えるわけだが、メモリ上のデータ X は CPU0 のキャッシュラインにあるデータ X よりも古くなっている
  - そこで、CPU0 のキャッシュラインを CPU1 に移します
  - その際、CPU0 側のキャッシュを消して、CPU1 がデータ X を独占的に書き換えられるようにします
  - なお、CPU0 と CPU1 がいずれもデータ X を読み出すだけで書き換えない場合は、CPU0 および CPU1 のキャッシュに同じラインが乗っていることもあります
- False Sharing
  - 前述のように、米 Intel 社製 CPU ではラインが 64 バイトもあるので、同じデータへのアクセスではなく、近くにあるデータにアクセスした場合にもキャッシュ間でのライン移動が生じる可能性があります
  - 例えば、long が 8 バイトだとして、その一次元配列を定義し、その並列に各 CPU が異なるインデックスをアクセスした場合、8CPU(64/8)分のデータが同じラインに乗ることになる
  - 各 CPU がそれぞれのインデクスのデータを書き換えるたびに、ラインの移動が発生し動作が極めて遅くなる
  - このような状況を False Sharing と呼ぶ
- キャッシュへのアクセスを最適化するため、Linux カーネルは各 CPU 固有のデータ域を作成する「PER CPU メモリ」という機能を持っている
  - PER CPU メモリは対となる CPU からしか書き換えないという"お約束"のもとに利用できるカーネルメモリ
  - 各 CPU を占有することにより、False Sharing を回避できるとともに、メモリアクセスに置いてロックなどの排他制御が不要になる
  - 使い方は、まず次のようなオブジェクトを作成する
    - x = aloc_percpu
    - this_cpu(x)で各 CPU のローカルデータに、また per_cpu(x, cpu)で各 CPU 固有のデータ息にアクセスする
    - 各 CPU のデータは、実際には CPU ごとにまとまった個別のメモリ域に配置され、this_cpu()などによってアドレス位置を計算した上でアクセスされる
  - PER_CPU カウンタ
    - 各 CPU 固有のメモリ域にカウンタを持たせることで、精度を犠牲にしてキャッシュラインの相次ぐ移動を避けて SMP 性能を引き上げる機能です
    - int counter;
    - per_cpu int pcp_counter;
    - 各 CPU は pcp_counter を更新し、その絶対値が閾値以上になったら counter に反映する
    - 例えば、1 ずつカウントアップする counter において閾値が 16 なら counter へのアクセスを 1/16 に減らすことができる
    - このケースで CPU 数が 16 の場合には、最大で 240 の誤差がでる
      - /proc から読み取れるデータの中には、こうした仕組みで算出されてるものもあるので、値が必ずしも正確とは限らない
    - CPU が多い場合には、OS が見せる細かい数値の「正確さ」にはこだわらないように

## リソースコントローラ

- プロセスに割り当てる CPU やメモリの量、I/O やネットワーク帯域を、ユーザからの指示を受けて制御する機能を「リソースコントローラ」と呼ぶ
- Linux カーネルには、プロセス群のリソースを管理する「cgroup」という仕組みが備わっている
- memory cgroup
  - ユーザプロセスのメモリやファイルキャッシュ、カーネルメモリの一部などを管理できる
  - 各 memory cgroup はカウンタを一つ持っている
    - そして、ページ獲得要求を受けた際のメモリ獲得制限に、そのカウンタの値を使う
  - 例えば、memory cgroup のリミットが 4G バイトで、ここに 3 プロセスが所属していてそれぞれが 1G バイトづつ(合計 3G バイト)利用していたとする
    - この場合、あと 1G バイトのメモリは獲得できる
    - しかし、1G バイトを超えて獲得しようとした場合には、この memory cgroup 内で保持しているページ(各プロセスのファイルキャッシュやユーザメモリ)からメモリ回収を試みます
    - また、swap も同じ memory cgroup で limit をかけることができる
  - つまり、最大の limit は、メモリ + swap のトータルとなる
  - これは、カーネルのメモリ管理機構が行うスワップアウトに干渉しない
    - kwsapd などのシステム全体をメンテナンスするプログラムの動作には極力干渉しないようにするため
- memory cgroup 単位でのメモリ回収と、システム全体でのメモリ回収が両立するように、memory cgroup を組み込んだ場合のメモリ回収用 LRU には工夫が凝らされている
  - LRU とは Least Recentry Used: 最も長期間使われていないプロックを割り出すアルゴリズムのこと
  - 基本的には、memory cgroup 単位に LRU を保持しており、システム全体からメモリ回収を行う場合には、すべての memory cgroup を順番にスキャンする
  - memocy cgroup がある場合は、それらを一つづつ調べて、それぞれの LRU から回収するメモリを見つける
  - そして、各 memory cgroup が持つページ数や直近のアクセス動向をベースに、メモリを回収すべきかを決定する
  - memocy cgroup がない場合は、各 NUMA ノードが持つメモリの LRU リストから回収するメモリを見つける
- カウンタの工夫
  - memory cgroup はメモリ量を数えるカウンタを持っている
  - 普通に数えると、性能のボトルネックになるので、PER CPU カウンタのような作りになっている
  - このため、memory.usage に表示されるメモリ使用量の精度には最大 128K バイトほどの誤差が生じる
  - とはいえ、タスクスイッチ時に誤差を解消するようなコードになってるので、あまり気にする必要はない

## sysctl

- reclaim 関連

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

- dirty 関連

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

- http://linuxinsight.com/proc_vmstat.html

```bash
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

- /proc/meminfo
- /proc/sys/vm/...

## ページ

- http://www.coins.tsukuba.ac.jp/~yas/coins/os2-2010/2011-01-11/

## buddy

- 「Buddy システム」は、Linux で使われている外部フラグメンテーションを起こしにくいメモリ割当てアルゴリズム
- 利用可能なメモリ・ブロックのリストを管理する
- メモリ・ページを「ゾーン」と呼ばれる領域に分割して管理する
- ZONE_DMA: DMA でアクセス可能なページ・フレーム x86 では 0-16M
- ZONE_NOMAL: DMA ではアクセスできないが、カーネルの仮想アドレス空間に常にマップされてる
  -x86 では 16M-896M
- NONE_HIGMEM: 普段はカーネルの仮想アドレス空間にマップされていない
  - 使うときにはマップして使い、使い終わったらアンマップする
  - x86 では 896M より大きいところ
- buddyinfo で現在の空き情報が確認できる

```bash
#                         4K     8k     16k    32k    64k   128k   256k   512k     1M     2M     4M
$ cat /proc/buddyinfo
Node 0, zone      DMA      0      1      1      0      2      1      1      0      1      1      3
Node 0, zone    DMA32    710    596    407    454    362    241     89     14      7      0      0
Node 0, zone   Normal    106    486    327    178    135     56     40      7      4      0      0
```

## pmap -x [PID]

- メモリには file map と anon がある
- file map はプログラムファイルや共有ライブラリタの内容を読み込んだメモリ領域
- anonymouse はファイルとは無関係の領域で、ヒープ（malloc で得られるメモリ）やスタックに使う

```bash
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

## HugePage

- http://dpdk.org/doc/guides-16.04/sample_app_ug/vhost.html
- https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/7/html/Virtualization_Tuning_and_Optimization_Guide/sect-Virtualization_Tuning_Optimization_Guide-Memory-Tuning.html

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
GRUB_CMDLINE_LINUX="default_hugepagesz=1G hugepagesz=1G hugepages=8"

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


$ virsh dumpxml xxxx
<memoryBacking>
   <hugepages/>
</memoryBacking>
```

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

## jemalloc()

## tcmalloc()

## kmalloc()

## slub

- カーネルは、メモリの利用効率を高めるために、カーネル空間内のさまざまな メモリ資源を、資源ごとにキャッシュしている領域
- もし、slub のメモリが断片化してしまうとパフォーマンスにも影響が出てくる
- スラブの利用量は slubtop で確認できる

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

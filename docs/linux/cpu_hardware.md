# CPU(ハードウェア)

## CPU の基本原理

- CPU ができるのはデータのコピー、四則演算、論理演算、数値比較などだけ
  - 高度な演算もこれらの基本演算を組み合わせて実現しているだけ
  - トランジスタのスイッチ特性を利用することで、これらの演算を実行するための回路を構成している
  - CPU はメモリから値をレジスタにロードして、何らかの演算をし、レジスタに格納されている結果をメモリに書き込む、基本的にはこの繰り返し
- トランジスタ
  - マイクロプロセッサのものになる電子回路のほとんどはトランジスタの組み合わせでできている
  - トランジスタは、増幅器としても使えるが、高速なスイッチの役割を持っており、その高速な ON/OFF 動作でさまざまな計算を行っている
  - プロセス・テクノロジー
    - 半導体チップの製造技術のこと
    - プロセスノードの微細化は直近の約 10 年間で、90nm -> 65nm -> 45nm -> 32nm -> 22nm -> 14nm -> 10nm と進化してきた
    - Intel の 10nm プロセスでは、1mm^2 当たり 1 億 80 万個のトランジスタを詰め込む
  - 参考文献
    - [Intel: トランジスターの仕組み](https://www.intel.co.jp/content/www/jp/ja/innovation/transworks.html)
- レジスタ
  - CPU はレジスタと呼ばれる小規模な記憶装置を何個か持っている
    - レジスタは 8bit, 16bit, 32bit, 64bit といった数値を記憶することができる
  - アドレッシングモード
    - レジスタに記録された数値をそのまま数値として解釈する場合とアドレスとして解釈する場合がある
      - アドレスで解釈する場合はさらに、絶対的なアドレスとして解釈するのか、相対的なアドレスとして解釈するのか、あるいは計算結果のアドレスとして解釈するかの違いがある
      - この解釈の指定の仕方をアドレッシングモードといい、機械語命令で指定できる
    - アドレッシングモードの種類
      - 即値 (immediate または literal): 指定されている数値そのものを指す
      - 絶対アドレス (absolute address): 指定されている数値で示されるメモリー上のアドレスを指す
      - レジスタ直接 (register direct or 単に register): レジスタの数値そのものを指す
      - レジスタ間接 (register indirect): レジスタの数値で示されるメモリ上のアドレスを指す
      - ベースオフセット (base plus offset or base plus displacement): 指定したレジスタ(ベース)に符号つき数値 (オフセット) を加えたアドレスを指す
        - レジスタ間接に機能を足したもの
      - レジスタ自動加算 (register auto increment): 指定したレジスタのアドレスを指すが、命令が終わった後、符号付き数値を加算・減算します
        - レジスタ間接に機能を足したもの
      - プログラムカウンタ相対アドレス (PC-relative address): 現在のプログラムに指定されている符号つき数値を加えたアドレスを指します。
  - 特殊レジスタ
    - 汎用レジスタは、アドレッシングモードによって使い分けしているが、特定の用途専用の特殊レジスタがある
    - 代表的な特殊レジスタ
      - プログラムカウンタ
        - CPU はプログラムカウンタの指し示すメモリから機械語コードを読み取り(fetch)、その意味を解釈し(decode)、実行し(execute)、結果を書き込む(store)
        - fetch が終わったときにプログラムカウンタのアドレスを一つ進める
        - また、条件分岐などで特定のアドレスに値を代入することもある(分岐命令)
        - fetch, decode, execute, store のサイクルを命令サイクル(instruction cycle, fetch-and-execute cycle, fetch-decode-execute cycle, FDX)と呼びます
        - CPU は、一つの機械語命令実行で必ず命令サイクルを 1 通り行う
        - しかし、命令サイクルを一つづつ実行する必要はなく、ある命令を実行している間に次の命令の fetch を行うというように効率よく進めることも可能
          - このような方式に、パイプライン方式、スーパースカラ方式などがある
      - スタックポインタ
        - 関数や手続き、サブルーチンの呼び出しの実用に用いる
        - 関数 a, b, c を入れ子で呼び出しているとき、その返りは c が終了すると b に戻り、b が終了すると a に戻るという LIFO になっている
        - 例
          - サブルーチンを呼び出す命令を fetch/decode すると execute/store のサイクルで、スタックポインタの指し示すアドレスに現在のプログラムカウンタの値を書き込んで、スタックポインタを増やし、プログラムカウンタに呼び出す先のサブルーチンのアドレスを代入する
          - そして、サブルーチンが終了して、復帰する命令(return)を fetch/decode すると execute/store のサイクルで、スタックポインタを減らし、スタックポインタの指し示すアドレスから値を読み取ってプログラムカウンタに代入する
      - フラグ
        - 計算結果を格納する
        - N(negative)フラグ: 計算結果が負だと 1、それ以外で 0 になる
        - Z(zero)フラグ: 計算結果が 0 もしくは等しかった場合に 1、それ以外で 0 になる
        - C(carry)フラグ: 符号なしの整数だと思って計算したときに、桁上がりもしくは桁下がりが起こった場合に 1、それ以外で 0 になる
        - V(overflow)フラグ: 符号付きの整数だと思って計算したときに、桁あふれが起こった場合に 1、それ以外で 0 になる
- 機械語
  - CPU が解釈する命令は、実際には対応する数値で表される
  - 命令の集合の事を命令セットとよび、CPU のメーカや世代によって異なる
  - 機械語とは CPU によって直接実行される命令とデータの体系のこと
  - 機械語をそのまま覚えるのは難しいため、機械語と人が読めるように一対一で対応させた言語がアセンブリ言語
  - 通常のプログラムはこの機械語に翻訳(コンパイル)されることで CPU で実行可能になる

## 用語

- パイプライン処理
  - 命令サイクルを一つづつ実行する必要はなく、ある命令を実行している間に次の命令の fetch を行うというように、各工程を流れ作業のように処理すること
- スーパースカラ
  - 一つのコアで命令処理を実行する回路(パイプライン)を複数持ち、複数の命令処理を同時に実行する仕組み
- 論理プロセッサコア(マルチスレッディング、ハイパースレッディング)
  - 実際の物理コア数よりも多く(基本 2 倍)のコアを OS に見せる技術
  - OS が複数のプロセスを別々のコアに割り当てても、物理的には同じコアで複数のプロセスが同じ実行エンジンを共有している
  - これによりパイプラインを効率的に使える
- 分岐予測、投機実行
  - 命令処理の結果によって次に実行する命令処理が異なる場合、どの命令処理が実行されるかを予測する仕組み
    - 過去の実行履歴にもとづき、次に実行される可能性が高い分岐の命令予測する
  - その予想にもとづいて、命令処理を先に実行する仕込みを投機実行という
- アウトオブオーダ
  - 実行すべき命令は基本的に順に実行していかなければならないが、結果に影響を与えないのであれば順序を問わずどんどん実行することにより、複数命令の同時実行を可能にする
    - 「順序を守らない実行」の意である(順序通りに実行することを、インオーダと呼ぶ)
  - アウトオブオーダプロセッサは過度な投機実行を行い、その命令が本当に「正しい」命令であるかどうかを確認する必要がある
- リオーダバッファ
  - アウトオブオーダで発行された各種演算ユニットで処理された命令を、処理が完了した段階で回収し、最後に順番を命令順にそろえるユニットのこと
    - 言い換えると、命令をインオーダ完了させるためのユニット
  - リオーダバッファに溜め込まれ、前の命令(条件分岐命令)の結果が確定したことをもって、その命令が有効かどうかを決定する
    - このステージで「命令がコミット」されると、その命令が実行されることを確定し、リオーダバッファからレジスタファイルへのデータ書き戻しなどの確定処理が行われる
      - そうでなければ、その命令はリオーダバッファから破棄される
    - このとき、コミットされた命令は命令の実行が確定したとして、最後の書き戻し処理を行って「リタイア」される
- ミスプレディクションウィンドウ
  - 投機実行では、分岐予測が完了するまでとりあえず次の命令を fetch して発行し続けるが、これらの命令は条件分岐予測が外れることにより破棄されるかもしれない
  - ミスプレディクションウィンドウは、この条件分岐命令において、どれくらいの後続の命令が発行されるかを示しており、このウィンドウが大きいほど多くの命令が破棄される
- ノンブロッキングキャッシュ制御
  - ある命令処理に必要なデータがキャッシュメモリになく、メインメモリまでデータを取りに行く間に、別の命令処理に必要なデータをキャッシュメモリに取りに行くことができる仕組み
- キャッシュメモリ
  - CPU のチップ上に搭載されている高速少量のメモリ
    - DRAM よりも高速で高価な SRAM が使われている
  - アクセスする頻度の高いデータや命令をキャッシュメモリに保存しておくことで、メモリアクセスの時間を短縮できる
- キャッシュヒット、キャッシュミス
  - CPU はデータを読み込む際に、まずキャッシュメモリ上を探す
  - これがあればキャッシュヒット、そのキャッシュからデータをレジスタにストアする
  - これがなければキャッシュミス、メインメモリからデータをレジスタにストアし、このときキャッシュにもストアする
- キャッシュデータ、アンキャッシュデータ
  - リアルタイムデータや制御データなどのタイムクリティカルなデータは、キャッシュに入れてしまうと実際にコアの外のバスに流れるのがいつになるかわからないので、アンキャッシュなデータとしてレジスタに持ってきたり、レジスタからストアする
  - アンキャッシュなデータはキャッシュを汚すことがないというのが一つの利点であり、またすぐにコア外のバスまで出ていくのでタイミングクリティカルな制御信号などを流すのに使われる
- ハードウェアプリフェッチ
  - プログラムのメモリアクセスの規則性から、今後のデータアクセスをハードウェア自身により予測し、あらかじめメインメモリからキャッシュメモリにデータを読み込む仕組み
- ストール
  - CPU のパイプライン処理が止まること
  - キャッシュミスした場合にメモリからデータを読み込む(Data Fetch)必要があるが、この読み込んでいる間は CPU はなにもできず、この状態をストールと呼ぶ

## Meltdown と Spectore

- どちらも CPU の投機的実行の設計ミスを利用した攻撃(サイドチャネル攻撃)
- Spector
  - アプリケーション内で悪意あるプログラムを埋め込み、そのアプリケーション内のメモリ領域を推測する攻撃
  - 攻撃例
    - ブラウザが悪意ある JavaScript を実行したとき、ブラウザがメモリ領域上に保存しているパスワードなどを読むことができる
- Meltdown
  - ユーザ空間のプロセスが、カーネルのメモリ空間の中身を推測する攻撃
  - 攻撃例
    - 悪意あるプログラムが、ホストのカーネル空間を読むことができる
    - 仮想マシンが、親ホストのカーネル空間のアドレスを読むことができる？
- Variant 1: bounds check bypass(Spector)
  - 一般的なアプリケーションが、配列にアクセスしようとするとき、バッファオーバーフローなどの対策のために Bounds Check を行う
    - 例えば、配列の長さを調べて、その範囲内でのみアクセスするといったコード
  - しかし、投機実行では if 文のあとの配列にアクセスする処理が先に実行される場合があり、その計算結果がキャッシュに乗ってしまう
  - その後、そのキャッシュにヒットするかで、その値を推測する
  - この脆弱性はバウンドチェックをしているコードパターンがないとできないらしい
  - 対策
    - アプリケーションによる修正が必要
- Variant 2: branch target injection(Spector)
  - 条件分岐で pc のアドレスが飛ぶとき、投機実行では、すでに飛んだことある履歴から実行することができる
  - これを使うと、本来飛ぶところではないところに、投機的に実行でき、その結果がキャッシュに乗ってしまう
  - その後、そのキャッシュにヒットするかで、その値を推測する
  - ゲスト側から kvm のシンボルのアドレスが分かる
  - 対策
    - アプリケーションによる修正が必要
- Variant 3: rogue data cache load(Meltdown)
  - カーネルメモリアドレスを読み込む命令を実行し、その読み込んだデータを使って別計算をする
  - このとき、本来はセグメンテーションフォルト例外となるが、それが確定する前に投機実行で次の計算が実行されてしまい、その結果がキャッシュに乗ってしまう
    - リオーダの段階になって例外が発生し、リタイアするがキャッシュは消えない
  - その後、そのキャッシュにヒットするかで、その値を推測する
  - 対策
    - OS による修正が必要
    - KPTI(Kernel Page-Table Isolation)
      - ユーザモードとカーネルモードで利用するページテーブルが共通であることが原因
      - そのためユーザモードとカーネルモードで利用するページテーブルを分けた
      - しかし、ユーザモードとカーネルモードが切り替わるときにページテーブルも切り替える必要があるためコストが高い
        - TLB フラッシュが伴う
      - ユーザモードのときはカーネルのページ部分をアンマップし、カーネルモードになるときにマップする
        - ページテーブルの切り替えではない？
- 派生攻撃
  - BranchScope
    - BPU(Branch Prediction Unit)の方向予測をターゲットにした攻撃
    - http://www.itmedia.co.jp/news/articles/1803/28/news062.html

### 対策コードを無効にする

- https://access.redhat.com/articles/3311301
- https://access.redhat.com/ja/articles/3316261

```
# CentOS
$ echo 0 > /sys/kernel/debug/x86/pti_enabled
$ echo 0 > /sys/kernel/debug/x86/ibpb_enabled
$ echo 0 > /sys/kernel/debug/x86/ibrs_enabled

# centos6ではdebugfsをマウントする必要がある(centos7ではデフォルトでマウントされている)
$ mount -t debugfs nodev /sys/kernel/debug
```

## Microcode

- CPU を外部から制御する場合の命令単位をインストラクションと呼ぶ
- ある命令を実行するために必要な手続きがマイクロコードとして実装されている
- Microcode は CPU 内部のメモリに保存されている
- MCU(Microcode Update)
  - Microcode を修正するためのコード
  - 各 CPU にあわせて作成される
  - BIOS および OS に保存される
    - マシンのブート時に BIOS 内の MCU が CPU にロードされ、OS 起動時に BIOS の MCU より新しい revision が OS 内にあればそれをロードする
  - MCU は、マザーボード・OS ベンダーに配布され、BIOS や OS に組み込まれた状態でエンドユーザにに提供される
- 参考
  - [Intel Microcode の基礎](http://datyotosanpo.blog.fc2.com/blog-entry-180.html)
  - [Linux カーネルが x86 microcode を扱う処理について](https://qiita.com/akachochin/items/ae91efec12297fd05c0b)

## CPU の仕様書・設計 IP・製品について

- 仕様書
  - ISA(Instruction Set Architecture: 命令仕様)のこと
  - x86
    - クロスライセンス契約により Intel, AMD のみ利用可能
  - ARMv7, ARMv8
    - これを直接利用するためには ARM からアーキテクチャライセンスを購入する必要がある
  - RISC-V
    - オープンソースで誰でも利用可能
- IP(Intellectual Property)
  - 仕様書をもとに作成された回路設計データのこと
    - ARM などはこのデータを半導体メーカに提供し、ライセンス料をもらう事で商売をしている
  - x86
    - Intel, AMD がそれぞれ独自に所持している
  - ARM
    - Arm 社の Cortex シリーズ
      - これを利用するためには、ARM からプロセッサライセンスを購入する必要がある
    - Qualcomm 社の Kryo シリーズ
    - Apple 社の A シリーズに搭載されている SoC など
- 製品
  - IP をもとに製造された製品の事
  - x86
    - Intel, AMD がそれぞれ独自に CPU を製造している
  - ARM
    - Qualcomm 社の Snapdragon シリーズ
    - Apple 社の A シリーズ
- x86 のライセンスについて
  - 初期の Intel は自社だけでは CPU を安定供給できない状況から、他の半導体メーカにも製造してもらうためにセカンドソース契約を結んでいた
    - ライセンス料の代わりに、設計データや製造に必要な情報を渡して、他社にも自社の CPU を製造できるようにする契約
    - Intel は、8086/8088 では、AMD/米 Harris/独シーメンス/NEC/日立などとセカンドソース契約を結んでいた
  - 初期の Intel は、セカンドソースを利用していたが、1985 年にその供給と止めると発表した
  - そこから Intel 他者を敵に回し、特に AMD とは激しい訴訟合戦が始まる
  - 1994 年に両者がクロスライセンス契約を結ぶことで合意した(2001 年に締結）
    - クロスライセンスとは、両社が必要とする技術を含んだ特許を交換し、持ちあうというもの
    - また AMD は、クロスライセンス契約の締結をただ待つのではなく、独自に x86 互換の CPU を製造するようになった
  - このような経緯から、x86 を製造できるのは Intel と AMD のみとなっている
  - 2009 年に AMD が製造部門を分離して「Global Foundries」を設立したため、Intel がこれを訴て、また一波乱あった
- 参考
  - [半導体業界における「IP」とは何なのかを説明したい](https://msyksphinz.hatenablog.com/entry/2020/10/04/040000)

## 参考文献

- [Intel: トランジスターの仕組み](https://www.intel.co.jp/content/www/jp/ja/innovation/transworks.html)
- [なんちゃって電子工学](http://doku.bimyo.jp/electronics/ShoddyElectronics882.htm)
- [コンピュータの基本構成と動作原理～知識編](https://qiita.com/zacky1972/items/ef4486e8a6d95edb68fd)
- [FPGA 開発日記: Meltdown, Spectre で学ぶ高性能コンピュータアーキテクチャ](http://msyksphinz.hatenablog.com/entry/2018/01/06/020000)
- [FPGA 開発日記: プロセッサにおけるアウトオブオーダの考え方について(リオーダバッファの考え方について)](http://msyksphinz.hatenablog.com/entry/2016/05/07/025243)
- [FPGA 開発日記: プロセッサにおけるアウトオブオーダの考え方について(リネームレジスタの例外時の処理について)](http://msyksphinz.hatenablog.com/entry/2016/04/24/030607)
- [CPU の脆弱性[Spectre], [Meltdown] は具体的にどのような仕組みで攻撃する？影響範囲は？](http://milestone-of-se.nesuke.com/nw-advanced/nw-security/meltdown-spectre/)
- [なぜ、Apple の M1 チップはそんなに速いのか?](https://okuranagaimo.blogspot.com/2020/12/applem1.html)

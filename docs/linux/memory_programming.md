# プログラミングにおけるメモリ管理

## カーネルによるプログラムへのメモリ割り当て

- 仮想アドレス空間の大きさ
  - 32 ビットシステムで、0x00000000-0xffffffff
  - 64 ビットシステムで、0x00000000-0xffffffffffffffff (実際には、 もう少し小さい。0x00ffffffffffff くらい)
- プログラムは、起動すると仮想メモリ空間を作成し、そこに以下の情報をマッピングする(以下は 32bit の例)
  - 32 ビットシステムの範囲は、0x00000000-0xffffffff（4GB）
  - カーネル空間は、高い番地(0xffffffff)から低い番地(0xc0000000)を固定で割り当てており、残り(3GB)をユーザ空間で利用する
  - 引数、環境変数(カーネル空間に続いて、高い番地から低い番地へ固定で割り当てられる)
  - スタック(引数、環境変数の空間に続いて、高い番地から低い番地へ割り当てられ拡張されていく)
    - スタックポインタが指すところ
  - ヒープ(BSS 空間に続いて、低い番地から高い番地へ割り当てられ拡張されていく)
    - スタックとヒープのメモリ空間は連続していないので、互いに拡張できる
  - プログラムファイル(0 番値付近を空けて、低い番地から高い番地へ固定で割り当てられる)
    - 読み込み専用の機械語
    - PC がこの先頭を指し、プログラムが実行される
  - 0 番地(0x00000000)付近はメモリを割り当てないことが一般的
    - 割り込みのエントリポイントになってたりする?
- 仮想アドレスと RSS
  - プロセスが、上記の仮想アドレスにアクセスすると、まだページが存在しない場合(初めてアクセスしたときなど)、PageFault という例外が発生する
  - OS は、ユーザプログラムのアクセス先を調べて、mmap によって得た仮想アドレスの場合には先ほどの mmap の指定に従ってメモリを割り当てる
  - この実際に割り当てられた物理アドレスが RSS となる
- プログラムによって拡張されるのはスタックとヒープであり、メモリにおいて開発者が意識する必要があるのもこの二つである
  - 基本的にプログラミング言語側（一部を除いて）で意識しなくてもよいように設計されているが、高パフォーマンスを目指すなら意識する必要がある

## スタック

- 静的なメモリ割り当てで利用され、LIFO(Last In First Out)の構造を持っている
- LIFO の性質上データの保存と取得が高速
- スタックに格納されるデータは有限で静的でなければならない（コンパイル時にデータのサイズが分ってる必要がある）
- 関数の実行データがスタックフレームとして格納される場所
  - 各フレームは、その機能に必要なデータが格納されるスペースのブロックです
  - 例えば、関数が新しい変数を宣言するたびに、その変数はスタックの最上位のブロックにプッシュされる
  - 次に、関数が終了するたびに最上位のブロックがクリアされる
  - これらは、ここに格納されているデータの性質により、コンパイル時に決定できる
- マルチスレッドアプリケーションは、スレッドごとにスタックを持つことができる
- スタックのメモリ管理は OS によって実行される

## ヒープ

- 動的なメモリ割り当てで利用される
- 割り当て方法はプログラミング言語に大きく依存しており、基本的にポインタを使用してヒープ内を検索する
  - スタックに比べて遅いが柔軟
- ヒープはスレッド間で共有される
- プログラム側でヒープ管理しないといけない言語
  - C、C++は、ヒープの管理をプログラム側に委ねており、malloc、free などをでメモリ割り当て、解放を行う必要がある

## ガベージコレクション（GC）

- いくつかのプログラミング言語は、ヒープを自動で管理しており、メモリの解放は GC という仕組みで行っている
  - JVM(Java/Scala/Groovy/Kotlin), JavaScript, C#, Golang, OCaml, Ruby など
- Mark & Sweep GC(Tracing GC とも言う)
  - 2 段階のアルゴリズム
    1. "alive"として参照されたまだ存在するオブジェクトをマークする
    2. "alive"でないオブジェクトのメモリを解放する
  - JVM, C#, Ruby, JavaScript, Golang はこのアプローチを利用している
  - V8 などの JavaScript エンジンは、Mark & Sweep GC と Reference counting GC を併用している
  - C, C++でも外部ライブラリとしてこのような GC を使用できる
- Reference counting GC
  - すべてのオブジェクトは参照カウントを得る
  - オブジェクトへの参照が変更されるとインクリメントまたはデクリメントされカウントがゼロになるとガベージコレクションが実行される
  - 循環参照は処理できない
  - PHP、Perl、Python は、このタイプの GC を回避策と共に使用して、循環参照を克服している

## Resource Acquisition is Initialization (RAII)

- オブジェクトのメモリ割り当ては、ライフタイムは構築から破棄までのライフタイムに関連付けられる
- これは C++で導入され、Ada や Rust でも使用されている

## Automatic Reference Counting(ARC)

- Reference counting GC に似ているが、特定の間隔でランタイムプロセスを実行する代わりに、保持及び解放命令がコンパイル時にコンパイルされたコードに挿入され、オブジェクト参照がゼロになると、プログラムを一時停止することなく実行の一部として自動的にクリアされる
- 循環参照を処理することはできず、t 九艇のキーワードを使用されて処理するために開発者に依存する
- これは Clang コンパイラの機能であり、Objective C, Swift に ARC を提供する

## Ownership

- RAII と所有権モデルの組み合わせ
- 値は所有者として（一度に一人の所有者のみ）変数を持つ必要がある
- 所有者がスコープ外になると、値は（スタックまたはヒープにあるかどうかに関係なく)ドロップされる
- これはコンパイル時の参照カウントのようなもの
- Rust によって利用されている

## Golang

TODO

## 参考

- [Demystifying memory management in modern programming languages](https://deepu.tech/memory-management-in-programming/)
- [Visualizing memory management in Golang](https://deepu.tech/memory-management-in-golang/)
  - [Go におけるメモリ管理の可視化](https://zenn.dev/kazu1029/articles/38ab3d99ef0de3)
    - Visualizing memory management in Golang の日本語訳
- [A visual guide to Go Memory Allocator from scratch (Golang)](https://medium.com/@ankur_anand/a-visual-guide-to-golang-memory-allocator-from-ground-up-e132258453ed)
- [Allocation efficiency in high-performance Go services](https://segment.com/blog/allocation-efficiency-in-high-performance-go-services/)
  - [go で書いたコードがヒープ割り当てになるかを確認する方法](https://hnakamur.github.io/blog/2018/01/30/go-heap-allocations/)
    - Allocation efficiency in high-performance Go services のメモ書き記事
- [TCMalloc : Thread-Caching Malloc](http://goog-perftools.sourceforge.net/doc/tcmalloc.html)

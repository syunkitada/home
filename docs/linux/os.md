# OS

## OS とは

- OS(Operating System)とは、コンピュータのハードウェアとユーザアプリケーションの中間に位置するシステム
- ハードウェアの各リソース管理、ユーザアプリケーションの管理、ユーザアプリケーションへ各リソース管理のためのインターフェイスの提供を行う

## OS History

### UNIX

- すべての原点となる OS であり、あらゆる OS がこれを参考にしている
- 1969 年に AT&T の Bell 研究所の Kenneth Thompson と Dennis Ritchie が UNIX の初期バージョンを作成した
- コードの権利は AT&T が持っており、ライセンス費用も高かった

### BSD

- 1977 年に UC バークレーで、何人かの学者がライセンスの状況に不満を持ち、研究や教育を目的とした AT&T のライセンスコードを一切含まない Unix のバージョンを作った

### GNU

- GNU プロジェクトは 1983 年にリチャード・ストールマンによって開始され、フリーソフトウェアのみによって「完全な Unix 互換ソフトウェアシステム」を作り上げることをプロジェクトのゴールとしていた
- 1990 年代初頭までに、オペレーティングシステムに必要な多くのプログラムが完成していたが(ライブラリ、コンパイラ、シェル)、いくつかの要素が未完成であった

### POSIX

- Portable Operating System Interface for UNIX の略
- 1980 年代中頃、様々な UNIX 系 OS のインターフェイスを標準化するプロジェクトが開始され、その標準化のベースとして UNIX が選択されできたのが、POSIX(IEEE 1003)
- POSIX は、各種 OS 実装に共通のアプリケーションプログラミングインタフェース (API) を定めた
- 規格の内容はカーネルへの C 言語のインタフェースであるシステムコールに留まらず、プロセス環境、ファイルとディレクトリ、システムデータベース（パスワードファイルなど）、アーカイブフォーマットなど多岐にわたる

### MINIX

- 1987 年にオランダ・アムステルダム自由大学の教授であるアンドリュー・タネンバウムによって開発された Unix 系 OS
- 研究や教育を目的にしており、企業ライセンスのしがらみがないように書かれた

### Linux

- 1991 年、リーナス・トーバルズは自分の PC 用のオペレーティングを書き、これを公開した
- 当時、近代的な OS を動作させる能力を持つ Intel 80386 CPU を搭載した 32 ビット PC/AT 互換パーソナルコンピュータが登場しており広く普及していた
- 当初の Linux は、Intel 80386 でしか動かなかったが、ライバルの BSD は 1992 年から USL との訴訟を抱えており、1990 年代前半において自由な Unix 互換のカーネルは Linux のみだった
- このような背景もあり、多くの開発者が Linux により多くの機能を求めて改良されていった
- ちなみに、Linux の初期の開発は MINIX 上で開始された

### FreeBSD

- 1993 年に、BSD をもとにして開発されリリースされたフリーでオープンソースの OS
- Appele の Darwin(MacOS/OS X/iOS/watchOS/iPadOS), PlayStation 3, 4 などの OS も FreeBSD のコードをベースとしている

### DOS/MS-DOS/Windows

- Disk Operating System
- DOS/360
  - 1966 年にリリースされた IBM メインフレーム用の最初の DOS
- MS-DOS
  - Microsoft が開発した 1981 年発売の IBM PC 用の DOS
  - その後 GUI とユーティリティを DOS に追加し、商用のポータブル OS にしたものが Windows
  - 1993 年に Windows NT 3.1 がリリースされ、2000,XP,7,10 と続いていく

## Linux Distribution

- Linux Distribution は、Linux Kernel とその他のソフトウェア群を一つにまとめたもの
- コミュニティで運用されるもの、企業によって運用されるもの、また既存の Distribution からの派生で様々なものがある

### Debian 系

- Debian
  - コミュニティベース
- Ubuntu
  - Canonical によって開発、運用されている
  - LTS は５年は無料だが、10 年の場合は商用サポートが必要

### Red Hat 系

- Red Hat Linux
  - Red Hat(IBM)によって開発、運用されている
  - もともとは無料版と有料版（サポート）を提供していたが、利用者の多くが無料版を利用するため、無料版を Fedora として分離した
- Fedra
  - コミュニティベース（Red Hat が支援）
  - 最新の Kernel や技術を積極的に取り入れている
- CentOS
  - Red Hat 派生のコミュニティベースだったが、途中から Red Hat が吸収した
  - Red Hat Linux をほぼそのまま利用している
  - Red Hat と同等の品質で無料で利用できるということもあり人気があったが、IBM の買収を契機に CentOS Stream へ移行され、廃止となる
- CentOS Stream
  - Redhat のアップストリームとして開発されている
  - 修正は Red Hat に導入される前に入るのでバグなどの修正も速いが、バグの混在もしやすい
  - Red Hat によるサポートも 5 年までとなっている
- Red Hat 派生のディストリビューション
  - Red Hat Linux 自体は有料だが、Linux Kernel を含む多くのソースコードは GPL なので、その多くの資産を再配布することは許可されている
    - ただし、Red Hat の商標は取り除く必要がある
  - Oracle Linux
    - 無料版と有料版があり、その違いはサポートがあるかどうか
    - Oracle 製品に最適化した Unbreakable Enterprise Kernel を提供している
    - Red Hat Kernel を利用することもできる

## References

- [Modern Operating Platforms — Evolution History](https://medium.com/@scan.pratik/modern-operating-platforms-evolution-history-dbc094002aef)

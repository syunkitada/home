# Hardware

## PCI Express

- I/O シリアルインターフェイス
- 送信/受信を分離した全二重方式を採用し、1 レーンでデータ転送を行う
- 1 レーンあたりの速度は規格によって異なるので[Wikipedia](https://ja.wikipedia.org/wiki/PCI_Express)を参照
- x1 スロットだけでなく、x2、x4、x8、x16 スロットとレーンを束ねてたものも仕様化されている
  - レーンを束ねると比例して転送速度も増えるため、x16 のスロットは速度が必要なグラフィックカードによく利用される
  - NIC などは x8 が多い、低速なものは x4
- PCIe のレーンは CPU と直接つながるものと、チップセットとつながりチップセット経由で CPU につながるものがある
  - CPU と直接つながるもののほうが当然早いため、高速な処理が求められるもの(グラフィックカード、NIC、NVMe など)は通常こちらに接続する
- CPU がサポートしているレーン数はアーキテクチャや型版によって異なる
  - 高性能なものだと 40 レーン扱えたりするが、コンシューマ向けは 24 レーンやそれ以下の場合もあるので注意
  - CPU だけでなくチップセットによっても扱えるレーンが変わってる
  - この辺も考慮して何を指すか考えてマザーボードを選択するとよい

## CPU

### Intel

- 世代
  - Nehalem: 第 1 世代
  - Sandy-bridge: 第 2 世代
  - Ivy-bridge: 第 3 世代
  - Haswell: 第 4 世代
  - Broadwell: 第 5 世代
  - Skylake: 第 6 世代
    - 2015 年, 14nm
    - [ECE 4750 Computer Architecture Intel Skylake](http://www.csl.cornell.edu/courses/ece4750/handouts/ece4750-section-skylake.pdf)
  - Kaby Lake: 第 7 世代
    - 2016 年, 14nm+
    - 10nm プロセスは予定どおり立ち上がらず、その代替として Skylake の改良版となる Kaby Lake が第 7 世代 Core プロセッサとして導入されることとなった
    - 14nm+と呼ばれる改良版の 14nm プロセスルールで製造されるためクロック周波数が引き上げられたが、基本的なマイクロアーキテクチャは Skylake と同等
  - Kaby Lake Refresh(KBL-R): 第 8 世代
    - 2017 年、14nm+
    - Kaby Lake のクアッドコア版
  - Coffee Lake: 第 8 世代
    - 2017 年, 14nm++
  - Whiskey Lake: 第 8 世代
    - 2018 年、14nm+、モバイル向け
    - CPU 側は Kaby Lake と同じで、PCH が CNL-PCH(Cannon Lake 世代の 14nm で製造された PCH)に変更
  - Amber Lake: 第 8 世代
    - 2018 年、14nm、モバイル向け
  - Coffee Refresh: 第 9 世代
    - 2018 年, 14nm++
  - Ice Lake: 第 10 世代
    - 2019 年、10nm、モバイル向け
    - CPU コアは Sunny Cove コアを搭載している
  - Comet Lake: 第 10 世代
    - 2019 年、14nm++、モバイル向け
    - 実態は、Kaby Lake Refresh の低消費電力版
    - PCH は、 ICL-PCH(Ice Lake 用の PCH)
- Foveros
  - 3D パッケージング技術
  - I/O と CPU(チップレット)を分割する
    - AMD も Epic 用のアーキテクチャ「Rome」で分離するとすでに発表しているので Intel が追従？する形となる
  - 大きなシリコン台に I/O やメモリを乗せ、さらにその上に Compute チップレットを乗せる

### AMD

- 世代
  - SledgeHammer(K8)
  - Egypt(K8)
  - Bracelona(K10)
  - Istanbul(K10)
  - Magny-Cours(K10)
  - Interlagos(Bulldozer)
  - Naples(Zen)
    - [AMD がサーバー向け CPU「EPYC 7000」ファミリを正式発表](http://pc.watch.impress.co.jp/docs/column/kaigai/1066385.html)
    - [AMD が ISSCC で ZEN ベース SoC「Zeppelin」の詳細を明らかに](https://pc.watch.impress.co.jp/docs/column/kaigai/1107967.html)
  - Rome(Zen2)
    - [AMD Discloses Initial Zen 2 Details](https://fuse.wikichip.org/news/1815/amd-discloses-initial-zen-2-details/)
    - [第 3 世代 Ryzen で採用される AMD の次世代アーキテクチャ「Zen 2」について WikiChip が解説](https://gigazine.net/news/20181120-amd-zen-2/)

### コア間接続

- CPU のコア間やチップセットはネットワークのように接続されている
  - 接続の仕方はアーキテクチャによって異なる
  - Xeon のリング型とメッシュ型のアーキテクチャ: http://hexus.net/tech/news/cpu/107011-intel-mesh-architecture-announced-upcoming-xeons/
- Intel: QPI(QuickPathInterconnect)
  - CPU 同士(NUMA)、CPU とチップセットを相互に接続するインターフェイス
- AMD: Infinity Fabric
  - EPYC で、オンダイ、オンパッケージ、パッケージ間のすべての接続に使われてる

### Turbo Boost

- [なぜ同じ CPU でも性能差が出るのか? 新 VAIO TruePerformance が教えてくれるノート PC 設計の難しさ](https://pc.watch.impress.co.jp/docs/column/ubiq/1230738.html)

## メモリ

- [DDR4](https://ja.wikipedia.org/wiki/DDR4_SDRAM)

## GPU

- [NVIDIA の新アーキテクチャ GPU「GeForce RTX 30」シリーズ](https://pc.watch.impress.co.jp/docs/column/kaigai/1275220.html)

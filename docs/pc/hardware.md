# Hardware

## PCI Express
* I/Oシリアルインターフェイス
* 送信/受信を分離した全二重方式を採用し、1レーンでデータ転送を行う
* 1レーンあたりの速度は規格によって異なるので[Wikipedia](https://ja.wikipedia.org/wiki/PCI_Express)を参照
* x1スロットだけでなく、x2、x4、x8、x16スロットとレーンを束ねてたものも仕様化されている
   * レーンを束ねると比例して転送速度も増えるため、x16のスロットは速度が必要なグラフィックカードによく利用される
   * NICなどはx8が多い、低速なものはx4
* PCIeのレーンはCPUと直接つながるものと、チップセットとつながりチップセット経由でCPUにつながるものがある
    * CPUと直接つながるもののほうが当然早いため、高速な処理が求められるもの(グラフィックカード、NIC、NVMeなど)は通常こちらに接続する
* CPUがサポートしているレーン数はアーキテクチャや型版によって異なる
    * 高性能なものだと40レーン扱えたりするが、27レーンやそれ以下の場合もあるので注意
    * この辺も考慮して何を指すか考えてマザーボードを選択するとよい


## CPU
### アーキテクチャ
* Intel
    * Nehalem, Sandy-bridge, Ivy-bridge, Haswell, Broadwell, Skylake, Kabylake
    * [IntelR 64 and IA-32 Architectures Optimization Reference Manual](https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-optimization-manual.pdf)
    * ECE 4750 Computer Architecture Intel Skylake]http://www.csl.cornell.edu/courses/ece4750/handouts/ece4750-section-skylake.pdf
* AMD
    * EPYC: http://pc.watch.impress.co.jp/docs/column/kaigai/1066385.html

### コア間接続
* CPUのコア間やチップセットはネットワークのように接続されている
    * 接続の仕方はアーキテクチャによって異なる
    * Xeonのリング型とメッシュ型のアーキテクチャ: http://hexus.net/tech/news/cpu/107011-intel-mesh-architecture-announced-upcoming-xeons/
* Intel: QPI(QuickPathInterconnect)
    * CPU同士(NUMA)、CPUとチップセットを相互に接続するインターフェイス
* AMD: Infinity Fabric
    * EPYCで、オンダイ、オンパッケージ、パッケージ間のすべての接続に使われてる



## メモリ
* [DDR4](https://ja.wikipedia.org/wiki/DDR4_SDRAM)

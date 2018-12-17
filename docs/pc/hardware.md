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
    * 高性能なものだと40レーン扱えたりするが、コンシューマ向けは24レーンやそれ以下の場合もあるので注意
    * CPUだけでなくチップセットによっても扱えるレーンが変わってる
    * この辺も考慮して何を指すか考えてマザーボードを選択するとよい


## CPU
### Intel
* 世代
    * Nehalem
    * Sandy-bridge
    * Ivy-bridge
    * Haswell
    * Broadwell
    * Skylake
        * 2015年, 14nm
        * [ECE 4750 Computer Architecture Intel Skylake](http://www.csl.cornell.edu/courses/ece4750/handouts/ece4750-section-skylake.pdf)
    * Kaby Lake
        * 2016年, 14nm+
    * Coffee Lake
        * 2017年, 14nm++
    * Coffee Refresh
        * 2018年, 14nm++
    * Sunny Cove
        * 2019年, 10nm
    * Willow Cove
        * 2020年?
    * Golden Cove
        * 2021年?
* Foveros
    * 3Dパッケージング技術
    * I/OとCPU(チップレット)を分割する
        * AMDもEpic用のアーキテクチャ「Rome」で分離するとすでに発表しているのでIntelが追従？する形となる
    * 大きなシリコン台にI/Oやメモリを乗せ、さらにその上にComputeチップレットを乗せる


### AMD
* 世代
    * SledgeHammer(K8)
    * Egypt(K8)
    * Bracelona(K10)
    * Istanbul(K10)
    * Magny-Cours(K10)
    * Interlagos(Bulldozer)
    * Naples(Zen)
        * [AMDがサーバー向けCPU「EPYC 7000」ファミリを正式発表](http://pc.watch.impress.co.jp/docs/column/kaigai/1066385.html)
        * [AMDがISSCCでZENベースSoC「Zeppelin」の詳細を明らかに](https://pc.watch.impress.co.jp/docs/column/kaigai/1107967.html)
    * Rome(Zen2)
        * [AMD Discloses Initial Zen 2 Details](https://fuse.wikichip.org/news/1815/amd-discloses-initial-zen-2-details/)
        * [第3世代Ryzenで採用されるAMDの次世代アーキテクチャ「Zen 2」についてWikiChipが解説](https://gigazine.net/news/20181120-amd-zen-2/)


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

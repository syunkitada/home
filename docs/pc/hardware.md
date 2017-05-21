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


## QPI(QuickPathInterconnect)
* CPU同士(NUMA)、CPUとチップセットを相互に接続するインターフェイス


## Refarence
* [Nehalem microarchitecture](https://en.wikipedia.org/wiki/Intel_QuickPath_Interconnect#/media/File:Intel_Nehalem_arch.svg)

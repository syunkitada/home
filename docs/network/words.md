# Netowrk系の用語メモ


## 基幹系
* TDM(Time Division Multiplexing)
    * 時分割多重
    * 複数の異なるデジタル信号を時間的に配列して、一つの伝送路で伝送を行うことができるようにする多重化の一方式
* WDM(Wavelangth Division Multiplexing)
    * 一本の光ケーブルの中に複数の波長の違う光を押し込むこと
    * 光ケーブルは一本だが、擬似的に複数の光ケーブルがあるように扱う
* SDH/SONET
    * Synchronous Digital Hierachy/Synchronous Optical Network
    * 通信網における階層的な伝送速度の標準
        * SDHはITU-Tの国際標準
        * SONETは米国ANSI(米国規格協会)の標準
* OTN(Optical Transport Network)
    * イーサネットやSDHのバイト列を固定長に区切って、オーバヘッド(管理用情報)や誤り訂正機能を追加し、光増幅中継を繰り返す長距離伝送を実がんする規格
    * SDHと同様にTDMする機構も持っている


## モジュール・装置など
* SFPモジュール
    * Small Form-factor Pluggableの略で、光トランシーバなどとも呼ばれる
    * 電子信号を光信号へ変換するためのモジュール
* パケット光統合トランスポート装置
    * パケットスイッチ部と光スイッチ部を統合した装置
    * 製品
        * NEC SpectralWave DW7000


## プロトコル
* Segment Routing
    * 参考
        * https://www.janog.gr.jp/meeting/janog40/program/sr
        * https://www.janog.gr.jp/meeting/janog40/application/files/2415/0051/7614/janog40-sr-kamata-takeda-00.pdf

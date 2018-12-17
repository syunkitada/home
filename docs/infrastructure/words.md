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
    * イーサネットやSDHのバイト列を固定長に区切って、オーバヘッド(管理用情報)や誤り訂正機能を追加し、光増幅中継を繰り返す長距離伝送を実現する規格
    * SDHと同様にTDMする機構も持っている


## LAN配線
* 光トランシーバ・モジュール
    * 光トランシーバは、電気信号と光信号を相互に変換してデータを送受信する
    * SFP(Small Form-factor Pluggable)
        * SFPは、イーサネットの1000BASE-Tまたは1000BASE-Xのいずれかで通信するための規格
    * SFP+
        * SFP+は、イーサネットの10GBASE-Rで通信するための規格
    * CFP(C Form-factor Pluggable)、CFP2、CFP4
        * CFPは40GBASE-SR8、100GBASE-SR10で通信するための規格
    * QSFP28(Quad Small Form-factor Pluggable)
        * 100GBASE-SR4で通信するための規格
* ケーブル
    * SMF(Single Mode Fiber)
        * 光の分散が小さいため長距離伝送に向いていおり、最大で40Km程度まで可能
        * 芯経が小さいので接続のときの不整合による減衰が大きく、取扱は多少困難になる
    * MMF(Multi Mode Fiber)
        * MMFにはステップインデックス(SI)とグレーデッドインデックス(GI)がある
        * SIは光の分散が大きく長距離電装屋高速伝送に向いていないが、価格は安価です
        * GIは光の分散が比較的小さく、長距離伝送は2km程度まで可能で、伝送速度は最大100Gbpsまで可能
        * OM1、OM2、OM3、OM4と4種類ある
            * 数字が大きければ、特性が良くなる
            * OM3、OM4は10GbE以上の高速伝送に最適化されたMMF
    * AOC
        * アクティブ光ケーブル
        * データセンタ内の限られた範囲の相互接続に使用される
        * 内部はSMFもしくはMMFの光ファイバ
        * プラガブル・トランシーバと同じコネクタを使用し、各ケーブル端で電気から光への変換を行う
            * 40GE、100GEではQSFP終端、10GE、25GEではSFP終端する
    * DAC
        * 直結銅線ケーブル
        * AOCと同様に、回線速度によってQSFP、SFPで終端される
        * DACに比較して、AOCケーブルは伝送距離が長くて消費電力が少なく、軽量である
            * しかし、コストは高く、光ファイバは銅線よりも損傷しやすいという難点もある
* IDF、MDF
    * IDF(Intermediate Distribution Flame)
        * 各フロアの配線盤
        * 各フロアに設置され、フロアに設置したケーブルを収容し、幹線ケーブルに接続する機器
    * MDF(Main Distribution Flame)
        * 主配線盤
        * IDFの上流に接続し、企業やビル内のすべてのケーブルを収容する機器
        * 機能はIDFと同じだが、MDFの方が規模が大きい
* 用語メモ
    * チャネル損失と最大距離
        * チャネル損失: 機器間の最大損失値、この損失値を上回る損失になると伝送を保証できない
        * 最大距離: 伝送を保証できる最大の距離
        * 損失がチャネル損失値よりも少なく、最大距離よりも機器間の距離が短くないと伝送は保証されない
* 参考
    * 100ギガ時代のLAN配線
        * https://toe.bbtower.co.jp/20170105/1187/
        * https://toe.bbtower.co.jp/20170413/1513/
        * https://toe.bbtower.co.jp/20170727/2144/


## プロトコル
* Segment Routing
    * SRv6
        * IPv6のヘッダを利用して、SegmentRoutingを実現する技術
    * SRLB
        * Segment Routingを利用した、ロードバランサ
        * file:///C:/Users/owner/Downloads/2017-ICDCS-SRLBThePowerofChoicesinLoadBalancingwithSegmentRouting.pdf
    * 参考
        * https://www.janog.gr.jp/meeting/janog40/program/sr
        * https://www.janog.gr.jp/meeting/janog40/application/files/2415/0051/7614/janog40-sr-kamata-takeda-00.pdf


## 雑多
* ADC(Application Delivery Controller)
    * ロードバランサ、Firewall, TLS終端などのフロントエンド前段の機能を兼ね備えた機器
* パケット光統合トランスポート装置
    * パケットスイッチ部と光スイッチ部を統合した装置
    * 製品
        * NEC SpectralWave DW7000
* パッチパネル
    * ラックの前部分についてるやつ
* サービスチェイニング
    * サービスプールを用意しておき、届いたパケットを種類によって各サービスに通して処理する
    * パケットによってはファイアウォールや、DDoSフィルタを通したりする
* BGP Flowspec
    * サービスチェイニングするためのフロールールをBGPで設定する?
* CLOS/EVPN + VXLAN
* ポートミラーリング
    * DDoS Detection
    * FireWall
* Pod
    * ネットワーク用語では、TORスイッチを束ねた単位
* STP
* HSRP
* BGP
* OSPF
* 渡り線
* LAG


# ShowNet
* 2018
    * https://www.interop.jp/2018/images/shownet/shownet_topology.pdf

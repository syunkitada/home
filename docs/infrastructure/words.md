# Netowrk 系の用語メモ

## 機器

- L2Switch
  - L2 レイヤ用のスイッチ
  - 隣接ノードの Mac アドレスとポートの紐づきを管理するテーブルを持っており、特定 Mac アドレス宛てのパケットを対象ポートにフォワーディングする
- L3Switch
  - L3 レイヤ用のスイッチ
  - IP によるルーティングを行う
- Router
  - L3 Switch の機能に加えて、Nat などの機能を備えたもの
  - L3 Switch のことを Router とも呼んだりする

## 基幹系

- TDM(Time Division Multiplexing)
  - 時分割多重
  - 複数の異なるデジタル信号を時間的に配列して、一つの伝送路で伝送を行うことができるようにする多重化の一方式
- WDM(Wavelangth Division Multiplexing)
  - 一本の光ケーブルの中に複数の波長の違う光を押し込むこと
  - 光ケーブルは一本だが、擬似的に複数の光ケーブルがあるように扱う
- SDH/SONET
  - Synchronous Digital Hierachy/Synchronous Optical Network
  - 通信網における階層的な伝送速度の標準
    - SDH は ITU-T の国際標準
    - SONET は米国 ANSI(米国規格協会)の標準
- OTN(Optical Transport Network)
  - イーサネットや SDH のバイト列を固定長に区切って、オーバヘッド(管理用情報)や誤り訂正機能を追加し、光増幅中継を繰り返す長距離伝送を実現する規格
  - SDH と同様に TDM する機構も持っている

## LAN 配線

- 光トランシーバ・モジュール
  - 光トランシーバは、電気信号と光信号を相互に変換してデータを送受信する
  - SFP(Small Form-factor Pluggable)
    - SFP は、イーサネットの 1000BASE-T または 1000BASE-X のいずれかで通信するための規格
  - SFP+
    - SFP+は、イーサネットの 10GBASE-R で通信するための規格
  - CFP(C Form-factor Pluggable)、CFP2、CFP4
    - CFP は 40GBASE-SR8、100GBASE-SR10 で通信するための規格
  - QSFP28(Quad Small Form-factor Pluggable)
    - 100GBASE-SR4 で通信するための規格
- ケーブル
  - SMF(Single Mode Fiber)
    - 光の分散が小さいため長距離伝送に向いていおり、最大で 40Km 程度まで可能
    - 芯経が小さいので接続のときの不整合による減衰が大きく、取扱は多少困難になる
  - MMF(Multi Mode Fiber)
    - MMF にはステップインデックス(SI)とグレーデッドインデックス(GI)がある
    - SI は光の分散が大きく長距離電装屋高速伝送に向いていないが、価格は安価です
    - GI は光の分散が比較的小さく、長距離伝送は 2km 程度まで可能で、伝送速度は最大 100Gbps まで可能
    - OM1、OM2、OM3、OM4 と 4 種類ある
      - 数字が大きければ、特性が良くなる
      - OM3、OM4 は 10GbE 以上の高速伝送に最適化された MMF
  - AOC
    - アクティブ光ケーブル
    - データセンタ内の限られた範囲の相互接続に使用される
    - 内部は SMF もしくは MMF の光ファイバ
    - プラガブル・トランシーバと同じコネクタを使用し、各ケーブル端で電気から光への変換を行う
      - 40GE、100GE では QSFP 終端、10GE、25GE では SFP 終端する
  - DAC
    - 直結銅線ケーブル
    - AOC と同様に、回線速度によって QSFP、SFP で終端される
    - DAC に比較して、AOC ケーブルは伝送距離が長くて消費電力が少なく、軽量である
      - しかし、コストは高く、光ファイバは銅線よりも損傷しやすいという難点もある
- IDF、MDF
  - IDF(Intermediate Distribution Flame)
    - 各フロアの配線盤
    - 各フロアに設置され、フロアに設置したケーブルを収容し、幹線ケーブルに接続する機器
  - MDF(Main Distribution Flame)
    - 主配線盤
    - IDF の上流に接続し、企業やビル内のすべてのケーブルを収容する機器
    - 機能は IDF と同じだが、MDF の方が規模が大きい
- 用語メモ
  - チャネル損失と最大距離
    - チャネル損失: 機器間の最大損失値、この損失値を上回る損失になると伝送を保証できない
    - 最大距離: 伝送を保証できる最大の距離
    - 損失がチャネル損失値よりも少なく、最大距離よりも機器間の距離が短くないと伝送は保証されない
- 参考
  - 100 ギガ時代の LAN 配線
    - https://toe.bbtower.co.jp/20170105/1187/
    - https://toe.bbtower.co.jp/20170413/1513/
    - https://toe.bbtower.co.jp/20170727/2144/

## プロトコル

- Segment Routing
  - SRv6
    - IPv6 のヘッダを利用して、SegmentRouting を実現する技術
  - SRLB
    - Segment Routing を利用した、ロードバランサ
    - file:///C:/Users/owner/Downloads/2017-ICDCS-SRLBThePowerofChoicesinLoadBalancingwithSegmentRouting.pdf
  - 参考
    - https://www.janog.gr.jp/meeting/janog40/program/sr
    - https://www.janog.gr.jp/meeting/janog40/application/files/2415/0051/7614/janog40-sr-kamata-takeda-00.pdf

## 雑多

- ADC(Application Delivery Controller)
  - ロードバランサ、Firewall, TLS 終端などのフロントエンド前段の機能を兼ね備えた機器
- パケット光統合トランスポート装置
  - パケットスイッチ部と光スイッチ部を統合した装置
  - 製品
    - NEC SpectralWave DW7000
- パッチパネル
  - ラックの前部分についてるやつ
- CLOS/EVPN + VXLAN
- ポートミラーリング
  - DDoS Detection
  - FireWall
- ポートチャネル
  - 複数のポートでもう 1 台の装置と接続し、接続した複数のポートをチャネルグループという仮想リンクで 1 つに束ねる機能
  - ポート帯域の拡張と冗長性を確保できる
- Pod
  - ネットワーク用語では、TOR スイッチを束ねた単位
- STP(Spanning Tree Protocol)
  - L2 の冗長構成において発生するループを、論理的に単一経路にして冗長化するためのプロトコル
  - また、アクティブな単一経路が障害で使えなくなった場合、自動で別の経路に切り替える
- VSS
  - http://www.infraexpert.com/study/catalyst14.html
- 渡り線（渡り配線）
  - 冗長構成のために横のスイッチ同士(主に L2)をつなげるような配線のこと
- HSRP(Hot Standby Routing Protocol)
  - デフォルトゲートウェイを冗長化するためのシスコ独自のプロトコル
  - 仮想 IP アドレスをデフォルトゲートウェイとして使用し、アクティブルータがダウンした場合にスタンバイルータでその仮想 IP を引き継ぐ
- OSPF(Open Shortest Path First)
  - リンクステート型ルーティングプロトコル
- BGP(Border Gateway Protocol)
  - AS Path Prepend
    - ある IP へのルートが複数ある場合は、AS Path が少ないルートを優先するが、明示的に特定ルートへの AS Path 数を増やすことでそのルートの優先度を下げることができる
    - メンテなどでトラフィックを他のノードへ寄せる時によく利用する
  - Local Preference 属性
    - Local Preference 属性を操作することで優先パスを操作することができる
    - 内部 AS の隣接ノードに対して、外部 AS への優先パスを示す
    - デフォルト値は 100 で、高い値を持つパスが優先される
    - ベストパスの計算はパス数よりも Local Preference の方が優先される
    - Switch の Graceful Shutdown 時には、Local Preference を下げて、自身への優先順位を下げてから Shutdown する
  - MED 属性
    - MED 属性を操作することで優先パスを操作することができる
    - 外部 AS の隣接ノードに対して、自身の AS 内への優先パスを示す
    - デフォルト値は 0 で、低い値を持つパスが優先される
- BGP Flowspec
  - サービスチェイニングするためのフロールールを BGP で設定する?
- サービスチェイニング
  - サービスプールを用意しておき、届いたパケットを種類によって各サービスに通して処理する
  - パケットによってはファイアウォールや、DDoS フィルタを通したりする

# ShowNet

- 2018
  - https://www.interop.jp/2018/images/shownet/shownet_topology.pdf

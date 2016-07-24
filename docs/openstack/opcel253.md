# OPCEL 253

# 253.1 ネットワーキングサービス (Neutron)

## 概要
* VMが接続するネットワークを提供するサービス

## プロバイダネットワーク
* VMのネットワークを作成するためのプロバイダを定義・作成しておくことで、管理者はこのプロバイダを利用して、VM用のネットワークを作成できる。
* プロバイダの種類は、フラットネットワークと仮想ネットワーク
* プロバイダの実装(ドライバ)は、linuxbridge, OVSなどがある

## Openvswitch
* NetFlow、OpenFlow、および sFlow をサポートする仮想ネットワークへのスイッチングサービスを提供する
* Open vSwitch は、STP、LACP、802.1Q VLAN タグ付けなどのレイヤー 2 (L2) 機能のサポートにより、物理スイッチとの統合も可能
* GREトンネリング、VXLANトンネリングによる仮想ネットワークのサポートしている
```
# コマンド
ovs-vsctl show
ovs-vsctl add-br [bridge]
ovs-vsctl add-port [bridge] [interface]
ovs-vsctl list-ports [bridge]
```

## フラットネットワーク(Linuxbridge or OVS)
* linuxbridge-agent or openvswitch-agent: フラットネットワークのインターフェイスにブリッジをマッピングし、ブリッジにVMのtapをつなげる
* dhcp-agent: bridge-agentがマッピングしたブリッジで、dnsmasqを立ち上げIPの払い出しを行う(dhcpようのportを一つ使う）

## 仮想ネットワーク(OVS)
* Fixed IP : 仮想ネットワーク上でもつVMのIP
* Floating IP : VMを外部ネットワークにみせるため、Fixed IPへNATするためのIP
* network-node: openvswitch-agent : フラットネットワークにブリッジをマッピングし(br-ex)、外部ネットワーク・仮想ネットワークをつなげる
* network-node: l3-agent          : 仮想ネットワーク上での仮想ルータの作成・変更・削除を行う
    * 仮想ルータはVMのゲートウェイとしてふるまう
    * VM通信の仮想ネットワーク内部から他の内部ネットワークへのルーティング、外部ネットワークへ通信するためのNAT、Floating IPからFixed IPへのNATを行う(ip tables)
* network-node: dhcp-agent        : 仮想ネットワークごとにdnsmasqを立ち上げIPの払い出しを行う
* network-node: metadata-agent    : 仮想ネットワークごとにproxyを立ち上げ、VMがnovaのmetadata apiへアクセスする際のプロキシを行う
* compute-node: openvswitch-agent : network-nodeとBr-Tunnelingで接続したブリッジを作成し、ブリッジにVMのtapをつなげる
* dvr                             : 仮想ルータを各compute上に置く構成
* l3ha(vrrp)                      : 複数の仮想ルータを複数のネットワークノードに分散配置し、アクティブスタンバイさせる（冗長性の担保のみできる）


* Network Namespace
dhcpとrouterにはそれぞれnetnsが切られており、以下のようにipコマンドで確認できる
``` bash
$ ip netns
qdhcp-
qrouter-xxx

$ ip netns exec qrouter-xxx bash
$ ip r
```

## セキュリティグループ
VM起動時にセキュリティグループを指定することで、VMへのACLをiptablesなどで管理する
指定がない場合は、defaultセキュリティグループが設定される

## FWaaS


## LBaaS


## OpenDaylight
SDN

## コマンド
| neutron | openstack | 説明 |
| --- | --- | --- |
| Floating IP | | |
| neutron floatingip-list                  | | |
| neutron floatingip-show                  | | |
| neutron floatingip-create                | | |
| neutron floatingip-delete                | | |
| neutron floatingip-asspciate             | | |
| neutron floatingip-dissasociate          | | |
| Security Group | | |
| neutron security-group-list              | | |
| neutron security-group-show              | | |
| neutron security-group-create            | | |
| neutron security-group-delete            | | |
| neutron security-group-rule-list         | | |
| neutron security-group-rule-show         | | |
| neutron security-group-rule-create       | | |
| neutron security-group-rule-delete       | | |
| Network | | |
|  | | |
| Subnetwork | | |                                    | | |
|  | | |


# 253.2 コンピュートサービス (Nova)
## コマンド
| nova | openstack | 説明 |
| --- | --- | --- |
| Instance          | | |
| nova list         | | |
| nova show         | | |
| nova boot         | | |
| nova console-log  | | |
| nova delete       | | |
| nova stop         | | |
| nova suspend      | | |
| nova start        | | |
| nova reboot       | | |
| nova resume       | | |
| nova unpause      | | |
| nova rescue       | | |
| nova unrescure    | | |
| Flavor            | | |
| nova flavor-list  | | |
| Keypair           | | |
| nova keypair-add MY_KEY > MY_KEY.pem  | | キーペアを作成して、pemに保存する |
| nova keypair-list      | | |
| Other                  | | |
| nova image-list        | | |
| nova secgroup-list     | | |
| nova net-list          | | |
| nova floating-ip-list  | | |
| nova volume-list       | | |


# 253.3 ベアメタルプロビジョニング (Ironic)
* PXE,DHCP,NBP,TFTP,IPMIなどの既存技術を使ってプロビジョニングする
* 物理マシンの電源制御、OSのプロビジョニング、使用後のディスク消去、BIOS/ファームウェアのアップデート、ノードの管理が可能です
* UEFIおよびローカルブートプロパティを含む、ハードウェアノード用のFlavor

## コマンド
| ironic | openstack | 説明 |
| --- | --- | --- |
| ironic node-create    | | ベアメタルノードの追加
| ironic node-delete    | | ベアメタルノードの削除
| ironic node-list      | | ノードの一覧を表示
| ironic-python-agent   | | ディスカバリ、使用後のディスクデータの消去、BIOS・ファームウェアのアップデート
| ironic-neutron-plugin | | neutron-networkの利用

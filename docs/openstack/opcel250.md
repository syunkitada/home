# OPCEL 250

* [出題範囲](https://opcel.org/examarea)
* [受験方法](https://opcel.org/registration)


# 250.1 クラウドコンピューティングの概念
## 用語
* IaaS: 仮想サーバ、仮想ネットワークインフラを提供(AWS, GCE)
* PaaS: アプリケーションを動作させるためのプラットフォームを提供(Heroku, GAE)
* SaaS: ソフトウェア機能を提供(Google Docs, Cybouze)
* パブリッククラウド: インフラ構築のコストとメンテナンスの手間を削減できる
* プライベートクラウド: 企業内に独自に所持・構築できる、重要な情報を安全に保管できる
* ハイブリッドクラウド: パブリッククラウドにもプライベートクラウドにもそれぞれ利点欠点はあるが、必要に応じてパブリックとして、プライベートとしても使い分できるクラウドのこと
* SLA: サービス品質保証、VM稼働率とか


# 250.2 OpenStack のアーキテクチャと設計
## Core サービス
* Keystone: 認証、トークン管理、endpoint 管理
* Horizon: WEB UI
* Glance: 仮想マシン、ベアメタルのイメージ管理、Cinderのスナップショットなどのリソースの格納
* Cinder: ブロックストレージ
* Swift: オブジェクトストレージ
* Neutron: ネットワーク管理
* Nova: VM 管理、プロビジョニング

## IaaS の追加サービス
* Ceilometer: 各リソースのメータリングサンプルの収集・提供
* Heat: オーケストレーション
* Ironic: ベアメタル
* Barbican: セキュアストレージ(パスワードや証明書を管理するためのもの)
* Designate: DNSaaS、nova や neutron と統合して自動でレコードの操作を行うこともできる
* Magnum: コンテナ(docker, kubernetes)のオーケストレーションエンジン、バックエンドはHeat
* Manila: 共有ストレージ

## SaaS の追加サービス
* Trove: DBaaS
    * 汎用イメージを使う場合はtrove-agentを起動イメージに追加することで必要なデータベースのインストール、セットアップを行ってくれる
* Sahara: Hadoop クラスタ管理
* Murano: アプリケーションカタログ
    * DashboardからMuranoのコンパネを開き、ボタンを押すだけで単純なアプリケーション環境のデプロイを行える
    * kubeやhttp, mysqlなどがデプロイできる
* Zaqar: メッセージキュー


# 250.3 OpenStack のインストレーションとデプロイメント
* DevStack
    * shellscriptベースの公式デプロイツール
    * 設定ファイル    : local.conf(推奨）, localrc(旧）
    * stack.sh        : デプロイ
    * unstack.sh      : 停止
    * clean.sh        : インストール済みの関連パッケージを削除
    * rejoin-stack.sh : 停止したOpenStack環境を再開
* PackStack
    * pappetベースのデプロイツール
    * デプロイの流れ
        * packstack --allinone             : all in oneのデプロイ
        * packstack --gen-answer-file=FILE : answer-file(設定ファイル）の生成
        * packstack --answer-file=FILE     : answer-fileを指定して実行
* RDO Manger
    * TripleOをベースにしている
    * Undercloud(Ironic)のデプロイから、Overcloud（ユーザランド）のデプロイをサポート
* Red Hat Enterprise Linux OpenStack Platform 6 (Foreman, Puppet)
    * Foreman OpenStack Manager
        * Webユーザインターフェイスを提供
        * デプロイにはPuppetが使用される
        * 追加で、DHCP, DNS, PXE, TFTPのサービスを提供可能
            * これらによりOSがインストールされてない物理システムのプロビジョニングも可能
        * デプロイの流れ
            * sh foreman_server.sh : foremanサーバのセットアップ
            * webダッシュボードからユーザ作成、ホスト登録、各種設定、デプロイ
* Ubuntu OpenStack (Landscape, MAAS, JuJu)
    * Landscape
        * Ubuntu向けのシステム管理ツール
        * ソフトウェアアップデート、パッケージ管理などを一元化して行える
        * モニタリング機能もあり、システムリソースの利用状況、ボトルネックの検出、パーフォーマンスチューニングができる
    * MAAS
        * 物理サーバのプロビジョニング
        * DHCP, DNS, PXEでノードを登録
    * JuJu
        * juju deploy                         : アプリケーションの
        * juju add-relation                   : サービス同士を関連づける
        * juju expose                         : サービスを公開
        * juju status                         : サービスの稼働状況を確認
        * juju ssh 'machine'                  : サービスにSSH接続
        * juju destroy-environment 'envname'  : Juju環境の削除
* Ubuntu OpenStack Installer
    * MAAS, JuJuを使ったデプロイツール
    * all in one  : ホストにLXCを構築して、その上にLinux KVM環境を作り、3つの仮想マシン(controller, compute, network)にOpenStackの各コンポーネントをインストールする
    * マルチノード: ノードの管理にmaasを使い、 jujuでデプロイする
    * openstack-install : デプロイ
    * openstack-install --openstack-release [version] : version指定してデプロイ
    * openstack-status  : デプロイ状況の確認
* その他デプロイ
    * SUSE OpenStack Cloud 5 (Crowbar, Chef)
    * Rackspace Private Cloud (Ansible)
    * HP Helion
    * Mirantis FUEL
    * Chef for OpenStack(Chef)
* 手動デプロイの流れ
    * パッケージインストール
        * pip install -r requirements.txt
        * pip install python-openstack-client
        * python setup.py install
    * 設定ファイルの編集
    * DBの同期
        * cinder-manage
            * cinder-manage db sync
        * glance-manage
            * glance-manage db_sync
        * keystone-manage
            * keystone-manage db_sync
        * neutron-db-manage
            * neutron-db-manage upgrade head
        * nova-manage
            * nova-manage db sync
            * nova-manage api_db sync(mitaka)
    * サービス起動

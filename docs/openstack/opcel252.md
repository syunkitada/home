# OPCEL 252

# 252.1 イメージサービス (Glance)

glance image-create
glance image-delete
glance image-update
glance image-show
glance image-list
glance image-download


## glance-cache
http://docs.openstack.org/developer/glance/cache.html

glance-cache-cleaner    | glanceキャッシュのクリーンアップ
glance-cache-pruner     | キャッシュが一定サイズを超えていたら最近使用されていないキャッシュを捨てる
glance-cache-manager    | glanceキャッシュの管理
glance-cache-prefetcher | キャッシュ予約キューに入っているイメージのキャッシングを実施する
                        | キャッシュ予約キューにイメージを入れるには、APIをりようするか、glance-cache-manageコマンドを実行する


# 252.2 イメージの作成
## cloud-init
/etc/cloud/cloud.cfg, /etc/cloud/cloud.cfg.d 内のファイルを書き換えることで、
rootユーザでのログインやパスワード認証を許可したり、デフォルトユーザを定義したり、任意のパッケージインストールなどができる

VMにcloud-initが仕込まれていると、VMの起動時に公開鍵などのファイル(metadata)をnovaからダウンロード設定してくれる、
これをNetworkNamespaceで分離されているネットワークでも実現するのがmetadata-agent
http://d.hatena.ne.jp/pyde/20130914/p1


## qemu-image
qemu-image でqcow2形式にするには
qemu-image convert -c -f raw -O qcow2 original.img resize.qcow2



# 252.3 ブロックストレージ (Cinder)
## コマンド
cinder volume-list
cinder list
cinder show
cinder create
cinder delete
cinder snapshot-list
cinder snapshot-delete
cinder backup-list
cinder backup-show
cinder backup-create
cinder backup-restore
cinder backup-delete
nova volume-attach vm volume
nova volume-detach vm volume



# 252.4 オブジェクトストレージ (Swift)

webサーバのディレクトリインデックス表示ができる
swift post -m 'web-listings: true' public

## コマンド
swift post <container>
swift delete <container>
swift list
swift stat <container>
swift upload <container> <file_or_directory>
swift download <container> <object>
swift list <container>
swift delete <container> <object>
openstack container
openstack object

## ビルダーファイル
swiftはアカウント情報はアカウントサーバ、コンテナ情報はコンテナサーバ、オブジェクト情報はオブジェクトサーバで管理しています。
これらの情報はビルダーファイルという設定ファイルに記述されており、swift-ring-builderコマンドを使って設定の確認や変更が可能。

swift-ring-builder container.builder
変更した設定を反映するには、

## リングファイル
Swiftではホストがどういったサービスを提供する、オブジェクトをどのように分散配置するといった設定情報をリングと呼んでおり、リングファイルで管理しています。
リングファイル作成時に指定するレプリカ数は追加するデバイス数に依存します。レプリカ数>=デバイス数

swift-ring-builder <builder_file> create <part_power> <replicas> <min_part_hours>
builder_file | account.builder, container.builder, object.builder
part_power 利用するパーティション数を決定するためのパラメータ
replicas   1つのオブジェクトの複製を作る数
min_part_hours  パーティションの複数回の移動を制限する時間

swift-ring-builder account.builder create 10 2 1
swift-ring-builder container.builder create 10 2 1
swift-ring-builder object.builder create 10 2 1

## デバイスの追加と削除
リングを作成したら、このリングにデバイスを追加思案す。
swift-ring-builder <builder_file> add <device> <option>

swift-ring-builder <builder_file> add rlz1-<account-server_ip:6002 or container-server_ip:6001 or object-server_ip:6000>/xfs1 100
swift-ring-builder <builder_file> remove rlz1-....

swiftはストレージをゾーンで管理します。ゾーンにストレージがあればあるほど読み書きのパフォーマンスが向上する。
オブジェクトがswiftのストレージノードにアップロードされると、そのゾーンに属するストレージの一つにオブジェクトが保管されます。
オブジェクトが保管されるとレプリカの設定に従って別のゾーンに属したストレージノードにオブジェクトのレプリカが作成されます。


デバイスを追加・削除したあとは、
swift-ring-builder <builder-file> rebalance

を実行すると、リングファイルが作成され、これが実際にデータ格納ようディスクの管理をしているファイルとなります。
これにしたがってswiftはオブジェクトを各デバイスに配置・複製します。

account.builder
account.ring.gz
container.builder
container.ring.gz
object.builder
object.ring.gz


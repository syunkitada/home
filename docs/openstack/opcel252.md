# OPCEL 252

# 252.1 イメージサービス (Glance)
## コマンド
| glance | openstack | 説明 |
| glance image-create --disk-format qcow2 --container-format bare --name [name] --file [file] | openstack image create --disk-format qcow2 --container-format bare --file [file] [name] | |
| glance image-delete [image]                     | openstack image delete [option]            | |
| glance image-update [option] [image]            | openstack image set [option] [image]       | |
| glance image-show [image]                       | openstack image show [image]               | |
| glance image-list                               | openstack image list                       | |
| glance image-download --file [file] [image_id]  | openstack image save --file [file] [image] | |
| [glance-cache](http://docs.openstack.org/developer/glance/cache.html) | | |
| glance-cache-cleaner    | glanceキャッシュのクリーンアップ
| glance-cache-pruner     | キャッシュが一定サイズを超えていたら最近使用されていないキャッシュを捨てる
| glance-cache-manager    | glanceキャッシュの管理
| glance-cache-prefetcher | キャッシュ予約キューに入っているイメージのキャッシングを実施する。キャッシュ予約キューにイメージを入れるには、APIをりようするか、glance-cache-manageコマンドを実行する

## 設定ファイル
* glance-api.conf
* glance-cache.conf
* glance-registry.conf
* glance-scrubber.conf
* schema-image.json


# 252.2 イメージの作成
* [イメージの変更](http://docs.openstack.org/ja/image-guide/modify-images.html)
* guestfish
    * 仮想マシンイメージ内のファイルを編集できる
    * guestfish --rw -a centos63_desktop.img
    * 専用のシェル上で操作する
* guestmount, guestumount
    * 仮想マシンイメージをマウントして編集できる
    * guestmount -a centos63_desktop.qcow2 -m /dev/vg_centosbase/lv_root --rw /mnt
* libguestfs tools (virt-*)
    * virt-edit: イメージ内のファイルを編集する
    * virt-df: イメージ内の空き容量を表示
    * virt-resize: イメージの容量を変更
    * virt-sysprep: イメージを配布する準備(SSHホスト鍵の削除、MACアドレスの削除、ユーザの削除）
    * virt-sparsify: イメージをスパース化できる
    * virt-p2v: 物理マシンをKVMで動作するイメージに変換
    * virt-v2v: XenやVMwareイメージをKVMのイメージに変換
* cloud-init
    * VMにcloud-initが仕込まれていると、VMの起動時に公開鍵などのファイル(metadata)をnovaからダウンロード設定してくれる
    * 仮想ネットワークでmetadata利用するにはmetadata-agent(novaへのプロキシ）を利用する
    * /etc/cloud/cloud.cfg, /etc/cloud/cloud.cfg.d 内のファイルを書き換えることで、rootユーザの設定などデフォルトの設定を組み込むことができる
* cloudbase-init
    * windowsのcloud-init
* qemu-img
    * rawからqcow2へのコンバート: qemu-image convert -c -f raw -O qcow2 original.img resize.qcow2
* losetup, kpartx
    * losetup -f : 未使用のloopデバイスを見つける
    * losetup [loop dev] [raw img] : loopデバイスをrawイメージに関連付ける
    * mount /dev/loop0 /mnt : mntする
    * kpartx -av /dev/loop0 : イメージが複数のパーティションを持つ場合、パーティションを別々のデバイス(/dev/mapper/loop0p1)として認識させる
    * imount /dev/mapper/loop0p1 /mnt/image : ルートファイルシステムに対応するパーティションをマウントする
    * umount /mnt/image; rmdir /mnt/image; kpartx -d /dev/loop0; losetup -d /dev/loop0 : クリーンアップ
* disk-image-create
    * [イメージ作成のサポートツール](http://docs.openstack.org/ja/image-guide/create-images-automatically.html)
    * disk-image-create ubuntu vm : ubuntuのイメージを作成
* LVM ユーティリティ
    * Logical Volume Manager
    * ディスクパーティションを管理する
* qemu-nbd
    * modprobe nbd max_part=16 : qcow2 イメージをマウントするために、 nbd (ネットワークブロックデバイス) カーネルモジュールを読み込む必要がある
    * qemu-nbd -c /dev/nbd0 image.qcow2
    * partprobe /dev/nbd0
* /etc/udev/
    * デバイスの識別方法およびデバイス名の作成方法を決定するルール・ファイル
    * イメージを作る際にMACアドレスなど一部消す必要がある


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


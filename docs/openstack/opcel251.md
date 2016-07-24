# OPCEL 251

# 251.1 アイデンティティサービス、認証と認可(Keystone)

## ドメイン、プロジェクト(テナント)、ユーザ、ロール
* ドメイン: プロジェクトを含み、管理する単位
* プロジェクト: ユーザを含み、管理する単位
    * テナントとも呼ぶ
* ユーザ: 個人
* ロール: ユーザに対して追加できる権限
    * 基本的にはadmin、Memberのみ

## 認証方式
* パスワード: ユーザ名、パスワード、プロジェクトにより認証する
* トークン: パスワード認証などでトークンを発行し、そのトークンにより認証する
* 証明書: 証明書により認証する

## policy.json
* /etc/[service]/policy.jsonによって、ロール・プロジェクト・ユーザごとの機能権限を設定できる
* 設定単位
    * role:admin_required       : adminのみ
    * role:demo                 : demoロールのみ
    * user_id:%(user_id)s       : 指定したユーザのみ
    * project_id:%(project_id)s : 指定したプロジェクトのみ

```
例:
{
    "context_is_admin": "role:admin",
    "admin_or_owner": "is_admin:True or project_id:%(project_id)s"
    "default": "role:admin_or_owner",
    ...
    "compute:create": "",
    "compute:create:forced_host": "is_admin:True",
    ...
}
```

## サービスカタログとリージョン
* keystoneにより、各サービスカタログ、そのエンドポイントが一元管理されている
* リージョンは、サービスエンドポイントを含み、管理する単位
    * 一つのリージョンに対して同サービスのエンドポイントを複数登録できない
    * リージョンを分ければ、同サービスを登録可能
    * リージョンごとに各種サービスリソースの管理も分かれる

## コマンド
| keystone | openstack | 説明 |
| --- | --- | --- |
|ユーザ |                                                                    | |
|  | openstack user list                                                | |
|  | openstack user role list [user]                                    | |
|  | openstack user show [user]                                         | |
|  | openstack user create [user] --password [password]                 | |
|  | openstack user delete [user]                                       | |
|  | openstack user set [option] [user]                                 | |
|プロジェクト  |                                                                    | |
|  | openstack project list                                             | |
|  | openstack project show [project]                                   | |
|  | openstack project create [project]                                 | |
|  | openstack project delete [project]                                 | |
|  | openstack proejct set [option] [project]                           | |
|ドメイン  |                                                                    | |
|  | openstack domain list                                              | |
|  | openstack domain show [domain]                                     | |
|  | openstack domain create [domain]                                   | |
|  | openstack domain delete [domain]                                   | |
|  | openstack domain set [option] [domain]                             | |
|ロール |                                                                    | |
|  | openstack role list                                                | |
|  | openstack role show [role]                                         | |
|  | openstack role create [role]                                       | |
|  | openstack role delete [role]                                       | |
|  |                                                                    | |
|  | openstack user role list [user]                                    | |
|  | openstack role add --user [user] --project [project] [role]        | |
|  | openstack role remove --user [user] --project [project] [role]     | deleteと混在しないように注意 |
| サービス |                                                                    | |
|  | openstack service list                                             | |
|  | openstack service show [service]                                   | |
|  | openstack service create --name [name] [type]                      | |
|  | openstack service delete [service]                                 | |
|  | openstack service set [option] [service]                           | |
| エンドポイント |                                                                    | |
|  | openstack endpoint list                                            | |
|  | openstack endpoint show [endpoint_id]                              | |
|  | openstack endpoint create --publicurl [url] --internalurl [url] --adminurl [url] --region [region] [type] | |
|  | openstack endpoint delete [endpoint_id]                            | |
|  | openstack endpoint set [option] [endpoint_id]                      | |
| カタログ |                                                                    | |
|  | openstack catalog list                                             | |
|  | openstack catalog show [servicename]                               | |
| Quota |                                                                    | |
|  | openstack quota show [project]                                     | |
|  | openstack quota set [option] [project]                             | |
| その他 |                                                                    | |
|  | openstack limits show [option]                                     | ? |
|  | openstack usage list [option]                                      | ? |
|  | openstack usage show [option]                                      | ? |



# 251.2 ダッシュボード(Horizon)とRESTful API
## HorizonとRESTful API
* local_settings.pyにkeystoneのエンドポイントを設定
    * OPENSTACK_KEYSTONE_URL = "http://localhost:5000/v3"
* keystoneで認証、keystoneからのサービスカタログの取得、各種サービスのRESTful APIをたたいてリソース操作を行う

## Horizonのカスタマイズ
* [Customizing Horizon](http://docs.openstack.org/developer/horizon/topics/customizing.html)
* ダッシュボードとパネルを追加
    * mkdir openstack_dashboard/dashboards/dashbord1/
    * mkdir openstack_dashboard/dashboards/dashbord1/panel1
* ブランド設定
    * openstack_dashboard/templates/header/_brand.html
    * openstack_dashboard/static/dashboard/img/logo.png

# 251.3 テレメトリ(Ceilometer)
## 各種サービスデーモンの役割
* ceilometer-polling-agent: 各ノードで起動し、notification データを収集しキューに流す
    * ceilometer-agent-compute, ceilometer-agent-central, ceilometer-agent-ipmi などがある
* ceilometer-notification-agent: キューからnotification データを収集しsampleデータに加工しキューに流す
* ceilometer-collector: キューからsampleデータを収集し、データベースに格納する
* ceilometer-api: データベースからsampleデータを提供する
* ceilometer-alarm-evaluator: apiからsampleデータを取得して評価し、alarmの閾値を超えればalarm-notifierに中継する
* ceilometer-alarm-notifier: alarm発生時の動作に従い、アクションを起こす

## コマンド
| ceilometer | openstack | 説明 |
| --- | --- | --- |
| アラーム                                                        | | |
| ceilometer alarm-list                                           | | |
| ceilometer alarm-show                                           | | |
| ceilometer alarm-create                                         | | |
| ceilometer alarm-delete                                         | | |
| メータ(測定項目)                                                | | |
| ceilometer meter-list                                           | | |
| サンプル(測定したデータ)                                        | | |
| ceilometer sample-list -m [meter] -q [resource_id=instance_id]  | | -m でメータを指定、-q で絞り込み  |
| 管理コマンド                                                    | | |
| ceilometer-dbsync                                               | | |


# 251.4 オーケストレーション (Heat)

## 各種サービスデーモンの役割
* heat-api
    * api
* heat-api-cfn
    * AWS CloudFormation (CFN)テンプレートを解釈
* heat-engine
    * リソースの操作

## オーケストレーションユーザ
* オーケストレーションユーザの認証にtrustを使用する
* heat-engineがリソースを操作する際の認証方式のこと

## コマンド
| heat | openstack | 説明 |
| --- | --- | --- |
| スタック | | |
| heat stack-list                     | | |
| heat stack-show [stack]             | | |
| heat stack-create -f [file] [stack] | | |
| heat stack-delete [stack]           | | |
| リソース | | |
| heat resource-list [stack]          | | |
| 管理コマンド | | |
| heat-manage db_sync                 | | |


## CFNテンプレート
```
heat_template_version: 2015-04-30

description: Simple template to deploy a single compute instance

resources:
  my_instance:
    type: OS::Nova::Server
    properties:
      image: hoge
      flavor: flavor1
      networks:
        - network: piyo
```

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
|  | openstack user list                                                | |
|  | openstack user role list [user]                                    | |
|  | openstack user show [user]                                         | |
|  | openstack user create [user] --password [password]                 | |
|  | openstack user delete [user]                                       | |
|  | openstack user set [option] [user]                                 | |
|  |                                                                    | |
|  | openstack project list                                             | |
|  | openstack project show [project]                                   | |
|  | openstack project create [project]                                 | |
|  | openstack project delete [project]                                 | |
|  | openstack proejct set [option] [project]                           | |
|  |                                                                    | |
|  | openstack domain list                                              | |
|  | openstack domain show [domain]                                     | |
|  | openstack domain create [domain]                                   | |
|  | openstack domain delete [domain]                                   | |
|  | openstack domain set [option] [domain]                             | |
|  |                                                                    | |
|  | openstack role list                                                | |
|  | openstack role show [role]                                         | |
|  | openstack role create [role]                                       | |
|  | openstack role delete [role]                                       | |
|  |                                                                    | |
|  | openstack user role list [user]                                    | |
|  | openstack role add --user [user] --project [project] [role]        | |
|  | openstack role remove --user [user] --project [project] [role]     | deleteと混在しないように注意 |
|  |                                                                    | |
|  | openstack service list                                             | |
|  | openstack service show [service]                                   | |
|  | openstack service create --name [name] [type]                      | |
|  | openstack service delete [service]                                 | |
|  | openstack service set [option] [service]                           | |
|  |                                                                    | |
|  | openstack endpoint list                                            | |
|  | openstack endpoint show [endpoint_id]                              | |
|  | openstack endpoint create --publicurl [url] --internalurl [url] --adminurl [url] --region [region] [type] | |
|  | openstack endpoint delete [endpoint_id]                            | |
|  | openstack endpoint set [option] [endpoint_id]                      | |
|  |                                                                    | |
|  | openstack catalog list                                             | |
|  | openstack catalog show [servicename]                               | |
|  |                                                                    | |
|  | openstack quota show [project]                                     | |
|  | openstack quota set [option] [project]                             | |
|  |                                                                    | |
|  | openstack limits show [option]                                     | ? |
|  |                                                                    | |
|  | openstack usage list [option]                                      | ? |
|  | openstack usage show [option]                                      | ? |



# 251.2 ダッシュボード(Horizon)とRESTful API


# 251.3 テレメトリ(Ceilometer)
## コマンド
ceilometer meter-list    | 測定項目一覧
ceilometer sample-list -m meter -q resource_id=instance_id  | 測定項目のデータを一覧表示、-q で絞り込み



# 251.4 オーケストレーション (Heat)

## コマンド
heat stack-create
heat stack-delete
heat stack-list

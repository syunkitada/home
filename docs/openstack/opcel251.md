# OPCEL 251

# 251.1 アイデンティティサービス、認証と認可(Keystone)

## コマンド
| keystone | openstack | 説明 |
| --- | --- | --- |
|          | openstack quota show admin                                         | quota の詳細表示
|          | openstack quota set --cores 8 admin                                | quota の更新
|          |                                                                    |
|          | openstack project list                                             | project 一覧
|          | openstack project show                                             | project の詳細表示
|          | openstack project create                                           |
|          | openstack project delete                                           |
|          | openstack proejct set                                              |
|          |                                                                    |
|          | openstack user list                                                |
|          | openstack user show                                                |
|          | openstack user create                                              |
|          | openstack user delete                                              |
|          | openstack user set                                                 |
|          |                                                                    |
|          | openstack role list                                                |
|          | openstack role show                                                |
|          | openstack role create                                              |
|          | openstack role delete                                              |
|          | openstack role set                                                 |
|          |                                                                    |
|          | openstack user role list                                           |
|          | openstack role add                                                 |
|          | openstack role remove deleteと注意(remove はユーザからroleを外す） |
|          |                                                                    |
|          | openstack endpoint show <servicename>                              |

## バックエンド
LDAPをバックエンドに使うとことで、既存のLDAPアカウントを使ってOpenStackにログオンすることができる

## policy.json
* ロール・プロジェクト・ユーザごとの機能制限を設定できる
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

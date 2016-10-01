# manila

## コマンド
``` bash
$ manila create nfs 1
+-----------------------------+--------------------------------------+
| Property                    | Value                                |
+-----------------------------+--------------------------------------+
| status                      | creating                             |
| share_type_name             | default_share_type                   |
| description                 | None                                 |
| availability_zone           | None                                 |
| share_network_id            | None                                 |
| share_server_id             | None                                 |
| host                        |                                      |
| access_rules_status         | active                               |
| snapshot_id                 | None                                 |
| is_public                   | False                                |
| task_state                  | None                                 |
| snapshot_support            | True                                 |
| id                          | a80034f6-51b0-490d-845e-3360e1c455f7 |
| size                        | 1                                    |
| name                        | None                                 |
| share_type                  | dfd5beaf-464c-4011-a0a8-5e13a6048f3f |
| has_replicas                | False                                |
| replication_type            | None                                 |
| created_at                  | 2016-09-22T01:27:35.000000           |
| share_proto                 | NFS                                  |
| consistency_group_id        | None                                 |
| source_cgsnapshot_member_id | None                                 |
| project_id                  | f05600e093a842039ee0c2e7b40c5f05     |
| metadata                    | {}                                   |
+-----------------------------+--------------------------------------+

$ manila list
+--------------------------------------+------+------+-------------+-----------+-----------+--------------------+----------------------------------------+-------------------+
| ID                                   | Name | Size | Share Proto | Status    | Is Public | Share Type Name    | Host                                   | Availability Zone |
+--------------------------------------+------+------+-------------+-----------+-----------+--------------------+----------------------------------------+-------------------+
| a80034f6-51b0-490d-845e-3360e1c455f7 | None | 1    | NFS         | available | False     | default_share_type | centos7-hostname@lvm01#lvm-single-pool | nova              |
+--------------------------------------+------+------+-------------+-----------+-----------+--------------------+----------------------------------------+-------------------+

$ manila access-allow a80034f6-51b0-490d-845e-3360e1c455f7 ip 192.168.122.50
+--------------+--------------------------------------+
| Property     | Value                                |
+--------------+--------------------------------------+
| share_id     | a80034f6-51b0-490d-845e-3360e1c455f7 |
| access_type  | ip                                   |
| access_to    | 192.168.122.50                       |
| access_level | rw                                   |
| state        | new                                  |
| id           | 519ce038-de04-4714-9b5b-c77203ea8344 |
+--------------+--------------------------------------+

$ cat /etc/exports
/var/lib/manila/mnt/share-f6cabc2b-a4fd-4bc6-b2d4-27710fba5889  192.168.122.50(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,no_pnfs,anonuid=65534,anongid=65534,sec=sys,rw,secure,no_root_squash,no_all_squash)


$ manila show a80034f6-51b0-490d-845e-3360e1c455f7
+-----------------------------+--------------------------------------------------------------------------------------+
| Property                    | Value                                                                                |
+-----------------------------+--------------------------------------------------------------------------------------+
| status                      | available                                                                            |
| share_type_name             | default_share_type                                                                   |
| description                 | None                                                                                 |
| availability_zone           | nova                                                                                 |
| share_network_id            | None                                                                                 |
| export_locations            |                                                                                      |
|                             | path = 192.168.122.50:/var/lib/manila/mnt/share-f6cabc2b-a4fd-4bc6-b2d4-27710fba5889 |
|                             | preferred = False                                                                    |
|                             | is_admin_only = False                                                                |
|                             | id = 2bafcd26-506e-400a-b4ac-e6e7577076a4                                            |
|                             | share_instance_id = f6cabc2b-a4fd-4bc6-b2d4-27710fba5889                             |
| share_server_id             | None                                                                                 |
| host                        | centos7-hostname@lvm01#lvm-single-pool                                               |
| access_rules_status         | active                                                                               |
....

$ sudo mount -t nfs 192.168.122.50:/var/lib/manila/mnt/share-f6cabc2b-a4fd-4bc6-b2d4-27710fba5889 /mnt
```

# Vitess


## Getting Started
* https://vitess.io/getting-started/

### etcd-operatorをインストール
* https://github.com/coreos/etcd-operator/blob/master/doc/user/install_guide.md
    * 公式通りでOK

```
$ kubectl get pod
NAME                             READY     STATUS    RESTARTS   AGE
etcd-operator-69b559656f-rvx4t   1/1       Running   0          4h
```


### vtctlclientをインストール
```
$ wget https://dl.google.com/go/go1.10.1.linux-amd64.tar.gz
$ sudo tar -C /usr/local -xzf go1.10.1.linux-amd64.tar.gz
$ export PATH=$PATH:/usr/local/go/bin
$ GOPATH=$HOME/go
$ go get vitess.io/vitess/go/cmd/vtctlclient

$ go/bin/vtctlclient -h
...
```

### exampleを試す
* $HOME/go/src/vitess.io/vitess/examples/kubernetes にexampleがある
* https://vitess.io/getting-started/
    * 基本的には公式通りでOK
    * vtctldなどが動かない場合
        * 実行オプションが間違って起動できてない場合があるので、イメージを書き換える
            * examples/kubernetesディレクトリ内にある、テンプレート(vtctld-controller-template.yamlなど)のイメージを書き換える
            * "image: {{vitess_image}}" を "image: vitess/lite:v2.1" に書き換えた
        * CPU、メモリのリソース不足で動かない場合がある
            * テンプレートのresouceの項目を消して制限を外す

* ./kvtctl.sh 使ってもいいが、vtctlclientを直接使ってもOK

```
$ kubectl get svc
vtctld            ClusterIP      10.32.132.65    <none>        15000/TCP,15999/TCP                              3h
...

$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 help
```

* 中身はmysql
    * grpc経由でmysqlを叩いてる

```
$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 ExecuteFetchAsDba test-0000000100 "show tables"
+----------------------------+
| Tables_in_vt_test_keyspace |
+----------------------------+
| messages                   |
+----------------------------+

$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 ExecuteFetchAsDba test-0000000100 "SELECT * FROM messages"
+------+---------------------+--------------+
| page |   time_created_ns   |   message    |
+------+---------------------+--------------+
|   27 | 1523797279376063232 | testaaaa     |
|   27 | 1523797282238238208 | testaaaabbbb |
|   27 | 1523797295107198976 | wwww         |
+------+---------------------+--------------+


$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 ExecuteFetchAsDba test-0000000100 "show databases"
+--------------------+
|      Database      |
+--------------------+
| information_schema |
| _vt                |
| mysql              |
| performance_schema |
| sys                |
| vt_test_keyspace   |
+--------------------+

$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 ExecuteFetchAsDba test-0000000100 "select user,host from mysql.user;"
+-----------------+-----------+
|      user       |   host    |
+-----------------+-----------+
| orc_client_user | %         |
| vt_repl         | %         |
| mysql.sys       | localhost |
| root            | localhost |
| vt_allprivs     | localhost |
| vt_app          | localhost |
| vt_dba          | localhost |
| vt_filtered     | localhost |
+-----------------+-----------+


$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 ExecuteFetchAsDba test-0000000100 "show master status;"
+--------------------------+----------+--------------+------------------+-------------------------------------------+
|           File           | Position | Binlog_Do_DB | Binlog_Ignore_DB |             Executed_Gtid_Set             |
+--------------------------+----------+--------------+------------------+-------------------------------------------+
| vt-0000000100-bin.000001 |     3711 |              |                  | 84fe171a-4097-11e8-8022-e268083c86f0:1-10 |
+--------------------------+----------+--------------+------------------+-------------------------------------------+
```

* masterに対して、replica, rdonlyがslaveとして稼働している

```
$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 ListAllTablets test
test-0000000100 test_keyspace 0 master 10.200.204.19:15002 10.200.204.19:3306 []
test-0000000101 test_keyspace 0 replica 10.200.94.146:15002 10.200.94.146:3306 []
test-0000000102 test_keyspace 0 replica 10.200.112.18:15002 10.200.112.18:3306 []
test-0000000103 test_keyspace 0 rdonly 10.200.204.20:15002 10.200.204.20:3306 []
test-0000000104 test_keyspace 0 rdonly 10.200.112.19:15002 10.200.112.19:3306 []

$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 ExecuteFetchAsDba test-0000000102 "show slave status;" | awk -F '|' '{print $2 $3}'
         Slave_IO_State           Master_Host
 Waiting for master to send      10.200.204.19

$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 ExecuteFetchAsDba test-0000000101 "show slave status;" | awk -F '|' '{print $2 $3}'
         Slave_IO_State           Master_Host
 Waiting for master to send      10.200.204.19

$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 ExecuteFetchAsDba test-0000000103 "show slave status;" | awk -F '|' '{print $2 $3}'
         Slave_IO_State           Master_Host
 Waiting for master to send      10.200.204.19

$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 ExecuteFetchAsDba test-0000000104 "show slave status;" | awk -F '|' '{print $2 $3}'
         Slave_IO_State           Master_Host
 Waiting for master to send      10.200.204.19
```

* guestbookもexample/kubernetesの配下においてある
    * guestbook/main.py
        * webフレームワークはFlaskを利用
        * DBへのアクセスは、vtgate_clientを利用
            * 書き込み(INSERT)は、masterを利用して、読み込み(SELECT)はreplicaを利用している
            * 加えて、keyspaceを設定すれば、grpcがよしなにルーティングして処理してくれる


* masterをdeleteしてみる
```
$ kubectl delete pod vttablet-100
vttablet-100                     0/2       Terminating   2          3h
vttablet-101                     2/2       Running       2          3h
vttablet-102                     2/2       Running       2          3h
vttablet-103                     2/2       Running       2          3h
vttablet-104                     2/2       Running       2          3h

# guestbookは表示できるけど、書き込みできない
DatabaseError: ('VitessError', u'vtgate: http://vtgate-test-7gqx5:15001/: execInsertUnsharded: target: test_keyspace.0.master, used tablet: (alias:<cell:"test" uid:100 > hostname:"10.200.204.19" ip:"10.200.204.19" port_map:<key:"grpc" value:16002 > port_map:<key:"mysql" value:3306 > port_map:<key:"vt" value:15002 > keyspace:"test_keyspace" shard:"0" type:MASTER ), no connection for key 10.200.204.19,grpc:16002,mysql:3306,vt:15002 tablet alias:<cell:"test" uid:100 > hostname:"10.200.204.19" ip:"10.200.204.19" port_map:<key:"grpc" value:16002 > port_map:<key:"mysql" value:3306 > port_map:<key:"vt" value:15002 > keyspace:"test_keyspace" shard:"0" type:MASTER ', 'Execute', 2, 'Execute', 'keyspace=test_keyspace, not_in_transaction=False, sql=INSERT INTO messages (page, time_created_ns, message) VALUES (:page, :time_created_ns, :message), tablet_type=master')

# tablesではmasterいる
$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 ListAllTablets test
test-0000000100 test_keyspace 0 master 10.200.204.19:15002 10.200.204.19:3306 []
test-0000000101 test_keyspace 0 replica 10.200.94.146:15002 10.200.94.146:3306 []
test-0000000102 test_keyspace 0 replica 10.200.112.18:15002 10.200.112.18:3306 []
test-0000000103 test_keyspace 0 rdonly 10.200.204.20:15002 10.200.204.20:3306 []
test-0000000104 test_keyspace 0 rdonly 10.200.112.19:15002 10.200.112.19:3306 []
```

```
# 起動しなおす
$ ./vttablet-up.sh

# 新しいpod ipでtest-0000000100が参加し直した
$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 ListAllTablets test
test-0000000100 test_keyspace 0 replica 10.200.204.23:15002 10.200.204.23:3306 []
test-0000000101 test_keyspace 0 replica 10.200.94.146:15002 10.200.94.146:3306 []
test-0000000102 test_keyspace 0 replica 10.200.112.18:15002 10.200.112.18:3306 []
test-0000000103 test_keyspace 0 rdonly 10.200.204.20:15002 10.200.204.20:3306 []
test-0000000104 test_keyspace 0 rdonly 10.200.112.19:15002 10.200.112.19:3306 []

# masterを001 で再設定する
$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 InitShardMaster  -force test_keyspace/0 test-0000000101

$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 ListAllTablets test
test-0000000100 test_keyspace 0 replica 10.200.204.23:15002 10.200.204.23:3306 []
test-0000000101 test_keyspace 0 master 10.200.94.146:15002 10.200.94.146:3306 []
test-0000000102 test_keyspace 0 replica 10.200.112.18:15002 10.200.112.18:3306 []
test-0000000103 test_keyspace 0 rdonly 10.200.204.20:15002 10.200.204.20:3306 []
test-0000000104 test_keyspace 0 rdonly 10.200.112.19:15002 10.200.112.19:3306 []

# 000にもdbがreplicateされる
$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 ExecuteFetchAsDba test-0000000100 "show databases"
+--------------------+
|      Database      |
+--------------------+
| information_schema |
| _vt                |
| mysql              |
| performance_schema |
| sys                |
| vt_test_keyspace   |
+--------------------+

# しかし、中身が空
$ ~/go/bin/vtctlclient -server 10.32.132.65:15999 ExecuteFetchAsDba test-0000000100 "show tables;"
+----------------------------+
| Tables_in_vt_test_keyspace |
+----------------------------+
+----------------------------+

# guestbookからは書き込みは問題なくできるようになった
# 読み込みもできてるので、grpcが100は利用しないようにしてるみたい
```

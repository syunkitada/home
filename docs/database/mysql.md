# mysql


## User
```
# ユーザ作成と権限付与
CREATE USER IF NOT EXISTS 'hoge'@'%' IDENTIFIED BY 'hogepass'; GRANT ALL ON *.* TO 'hoge'@'%'; FLUSH PRIVILEGES;

# MySQL8から、GRANT時のIDENTIFIED BYでのパスワードは設定できなくなった
# GRANT ALL ON *.* TO 'hoge'@'%' IDENTIFIED BY 'hogepass';
```


## GTID Master-Slave 構成
``` reqlication user
SLAVE_USER=slave
SLAVE_PASSWARD=slavepass
MASTER_IP=172.16.100.121
PORT=3306

# Master: create user to replication
mysql -uroot -e "GRANT REPLICATION SLAVE ON *.* TO 'slave'@'172.16.100.0/255.255.255.0' IDENTIFIED BY 'slavepass'";

# Slave: setting master
mysql -uroot -e "
change master to
    master_host='${MASTER_IP}',
    master_port='${PORT}',
    master_user='${SLAVE_USER}',
    master_password='${SLAVE_PASSWORD}',
    master_auto_position=1;
"
```

* Master-Master構成について
    * 2つのMasterで互いにSlave設定を入れればよい
    * しかし、Master-Masterの同時書き込みは不整合が発生しやすいので非推奨


## GTID レプリケーション組み直し
```
# Slave: stop slave
$ sudo mysql -uroot -e 'stop slave;'

# Master: mysqldump and scp dump to slave
$ sudo mysqldump -uroot -q --all-databases --master-data > all.dump
$ sed -i "s/CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.*//g" all.dump
$ scp all.dump slavehost.com:


# Slave: drop databases except mysql, information_schema, and performance_schema
$ sudo mysql -uroot -e 'show databases;'
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sample             |
| sysbench           |
+--------------------+
$ sudo mysql -uroot -e 'drop database sample;'
$ sudo mysql -uroot -e 'drop database sysbench;'

# Slave: reset slave
$ sudo mysql -uroot -e 'reset slave;'

# Slave: if Master-Master, reset master before take in dump
$ sudo mysql -uroot -e 'reset master;'

# Slave: take in dump
$ sudo mysql -uroot < all.dump

# Master: if Master-Master
$ sudo mysql -uroot -e 'reset slave;'
$ sudo mysql -uroot -e 'start slave;'

# Check slave status
$ sudo mysql -uroot -e 'show slave status\G'
```


## Tips
* https://dev.mysql.com/doc/refman/5.7/en/optimize-overview.html
* server_idを確認する

```
mysql> show variables like '%server_id%';
```

* mysql.cnfの場所
```
mysql --help | grep my.cnf
                      order of preference, my.cnf, $MYSQL_TCP_PORT,
/etc/my.cnf /etc/mysql/my.cnf ~/.my.cnf
```

* mysqldumpに失敗する場合
    * データ量が多すぎてOOMでmysqlがダウンする場合がある
        * innodbのbufferを割り当てすぎた場合など
    * タイムアウトでコネクションが閉じる場合がある

```
show global variable like '%timeout%'
SET GLOBAL net_write_timeout=3600
SET GLOBAL net_read_timeout=3600
SET GLOBAL interactive_timeout=3600
SET GLOBAL wait_timeout=3600
```

# mysql



## memo
stop slave
reset slave
start slave



## Tips
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

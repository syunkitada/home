# DevStack

## セットアップ
* Doc: http://docs.openstack.org/developer/devstack/
* 環境: CentOS/RHEL 7
* メモリ: 6M (4Gだと余裕が無い）ディスク: 32G

``` bash
$ git clone https://github.com/openstack-dev/devstack.git
$ cd devstack
$ vim local.conf
$ ./stack.sh
```

## local.conf
``` bash
[[local|localrc]]
ADMIN_PASSWORD=adminpass
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD
SERVICE_TOKEN=a682f596-76f3-11e3-b3b2-e716f9080d50
```

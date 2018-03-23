# VPP


### ソースからパッケージビルドしてインストールする
```
$ git clone https://github.com/chrisy/vpp.git
$ cd vpp/

# build
$ sudo ./extras/vagrant/build.sh

# install
$ sudo dpkg -i build-root/*.deb

$ sudo systemctl start vpp
$ sudo systemctl status vpp

# 自動でNICをバインドしている
$ sudo vppctl show int
              Name               Idx       State          Counter          Count
GigabitEthernet0/3/0              1        down
GigabitEthernet0/4/0              2        down
GigabitEthernet0/5/0              3        down
GigabitEthernet0/6/0              4        down
local0                            0        down


# OSからも見えなくなってる
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:16:3e:41:00:ea brd ff:ff:ff:ff:ff:ff
    inet 172.16.100.131/24 brd 172.16.100.255 scope global ens2
       valid_lft forever preferred_lft forever
    inet6 fe80::216:3eff:fe41:ea/64 scope link
       valid_lft forever preferred_lft forever

# topを見るとvpp_mainが100%で張り付いてる
$ top
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 9057 root      20   0 4971732  58260  16568 R 100.3  1.5   8:59.93 vpp_main
```


### ipをつけてpingしてみる
```
$ sudo vppctl set int ip address GigabitEthernet0/3/0 192.168.10.10/24
$ sudo vppctl set int state GigabitEthernet0/3/0 up
$ sudo vppctl show int
              Name               Idx       State          Counter          Count
GigabitEthernet0/3/0              1         up       rx packets                   999
                                                     rx bytes                   63936
                                                     drops                        999
GigabitEthernet0/4/0              2        down
GigabitEthernet0/5/0              3        down
GigabitEthernet0/6/0              4        down
local0                            0        down


$ sudo vppctl set int ip address GigabitEthernet0/3/0 172.16.100.150/24
$ sudo vppctl set int state GigabitEthernet0/3/0 up

# 別のマシンからping飛ばしてみる
$ ping 172.16.100.150
64 bytes from 172.16.100.150: icmp_seq=1 ttl=64 time=0.061 ms
64 bytes from 172.16.100.150: icmp_seq=2 ttl=64 time=0.057 ms
```

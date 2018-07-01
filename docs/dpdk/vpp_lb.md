# VPP Load Balancer plugin


```
$ sudo vppctl show lb
lb_main ip4-src-address: 255.255.255.255
 ip6-src-address: ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
 #vips: 0
 #ass: 0


$ sudo vppctl lb ?
  as                             lb as <vip-prefix> [<address> [<address> [...]]] [del]
  conf                           lb conf [ip4-src-address <addr>] [ip6-src-address <addr>] [buckets <n>] [timeout <s>]
  vip                            lb vip <prefix> [encap (gre6|gre4|l3dsr)] [dscp <n>] [new_len <n>] [del]


$ sudo vppctl lb vip 172.16.100.0/24
lb_vip_add ok 0

$ sudo vppctl show lb
lb_main ip4-src-address: 255.255.255.255
 ip6-src-address: ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
 #vips: 1
 #ass: 0

$ sudo vppctl show lb vip verbose
 ip4-gre4 [0] 172.16.100.0/24
  new_size:1024
  counters:
    packet from existing sessions: 0
    first session packet: 0
    untracked packet: 0
    no server configured: 0
  #as:0


$ sudo vppctl lb as 172.16.100.160/24 172.16.100.131

$ sudo vppctl show lb vip verbose
 ip4-gre4 [0] 172.16.100.0/24
  new_size:1024
  counters:
    packet from existing sessions: 0
    first session packet: 0
    untracked packet: 0
    no server configured: 0
  #as:1
    172.16.100.131 1024 buckets   0 flows  dpo:10 used
```


```
$ sudo vppctl lb vip 172.16.100.150/32 encap l3dsr dscp 1
$ sudo vppctl lb as 172.16.100.150/32 172.16.100.131
$ sudo vppctl show lb vip verbose
 ip4-l3dsr [0] 172.16.100.150/32
  new_size:1024
  dscp:1
  counters:
    packet from existing sessions: 0
    first session packet: 0
    untracked packet: 0
    no server configured: 0
  #as:1
    172.16.100.131 1024 buckets   0 flows  dpo:10 used
```

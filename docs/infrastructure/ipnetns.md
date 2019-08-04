# ip netns

## ip netns で疑似的な calico like なネットワークを作る例

- ゲスト(netns 内部) の IP を 192.168.50.X とする
- ゲスト のゲートウェイには、リンクローカルアドレス(169.254.0.0/16) の 169.254.0.1 を利用する
- arp に応答させるため、ホスト側の veth に proxy_arp を設定する

### Setup netns1

```
sudo ip netns add testns
sudo ip link add testns-ex type veth peer name testns-in
sudo ip link set testns-ex up
sudo ip route add 192.168.50.2 dev testns-ex
sudo sysctl -w net.ipv4.conf.testns-ex.proxy_arp=1
sudo sysctl -w net.ipv4.conf.testns-ex.forwarding=1

sudo ip link set testns-in netns testns
sudo ip netns exec testns ip addr add 192.168.50.2/32 dev testns-in
sudo ip netns exec testns ip link set testns-in up
sudo ip netns exec testns ip link set lo up

sudo ip netns exec testns ip route add 169.254.1.1 dev testns-in
sudo ip netns exec testns ip route add default via 169.254.1.1
```

### Setup netns2

```
sudo ip netns add testns2
sudo ip link add testns2-ex type veth peer name testns2-in
sudo ip link set testns2-ex up
sudo ip route add 192.168.50.3 dev testns2-ex
sudo sysctl -w net.ipv4.conf.testns2-ex.proxy_arp=1
sudo sysctl -w net.ipv4.conf.testns2-ex.forwarding=1

sudo ip link set testns2-in netns testns2
sudo ip netns exec testns2 ip addr add 192.168.50.3/32 dev testns2-in
sudo ip netns exec testns2 ip link set testns2-in up
sudo ip netns exec testns2 ip link set lo up

sudo ip netns exec testns2 ip route add 169.254.1.1 dev testns2-in
sudo ip netns exec testns2 ip route add default via 169.254.1.1

```

### Accept Forword

```
# iptablesのFORWARD PolicyがDROPの場合は、ACCEPTに変更する
$ sudo iptables -L | grep DROP
Chain FORWARD (policy DROP)

$ sudo iptables -P FORWARD ACCEPT

# もしくは許可する
# iptables -A FORWARD -s ... -o ... -j ACCEPT
```

### Setup nat

```
sudo iptables -t nat -A POSTROUTING -s 192.168.50.2 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 192.168.50.3 -j MASQUERADE
```

### Setup netsted netns

```
sudo ip netns add testnsvm

sudo ip link add testnsvm-ex type veth peer name testnsvm-in
sudo ip link set testnsvm-in netns testnsvm
sudo ip netns exec testnsvm ip link set testnsvm-in up
sudo ip netns exec testnsvm ip link set lo up
sudo ip netns exec testnsvm ip addr add 192.168.60.1/32 dev testnsvm-in
sudo ip netns exec testnsvm ip route add 169.254.1.1 dev testnsvm-in
sudo ip netns exec testnsvm ip route add default via 169.254.1.1

sudo ip link set testnsvm-ex netns testns
sudo ip netns exec testns ip link set testnsvm-ex up
sudo ip netns exec testns sysctl -w net.ipv4.conf.testnsvm-ex.proxy_arp=1
sudo ip netns exec testns sysctl -w net.ipv4.conf.testnsvm-ex.forwarding=1
sudo ip netns exec testns sysctl -w net.ipv4.conf.testns-in.proxy_arp=1
sudo ip netns exec testns sysctl -w net.ipv4.conf.testns-in.forwarding=1

sudo ip netns exec testns ip route add 192.168.60.1 dev testnsvm-ex
sudo ip route add 192.168.60.1 dev testns-ex

sudo iptables -t nat -A POSTROUTING -s 192.168.60.1 -j MASQUERADE
```

```
sudo ip netns add testnsvm2

sudo ip link add testnsvm2-ex type veth peer name testnsvm2-in
sudo ip link set testnsvm2-in netns testnsvm2
sudo ip netns exec testnsvm2 ip link set testnsvm2-in up
sudo ip netns exec testnsvm2 ip link set lo up
sudo ip netns exec testnsvm2 ip addr add 192.168.60.2/32 dev testnsvm2-in
sudo ip netns exec testnsvm2 ip route add 169.254.1.1 dev testnsvm2-in
sudo ip netns exec testnsvm2 ip route add default via 169.254.1.1

sudo ip link set testnsvm2-ex netns testns2
sudo ip netns exec testns2 ip link set testnsvm2-ex up
sudo ip netns exec testns2 sysctl -w net.ipv4.conf.testnsvm2-ex.proxy_arp=1
sudo ip netns exec testns2 sysctl -w net.ipv4.conf.testnsvm2-ex.forwarding=1
sudo ip netns exec testns2 sysctl -w net.ipv4.conf.testns2-in.proxy_arp=1
sudo ip netns exec testns2 sysctl -w net.ipv4.conf.testns2-in.forwarding=1

sudo ip netns exec testns2 ip route add 192.168.60.2 dev testnsvm2-ex
sudo ip route add 192.168.60.2 dev testns2-ex

sudo iptables -t nat -A POSTROUTING -s 192.168.60.2 -j MASQUERADE
```

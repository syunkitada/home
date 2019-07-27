# ip

## ip addr add

```
$ sudo ip addr add 192.168.10.2/24 dev eth0
```

## ip link set

```
$ sudo ip link set eth0 up

# if following error occured, you should flush ip address
$ sudo ip link set eth0 up
RTNETLINK answers: File exists

$ sudo ip addr flush dev eth0
```

# DPDK

## メモ

- Driver
  - UIO
    - ユーザスペースにドライバを作成するための機能
    - ユーザスペースのメモリでデバイスと DMA する
      - 従来の Kernel ドライバでパケットを受けとってから、ユーザスペースにコピーするということがない
    - DMA 用に割り当てるメモリは、Hugepage を使うのが一般的
      - 割り当てられたメモリでリングバッファ(mbuf)を作る
        - ロックレス
      - Hugepage も使うので、TLB のヒット率も高い
  - VFIO
    - cat /proc/cpuinfo |grep -E "vmx|svm"
    - GRUB で iommu を有効にする必要がる
      - iommu=pt intel_iommu=on
- PMD
  - Poll Mode Driver
  - CPU がドライバをポーリングするために使用するドライバ
  - PMD Thread は、CPU pinning し、Kernel からは isol するのが一般的
    - Context Switch を抑制し、TLB・キャッシュのヒット率が高くなる
  - Poll せずに、Interupt するオプションもある
    - NAPI みたいなこともできる？
- 参考
  - [DPDK documentation](https://doc.dpdk.org/guides-20.02/)
  - [Understanding DPDK](https://www.slideshare.net/garyachy/dpdk-44585840)

## Ubuntu16(VM)

### Reserve hugepages

- 簡易的に hugepage 2M を 512 用意する

```
$ sudo sh -c 'echo 512 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages'
$ mkdir -p /mnt/huge
$ sudo mount -t hugetlbfs nodev /mnt/huge
$ cat /proc/meminfo
HugePages_Total:     512
HugePages_Free:      512
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
```

### dpdk をコンパイル・インストールする

```
$ sudo apt-get install libnuma-dev make gcc
$ wget https://fast.dpdk.org/rel/dpdk-17.11.1.tar.xz
$ tar xf dpdk-17.11.1.tar.xz

$ cd dpdk-stable-17.11.1/
$ make install T=x86_64-native-linuxapp-gcc

# カレントディレクトリに以下にファイルがインストールされる
$ ls x86_64-native-linuxapp-gcc/
Makefile  app/  build/  include/  kmod/  lib/

# ドライバのロード
# VMでVFIOが使えないのでigb_uio.koをロード
# また、igb_uio.koはカーネルごとにビルドし直す必要があるので、VFIO使えるならVFIO使うほうがよい
$ sudo modprobe uio
$ sudo insmod x86_64-native-linuxapp-gcc/kmod/igb_uio.ko
```

### helloworld を動かしてみる

```
# ビルド用の環境変数をセットする
$ export RTE_SDK=$HOME/dpdk-stable-17.11.1
$ export RTE_TARGET=x86_64-native-linuxapp-gcc

$ cd examples/helloworld
$ make
  CC main.o
  LD helloworld
  INSTALL-APP helloworld
  INSTALL-MAP helloworld.map

# --huge-unlinkは、実行後にhugepageを開放するオプション(これつけないとhugepageが取られっぱなしになる)
$ sudo ./build/helloworld --huge-unlink
EAL: Detected 4 lcore(s)
EAL: No free hugepages reported in hugepages-1048576kB
EAL: Probing VFIO support...
EAL: WARNING: cpu flags constant_tsc=yes nonstop_tsc=no -> using unreliable clock cycles !
EAL: PCI device 0000:00:02.0 on NUMA socket -1
EAL:   Invalid NUMA socket, default to 0
EAL:   probe driver: 1af4:1000 net_virtio
EAL: PCI device 0000:00:03.0 on NUMA socket -1
EAL:   Invalid NUMA socket, default to 0
EAL:   probe driver: 1af4:1000 net_virtio
EAL: PCI device 0000:00:04.0 on NUMA socket -1
EAL:   Invalid NUMA socket, default to 0
EAL:   probe driver: 1af4:1000 net_virtio
EAL: PCI device 0000:00:05.0 on NUMA socket -1
EAL:   Invalid NUMA socket, default to 0
EAL:   probe driver: 8086:100e net_e1000_em
EAL: PCI device 0000:00:06.0 on NUMA socket -1
EAL:   Invalid NUMA socket, default to 0
EAL:   probe driver: 8086:100e net_e1000_em
hello from core 1
hello from core 2
hello from core 3
hello from core 0
```

### NIC を DPDK にバインドする

```
# 初期状態を確認する
$ python3 usertools/dpdk-devbind.py --status

Network devices using DPDK-compatible driver
============================================
<none>

Network devices using kernel driver
===================================
0000:00:02.0 'Virtio network device 1000' if=ens2 drv=virtio-pci unused=igb_uio *Active*
0000:00:03.0 'Virtio network device 1000' if=ens3 drv=virtio-pci unused=igb_uio
0000:00:04.0 'Virtio network device 1000' if=ens4 drv=virtio-pci unused=igb_uio
0000:00:05.0 '82540EM Gigabit Ethernet Controller 100e' if=ens5 drv=e1000 unused=igb_uio
0000:00:06.0 '82540EM Gigabit Ethernet Controller 100e' if=ens6 drv=e1000 unused=igb_uio

Other Network devices
=====================
<none>

# DPDKにバインドする
$ sudo python3 usertools/dpdk-devbind.py --bind=igb_uio 0000:00:05.0

# バインド状態を確認
$ sudo python3 usertools/dpdk-devbind.py --status

Network devices using DPDK-compatible driver
============================================
0000:00:05.0 '82540EM Gigabit Ethernet Controller 100e' drv=igb_uio unused=e1000

Network devices using kernel driver
===================================
0000:00:02.0 'Virtio network device 1000' if=ens2 drv=virtio-pci unused=igb_uio *Active*
0000:00:03.0 'Virtio network device 1000' if=ens3 drv=virtio-pci unused=igb_uio
0000:00:04.0 'Virtio network device 1000' if=ens4 drv=virtio-pci unused=igb_uio
0000:00:06.0 '82540EM Gigabit Ethernet Controller 100e' if=ens6 drv=e1000 unused=igb_uio


# バインドしたNICはOSからは見えなくなる
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
3: ens3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 00:16:3e:18:13:98 brd ff:ff:ff:ff:ff:ff
4: ens4: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 00:16:3e:00:74:b6 brd ff:ff:ff:ff:ff:ff
6: ens6: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 00:16:3e:51:91:65 brd ff:ff:ff:ff:ff:ff
```

### testpmd

```
# -i で対話モードになる
$ sudo ./x86_64-native-linuxapp-gcc/build/app/test-pmd/testpmd -- -i
EAL: Detected 4 lcore(s)
EAL: No free hugepages reported in hugepages-1048576kB
EAL: Probing VFIO support...
EAL: WARNING: cpu flags constant_tsc=yes nonstop_tsc=no -> using unreliable clock cycles !
EAL: PCI device 0000:00:02.0 on NUMA socket -1
EAL:   Invalid NUMA socket, default to 0
EAL:   probe driver: 1af4:1000 net_virtio
EAL: PCI device 0000:00:03.0 on NUMA socket -1
EAL:   Invalid NUMA socket, default to 0
EAL:   probe driver: 1af4:1000 net_virtio
EAL: PCI device 0000:00:04.0 on NUMA socket -1
EAL:   Invalid NUMA socket, default to 0
EAL:   probe driver: 1af4:1000 net_virtio
EAL: PCI device 0000:00:05.0 on NUMA socket -1
EAL:   Invalid NUMA socket, default to 0
EAL:   probe driver: 8086:100e net_e1000_em
EAL: PCI device 0000:00:06.0 on NUMA socket -1
EAL:   Invalid NUMA socket, default to 0
EAL:   probe driver: 8086:100e net_e1000_em
Interactive-mode selected
USER1: create a new mbuf pool <mbuf_pool_socket_0>: n=171456, size=2176, socket=0

Warning! Cannot handle an odd number of ports with the current port topology. Configuration must be changed to have an even number of ports, or relaunch application with --port-topology=chained

Configuring Port 0 (socket 0)
Port 0: 00:16:3E:74:6A:8D
Checking link statuses...
Done
PMD: eth_em_interrupt_action():  Port 0: Link Up - speed 1000 Mbps - full-duplex

Port 0: LSC event

testpmd> show port stats all

  ######################## NIC statistics for port 0  ########################
  RX-packets: 1          RX-missed: 0          RX-bytes:  111
  RX-errors: 0
  RX-nombuf:  0
  TX-packets: 0          TX-errors: 0          TX-bytes:  0

  Throughput (since last show)
  Rx-pps:            0
  Tx-pps:            0
  ############################################################################

testpmd> show port info 0

********************* Infos for port 0  *********************
MAC address: 00:16:3E:74:6A:8D
Driver name: net_e1000_em
Connect to socket: 0
memory allocation on the socket: 0
Link status: up
Link speed: 1000 Mbps
Link duplex: full-duplex
MTU: 1500
Promiscuous mode: enabled
Allmulticast mode: disabled
Maximum number of MAC addresses: 15
Maximum number of MAC addresses of hash filtering: 0
VLAN offload:
  strip on
  filter on
  qinq(extend) off
No flow type is supported.
Max possible RX queues: 1
Max possible number of RXDs per queue: 4096
Min possible number of RXDs per queue: 32
RXDs number alignment: 8
Max possible TX queues: 1
Max possible number of TXDs per queue: 4096
Min possible number of TXDs per queue: 32
TXDs number alignment: 8

testpmd> start tx_first

Warning! Cannot handle an odd number of ports with the current port topology. Configuration must be changed to have an even number of ports, or relaunch application with --port-topology=chained

io packet forwarding - ports=1 - cores=1 - streams=1 - NUMA support enabled, MP over anonymous pages disabled
Logical Core 1 (socket 0) forwards packets on 1 streams:
  RX P=0/Q=0 (socket 0) -> TX P=0/Q=0 (socket 0) peer=02:00:00:00:00:00

  io packet forwarding packets/burst=32
  nb forwarding cores=1 - nb forwarding ports=1
  port 0:
  CRC stripping enabled
  RX queues=1 - RX desc=128 - RX free threshold=0
  RX threshold registers: pthresh=0 hthresh=0  wthresh=0
  TX queues=1 - TX desc=512 - TX free threshold=0
  TX threshold registers: pthresh=0 hthresh=0  wthresh=0
  TX RS bit threshold=0 - TXQ flags=0x0

testpmd> stop
Telling cores to stop...
Waiting for lcores to finish...

  ---------------------- Forward statistics for port 0  ----------------------
  RX-packets: 0              RX-dropped: 0             RX-total: 0
  TX-packets: 32             TX-dropped: 0             TX-total: 32
  ----------------------------------------------------------------------------

  +++++++++++++++ Accumulated forward statistics for all ports+++++++++++++++
  RX-packets: 0              RX-dropped: 0             RX-total: 0
  TX-packets: 32             TX-dropped: 0             TX-total: 32
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Done.

testpmd> quit
```

- start tx_first 中に top を見ると cpu が 100%に張り付くのがわかる

```
$ top
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
31704 root      20   0 1180076  53452   8252 S 100.0  1.4   0:09.12 testpmd
```

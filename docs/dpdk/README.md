# DPDK

## How to use
### Ubuntu(VM)
iommuを有効にする
* kernelパラメータに以下を入れてリスタートし、iommuを有効にする  
* ただし、virtioを利用する場合は必要ないので今回はスルー
```
iommu=pt intel_iommu=on
```

hugepageを確保する
```
# /etc/default/grub
> GRUB_CMDLINE_LINUX="hugepages=1024"

$ sudo grub-mkconfig -o /boot/grub/grub.cfg

# etc/fstab
> nodev /mnt/huge hugetlbfs defaults 0 0

$ sudo mkdir /mnt/huge
$ sudo reboot

$ cat /proc/meminfo | grep HugePages
AnonHugePages:      4096 kB
HugePages_Total:    1024
HugePages_Free:     1024
HugePages_Rsvd:        0
HugePages_Surp:        0
```

SSE3が有効になってることを確認
* SSE3は、SSE2を拡張した拡張命令セット、vmのcpu modeによっては無効になっている
* VMで利用する場合は、domain.xmlに <cpu mode='host-model'> を記述する
``` bash
$ cat /proc/cpuinfo | grep ssse3
```

マルチキューを使う（オプション)
``` bash
<interface type='bridge'>
   <driver name='vhost' queues='2'/>
   ...
</interface>
```

e1000, uio_pci_genericが必要?


``` bash
# インストール
$ apt-get install dpdk

# このコマンドで利用可能なDPDKに割り当てらているNICとKernelに割り当てられているNICを調べられる
$ dpdk_nic_bind --status
Network devices using DPDK-compatible driver
============================================
<none>

Network devices using kernel driver
===================================
0000:00:02.0 'Virtio network device' if= drv=virtio-pci unused=
0000:00:03.0 'Virtio network device' if= drv=virtio-pci unused=

Other network devices
=====================
<none>

# confにDPDKに割り当てるインターフェイスを指定する
$ sudo vi /etc/dpdk/interfaces
# <bus> <id>            <driver>
pci 0000:00:03.0 virtio-pci


# hugepagesの割り当て
# 2M or 1Gのhugepagesを割り当てる（割り当てなくてもよい）
# TLB のhit率上げるなら1G(しかし、1GだとDPDKメモリアロケーション内で断片化しているという報告がある)
$ sudo vi /etc/dpdk/dpdk.conf
NR_1G_PAGES=1
```

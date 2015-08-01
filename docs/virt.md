# Virt

## Enable kvm
``` bash
% sudo modprobe kvm
% sudo modprobe kvm_intel
% sudo lsmod | grep kvm
kvm_intel             143590  0
kvm                   452043  1 kvm_intel
```

## Virt install
``` bash
# Create disk img of VM
% sudo qemu-img create -f qcow2 /var/lib/libvirt/images/testvm 20G

# Create VM
% sudo virt-install \
    --connect=qemu:///system \
    --name=testvm --vcpus=1 --ram=1024 \
    --accelerate --hvm --virt-type=kvm \
    --cpu host \
    --disk=/var/lib/libvirt/images/testvm.img,format=qcow2 \
    --location='/tmp/imgs/CentOS-6.6-x86_64-bin-DVD1.iso' \
    --nographics \
    --extra-args='console=tty0 console=ttyS0,115200n8 keymap=ja'

# Create Snapshot
% sudo virsh snapshot-create-as testvm testsnap 'first snap'

% sudo virsh snapshot-list testvm
 Name                 Creation Time             State
 ------------------------------------------------------------
  testsnap             2015-06-21 11:58:35 +0900 running

% sudo virsh snapshot-revert testvm testsnap

% sudo virsh snapshot-info testvm testsnap
Name:           testsnap
Domain:         testvm
Current:        yes
State:          running
Location:       internal
Parent:         -
Children:       0
Descendants:    0
Metadata:       yes

% sudo virsh snapshot-info testvm --current
Name:           testsnap
Domain:         testvm
Current:        yes
State:          running
Location:       internal
Parent:         -
Children:       0
Descendants:    0
Metadata:       yes

% sudo virsh snapshot-dumpxml vm1 snap1

% sudo virsh snapshot-delete vm1 snap1
```


## XXX Add bridge

``` bash
% sudo brctl addbr mybr

# 無線LANはL2レイヤーレベルでの転送をサポートしていない
% sudo brctl addif mybr wlan0
can't add wlan0 to bridge mybr: Operation not supported

# 以下のように、無理やり対応しようとしたが無線がブツブツとぎれるようになった。

# パケットフォワワーディングを有効
% sudo sysctl net.ipv4.ip_forward=1

# wlan0に飛んできたarpをbr0にも転送する
% sudo apt-get install parprouted
% sudo parprouted wlan0 br0

# mybrから飛んできたブロードキャストをwlan0に転送する
% sudo apt-get install bcrelay
% sudo bcrelay -d -i br0 -o wlan0

% sudo ip link set mybr up
```

## Setup nat to ssh VM
``` bash
# 192.168.122.0/24へのアクセスを許可する
sudo iptables -R FORWARD 1 -o virbr0 -s 0.0.0.0/0 -d 192.168.122.0/255.255.255.0 -j ACCEPT

# 10022ポートへのアクセスを192.168.122.156:22 へ転送する
sudo iptables -t nat -A PREROUTING -p tcp --dport 10022 -j DNAT --to 192.168.122.156:22

sudo iptables -L -t nat
sudo iptables -L

# TODO サーバ起動時にiptablesを反映させる
```

## Virsh commands
``` bash
# Autostart VM
$ sudo virsh autostart testvm
```

# qemu

## 最小限の QEMU

- http://manual.geeko.cpon.org/ja/cha.qemu.monitor.html

```
sudo qemu-system-x86_64 --enable-kvm -m 512 -nographic -monitor telnet::4444,server,nowait
SeaBIOS (version rel-1.11.0-0-g63451fca13-prebuilt.qemu-project.org)


iPXE (http://ipxe.org) 00:03.0 C980 PCI2.10 PnP PMM+1FF91590+1FEF1590 C980



Booting from Hard Disk...
Boot failed: could not read the boot disk

Booting from Floppy...
Boot failed: could not read the boot disk

Booting from DVD/CD...
Boot failed: Could not read from CDROM (code 0003)
Booting from ROM...
iPXE (PCI 00:03.0) starting execution...ok
iPXE initialising devices...ok



iPXE 1.0.0+ (0600d) -- Open Source Network Boot Firmware -- http://ipxe.org
Features: DNS HTTP iSCSI TFTP AoE ELF MBOOT PXE bzImage Menu PXEXT

net0: 52:54:00:12:34:56 using 82540em on 0000:00:03.0 (open)
  [Link:up, TX:0 TXE:0 RX:0 RXE:0]
Configuring (net0 52:54:00:12:34:56)..... ok
net0: 10.0.2.15/255.255.255.0 gw 10.0.2.2
Nothing to boot: No such file or directory (http://ipxe.org/2d03e13b)
No more network devices

No bootable device.



$ sudo qemu-system-x86_64 --enable-kvm -m 512 -nographic -monitor telnet::4444,server,nowait
...

$ telnet localhost 4444

(qemu) info registers
EAX=00000000 EBX=00000000 ECX=0000b700 EDX=00000000
ESI=00000000 EDI=0000b7bf EBP=00000000 ESP=00006f7c
EIP=0000b7db EFL=00000246 [---Z-P-] CPL=0 II=0 A20=1 SMM=0 HLT=1
ES =dc80 000dc800 0000ffff 00009300
CS =f000 000f0000 0000ffff 00009b00
SS =0000 00000000 0000ffff 00009300
DS =0000 00000000 0000ffff 00009300
FS =0000 00000000 0000ffff 00009300
GS =0000 00000000 0000ffff 00009300
LDT=0000 00000000 0000ffff 00008200
TR =0000 00000000 0000ffff 00008b00
GDT=     00000000 00000000
IDT=     00000000 000003ff
CR0=00000010 CR2=00000000 CR3=00000000 CR4=00000000
DR0=0000000000000000 DR1=0000000000000000 DR2=0000000000000000 DR3=0000000000000000
DR6=00000000ffff0ff0 DR7=0000000000000400
EFER=0000000000000000
FCW=037f FSW=0000 [ST=0] FTW=00 MXCSR=00001f80
FPR0=0000000000000000 0000 FPR1=0000000000000000 0000
FPR2=0000000000000000 0000 FPR3=0000000000000000 0000
FPR4=0000000000000000 0000 FPR5=0000000000000000 0000
FPR6=0000000000000000 0000 FPR7=0000000000000000 0000
XMM00=00000000000000000000000000000000 XMM01=00000000000000000000000000000000
XMM02=00000000000000000000000000000000 XMM03=00000000000000000000000000000000
XMM04=00000000000000000000000000000000 XMM05=00000000000000000000000000000000
XMM06=00000000000000000000000000000000 XMM07=00000000000000000000000000000000

(qemu) q
```

qemu-io [device] "[command]"

--trace-backend=ftrace
-trace events=/home/eiichi/events

## network option

```
https://www.qemu.org/2018/05/31/nic-parameter/

-nic [tap|bridge|user|l2tpv3|vde|vhost-user|socket][,option][,...][mac=macaddr]
                initialize an on-board / default host NIC (using MAC address
                macaddr) and connect it to the given host network backend

$ qemu-system-x86_64 -nic help
Available netdev backend types:
socket
hubport
tap
user
l2tpv3
vde
bridge
vhost-user

$ qemu-system-x86_64 -nic model=help
qemu: Supported NIC models: e1000,e1000-82544gc,e1000-82545em,e1000e,i82550,i82551,i82557a,i82557b,i82557c,i82558a,i82558b,i82559a,i82559b,i82559c,i82559er,i82562,i82801,ne2k_pci,pcnet,pvrdma,rocker,rtl8139,virtio-net-pci,virtio-net-pci-non-transitional,virtio-net-pci-transitional,vmxnet3
```

## cloud イメージの利用

- cloudinit
  - クラウドプロバイダなしでの利用
    - https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html
    - cidata のラベルを付けてイメージを作成する
    - sudo genisoimage -o config.img -V cidata -r -J user-data meta-data
    - 以下のようなオプションで disk をアタッチする
    - qemu-system-x86_64 ... -drive file=config.img,format=raw,if=none,id=drive-ide0-1-0,readonly=on -device ide-cd,bus=ide.1,unit=0,drive=drive-ide0-1-0,id=ide0-1-0

## Examples

```
qemu-system-x86_64 -m 2048 -drive file=vm.img,if=virtio -monitor telnet::4444,server,nowait -nographic -serial telnet:localhost:4321,server,nowait -drive file=config.img,format=raw,if=none,id=drive-ide0-1-0,readonly=on -device ide-cd,bus=ide.1,unit=0,drive=drive-ide0-1-0,id=ide0-1-0 -nic tap,ifname=tap0,model=virtio-net-pci,mac=02:ca:83:1b:4d:f1,script=no,script=no,downscript=no
```

## grub の設定

```
sed -i 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="default_hugepagesz=1G hugepagesz=1G hugepages=16 transparent_hugepage=never amd_iommu=on"/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
cat /boot/grub/grub.cfg | grep vmlinuz
```

- crashkernel \* https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/kernel_administration_guide/kernel_crash_dump_guide
- iommu(intel\*iommu or amd_iommu)
  - pci パススルーを利用するのに必要
    \_ https://access.redhat.com/documentation/ja-jp/red_hat_virtualization/4.1/html/installation_guide/appe-configuring_a_hypervisor_host_for_pci_passthrough
- transparent\*hugepage=never
  - ページウォークが減るが、大きめのページサイズを確保するためメモリ確保のレイテンシが上がる
  - 利用はケースバイケース

## CPU

- https://qemu.weilnetz.de/doc/qemu-doc.html#index-_002dmachine
- cpu-hotplug について
  - https://github.com/qemu/qemu/blob/master/docs/cpu-hotplug.rst
  - http://events17.linuxfoundation.org/sites/events/files/slides/CPU%20Hot-plug%20support%20in%20QEMU.pdf
  - kvm はサポートされてない
- cpu のモデルについて
  - http://events19.linuxfoundation.org/wp-content/uploads/2017/12/Kashyap-Chamarthy_Effective-Virtual-CPU-Configuration-OSS-EU2018.pdf
- cpu の脆弱性について
  - https://www.qemu.org/2018/02/14/qemu-2-11-1-and-spectre-update/
- smp [cpus=]n[,cores=cores][,threads=threads][,dies=dies][,sockets=sockets][,maxcpus=maxcpus]
  - the number of cores per die, the number of threads per cores, the number of dies per packages
    - dies、sockets は numa を増やしてエミュレートしたい場合に利用する
    - threads は intel などの HT をエミュレートしたい場合に利用する
      - スレッドをうまく pinning すると、VM 側でも HT を意識できるかも?
  - pinning は qemu の機能としては提供されていないので、起動後に cgroup の機能を使って設定する
  - maxcpus は、cpu の hotplug を利用する場合に必要だが、kvm は cpu の hutplug はサポートされてない

```
qemu ...
  -enable-kvm -machine q35,accel=kvm
```

```
-smp sockets=1,cores=4,threads=1 \
```

## メモリ

- hotplug について
  - https://github.com/qemu/qemu/blob/master/docs/memory-hotplug.txt

```
qemu ...
    -m slots=64,maxmem=64G \
    -object memory-backend-file,id=mem1,size=2G,mem-path=/dev/hugepages \
    -device pc-dimm,id=dimm1,memdev=mem1 \
```

- virtio baloon driver
  - ゲストのメモリを動的に増減する(memory ballooning)ためもの
  - https://kvm.hatenadiary.org/entry/20081016/1224171825
  - -device virtio-balloon-pci,id=baloon1

## ディスク

- オンラインリサイズについて
- IO throttling
  - https://github.com/qemu/qemu/blob/master/docs/throttle.txt

## パススルー

```

-device amd-iommu/intel-iommu
```

## Persistent Memory

- https://docs.pmem.io/getting-started-guide/creating-development-environments/virtualization/qemu

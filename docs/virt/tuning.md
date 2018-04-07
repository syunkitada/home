# tuning

## Redhat tuning
https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/6/html/Performance_Tuning_Guide/index.html
https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/7/html/Performance_Tuning_Guide/index.html

## Redhat vitualization tuning
https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/6/html/Virtualization_Tuning_and_Optimization_Guide/index.html
https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/7/html/Virtualization_Tuning_and_Optimization_Guide/index.html

## Ubuntu
http://www.slideshare.net/janghoonsim/kvm-performance-optimization-for-ubuntu?qid=fb99f565-8ae4-44d3-9b58-8d8487197566&v=&b=&from_search=3



## CPU
* https://libvirt.org/formatdomain.html#elementsCPUTuning


## Disk
### cachemodeの種類
| cache mode | host page cache | disk write cache | no flush |
| --- | --- | --- | --- |
| directsync   |   |   |   |
| writethrough | o |   |   |
| none         |   | o |   |
| writeback    | o | o |   |
| unsafe       | o | o | o |

* host page cache
    * qemuがDiskをopenするときにO_DIRECTフラグをつけるかどうか
* disk write cache
    * virtio-blkデバイスの持つcache
        * 通常のHDDなども32MBや64MBのcacheを持っており、それと同じようなもの
    * qemuの中では、このキャッシュを使うかどうかでflush(fdatasync)のタイミングが異なる
        * キャッシュ有効時
            * 仮想マシンOSからflush要求があった時にqemuがflush(fdatasync)する
        * キャッシュ無効時
            * 仮想マシンのdisk writeのたびにqemuがflush(fdatasync)する
* no flush
    * cacheをdiskにflushするのを無効化する


### cachemodeの選定
* directsync
    * 物理環境と同程度の安全性が欲しい場合
    * データベースシステムなど、ファイルの不整合が許容できないところで利用するのが良い
    * しかし、IO性能は劣化するためDISK性能を最大限利用したい場合には不向き、またそのようなシステムでVMは利用すべきではない
* none
    * メモリ消費量はほどほどに抑え、性能もある程度確保したい場合
    * 1つHVに大量のVMを集約する場合はこれがよい
* writeback
    * 広大なホストのページキャッシュを利用し、性能を出したい場合
    * 1つのHVに少量のVMを集約し、高性能VMを提供する場合はこれがよい


### disk type
* raw
    * ただのファイル
* qcow2
    * 機能
        * sparce space
            * 仮想ディスクが必要とした部分だけ書き込む
        * snapshot
        * linked file
            * ベースファイルをリンクして、追加分だけを書き込む
        * AES暗号化
        * 圧縮(zlib)

* https://serverfault.com/questions/677639/which-is-better-image-format-raw-or-qcow2-to-use-as-a-baseimage-for-other-vms
* https://www.jamescoyle.net/how-to/1810-qcow2-disk-images-and-performance


### blkiotune
* https://libvirt.org/formatdomain.html#elementsBlockTuning


## Network

### multiqueueのサポート
``` bash
<interface type='bridge'>
    <driver name='vhost' queues='2'/>
    ...
</interface>

$ cat /proc/interrupts
# nic=2, queues=1
 24:          0          0          0          0   PCI-MSI 32768-edge      virtio0-config
 25:        620          0       1875          0   PCI-MSI 32769-edge      virtio0-input.0
 26:          1          0          0          0   PCI-MSI 32770-edge      virtio0-output.0
 27:          0          0          0          0   PCI-MSI 49152-edge      virtio1-config
 28:          1          0          0          0   PCI-MSI 49153-edge      virtio1-input.0
 29:          0          0          0          0   PCI-MSI 49154-edge      virtio1-output.0

# nic=2, queues=2
 24:          0          0          0          0   PCI-MSI 32768-edge      virtio0-config
 25:       1671          0          0       3200   PCI-MSI 32769-edge      virtio0-input.0
 26:          1          0          0          0   PCI-MSI 32770-edge      virtio0-output.0
 27:          0          0          0          0   PCI-MSI 32771-edge      virtio0-input.1
 28:          0          0          0          0   PCI-MSI 32772-edge      virtio0-output.1
 29:          0          0          0          0   PCI-MSI 49152-edge      virtio1-config
 30:          1          0          0          0   PCI-MSI 49153-edge      virtio1-input.0
 31:          0          0          0          0   PCI-MSI 49154-edge      virtio1-output.0
 32:          0          0          0          0   PCI-MSI 49155-edge      virtio1-input.1
 33:          0          0          0          0   PCI-MSI 49156-edge      virtio1-output.1
```

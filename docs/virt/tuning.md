# tuning

## Redhat tuning
https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/6/html/Performance_Tuning_Guide/index.html
https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/7/html/Performance_Tuning_Guide/index.html

## Redhat vitualization tuning
https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/6/html/Virtualization_Tuning_and_Optimization_Guide/index.html
https://access.redhat.com/documentation/ja-JP/Red_Hat_Enterprise_Linux/7/html/Virtualization_Tuning_and_Optimization_Guide/index.html

## Ubuntu
http://www.slideshare.net/janghoonsim/kvm-performance-optimization-for-ubuntu?qid=fb99f565-8ae4-44d3-9b58-8d8487197566&v=&b=&from_search=3



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

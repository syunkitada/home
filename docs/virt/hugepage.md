# hugepage

``` bash
# hugepageの作成
# $ sudo sh -c 'echo  > /proc/sys/vm/nr_hugepages'

# 永続化するならsysctl.confに書き込む
$ vim /etc/sysctl.conf
> vm.nr_hugepages = 2048
$ sudo sysctl -p
vm.nr_hugepages = 2048

# 確認
$ cat /proc/meminfo
HugePages_Total:    2048
HugePages_Free:     2048
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB

$ sudo cat /proc/sys/vm/nr_hugepages
2048

# hugepageをマウントする
$ sudo mkdir /dev/hugepages
$ sudo mount -t hugetlbfs hugetlbfs /dev/hugepages

$ sudo service libvirt-bin restart

$ sudo virsh stop centos7

$ sudo virsh edit centos7
<memoryBacking>
   <hugepages/>
</memoryBacking>

sudo virsh start centos7

# hugepageが使われている
$ cat /proc/meminfo
HugePages_Total:    2048
HugePages_Free:     1024
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
```

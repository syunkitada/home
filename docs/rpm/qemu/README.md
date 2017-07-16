# qemu
* http://vde.sourceforge.net/


## Build RPM
``` bash
mkdir -p /tmp/qemu/rpmbuild/SOURCES/
wget -P /tmp/qemu/rpmbuild/SOURCES/ https://github.com/openstack/keystone/archive/12.0.0.0b2.tar.gz
rpmbuild --bb qemu-2.9.0.spec --define "_topdir /tmp/qemu/rpmbuild" --define
```


## Check RPM
``` bash
ls /tmp/vde2/rpmbuild/RPMS/x86_64/
vde2-2.3.2-1mamba.x86_64.rpm  vde2-debuginfo-2.3.2-1mamba.x86_64.rpm  vde2-devel-2.3.2-1mamba.x86_64.rpm
```

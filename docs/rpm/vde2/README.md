# vde2
* http://vde.sourceforge.net/


## Build RPM
``` bash
mkdir -p /tmp/vde2/rpmbuild/SOURCES/
wget -P /tmp/vde2/rpmbuild/SOURCES/ http://downloads.sourceforge.net/project/vde/vde2/2.3.2/vde2-2.3.2.tar.gz
rpmbuild --bb vde2-2.3.2.spec --define "_topdir /tmp/vde2/rpmbuild"
```


## Check RPM
``` bash
ls /tmp/vde2/rpmbuild/RPMS/x86_64/
vde2-2.3.2-1mamba.x86_64.rpm  vde2-debuginfo-2.3.2-1mamba.x86_64.rpm  vde2-devel-2.3.2-1mamba.x86_64.rpm
```

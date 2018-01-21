# vpp

* https://wiki.fd.io/view/VPP/Build,_install,_and_test_images
* https://docs.google.com/document/d/1zqYN7qMavgbdkPWIJIrsPXlxNOZ_GhEveHQxpYr3qrg/edit


## メモ
```
Install Vagrant software.
Install the Vagrant software: https://docs.vagrantup.com/v2/installation/index.html
Install vagrant-cachier
Optional: To cache apt/yum (for faster Vagrant VM rebuild), install vagrant-cachier.

At the unix command line run:

$ vagrant plugin install vagrant-cachier

git clone https://gerrit.fd.io/r/vpp

vagrunt up

vagrunt ssh

$ cat /etc/os-release
NAME="Ubuntu"
VERSION="16.04 LTS (Xenial Xerus)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 16.04 LTS"
VERSION_ID="16.04"
HOME_URL="http://www.ubuntu.com/"
SUPPORT_URL="http://help.ubuntu.com/"
BUG_REPORT_URL="http://bugs.launchpad.net/ubuntu/"
UBUNTU_CODENAME=xenial


$ sudo dpkg -i *.deb


$ sudo vppctl show int
              Name               Idx       State          Counter          Count
local0                            0        down
```

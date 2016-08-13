# Ubuntu

For Ubuntu 16 LTS.

## Setup authorized_keys
Scp my id_rsa.pub to ubuntu home directory.
``` bash
$ cp ~/id_rsa.pub .ssh/authorized_keys
$ chmod 600 .ssh/authorized_keys
```

## Setup dot files, and install basic packages
``` bash
$ sudo apt-get install git
$ git clone git@github.com:syunkitada/home.git
$ cd home
$ ./setup_ubuntu.sh
$ source ~/.bash_profile
```

## Network commands
``` bash
$ sudo service network-manager restart
```

## Setup qemu
``` bash
$ sudo apt-get install kvm
$ sudo apt-get install qemu
$ sudo apt-get install libvirt
$ sudo apt-get install libvirt-bin
$ sudo apt-get install virtinst
$ sudo virsh list
```

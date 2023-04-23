# CentOS

For CentOS-6.5-i386-minimal.

## Setup user

```bash
$ useradd hoge
$ passwd hoge
$ gpasswd -a hoge wheel

# for use sudo
$ visudo
  # Remove comment out
  %wheel ALL=(ALL) ALL
```

## Setup Network

### enable eth on boot

```bash
$ vi /etc/sysconfig/network-scripts/ifcfg-eth0
  ONBOOT=yes
$ sudo service network restart
```

### Setup authorized_keys

Scp my id_rsa.pub to ubuntu home directory.

```bash
$ mkdir .ssh
$ chmod 700 .ssh
$ cp ~/id_rsa.pub .ssh/authorized_keys
$ chmod 600 .ssh/authorized_keys
```

## Setup secure

### Disable root login, and assword login on ssh

```bash
$ sudo vi /etc/ssh/sshd_config
  PermitRootLogin no
  PasswordAuthentication no

$ sudo service sshd restart
```

### Setup dot files, and install basic packages.

```bash
# Setup dotfiles and install basic packages
$ git clone git@github.com:syunkitada/home.git
$ cd home
$ ./setup_dotfiles.sh
$ ./setup_cent.sh
```

# Ubuntu

For Ubuntu 18 LTS.

## Install

- Create LiveUSB and Install
  - https://rufus.ie/
  - https://www.ubuntu.com/

## Setup authorized_keys

Scp my id_rsa.pub to ubuntu home directory.

```bash
$ cp ~/id_rsa.pub .ssh/authorized_keys
$ chmod 600 .ssh/authorized_keys
```

## Setup dot files, and install basic packages

```bash
$ sudo apt-get install git
$ git clone git@github.com:syunkitada/home.git
$ cd home
$ ./setup_dotfiles.sh
$ ./setup_ubuntu.sh
```

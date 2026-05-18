# Ubuntu

Ubuntu 24.04 LTS 用のセットアップ手順です。

## Setup authorized_keys

SSH公開鍵を .ssh/authorized_keys に書き込みます。

```bash
$ vim .ssh/authorized_keys
xxx

$ chmod 600 .ssh/authorized_keys
```

## Setup dot files, and install basic packages

```bash
$ sudo apt install git make

$ git clone git@github.com:syunkitada/home.git
$ git clone git@github.com:syunkitada/home_ex.git

$ make
```

```bash
$ sudo chsh -s $(which zsh) $(whoami)
```

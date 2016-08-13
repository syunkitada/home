# Windows

## Common software
| Soft | Description |
| --- | --- |
| Microsoft Security Essentials (Windows7)            | |
| Windows Defender (Windows 8, 10: default installed) | |
| Lhaplus           | |
| Clover            | |
| Desktops          | |
| VLC media player  | |
| TrueCrypt         | |
| LibreOffice       | |

## Install cygwin
* Install position: ~/Desktop/cygwin/cygwin64
  * local position: ~/Desktop/cygwin/local
* And Install 'KaoriYa gvim', 'putty', 'teraterm' to ~/Desktop/cygwin/

Install cygwin package is

| Category | Soft |
| --- | --- |
| Devel  | ctags, gcc (c, c++, objectiv-c, etc), git, make |
| Editor | vim, vim-common           |
| Net    | bind-utils, curl, openssl |
| Python | python, python-crypto     |
| Tcl    | expect    |
| Utils  | tmux, zsh |
| Web    | wget      |

## Change home directory
``` bash
$ mkpasswd -l > /etc/passwd

$ vim /etc/passwd
< home/<username>
> /cygdrive/c/Users/<username>
```

## cygwin options
* Looks > Transparency: Medium
* Text > Font: MSゴシック

## Setup git
``` bash
$ git config --global user.name "syunkitada"
$ git config --global user.email "syun.kitada@gmail.com"
```

## Setup ssh key
### create ssh key
``` bash
$ ssh-keygen -t rsa -b 4096 -C "hoge@piyo.com"
```

### Deproy ssk key
Deproy created ssh public key (.ssh/id_rsa.pub) to github or your server.

Register ssh public key to github, and ssh to github by bash and putty.
``` bash
$ ssh -T git@github.com
```

To use ssh-angent on github, export path of plink.exe to GIT_SSH.
``` bash
$ export GIT_SSH=plinkパス
```

Create secret key of putty (id_rsa.ppk).
And, create following shortcut.
``` bash
pagent.exe C:\Users\<username>\.ssh\id_rsa.ppk
```

## Setup dot files
``` bash
# In cygwin
$ git clone git@github.com:syunkitada/home.git
$ cd home
$ ./setup_win_clone_neobundle.sh
```

# In exploler
Run setup_win.bat by admin.
setu_win.bat create symbolic link from dot files to home directory.
Edit .bashrc or .zshrc, and setup path plink.exe.

## Setup vim
* Run vim on cygwin. First, install plugins by neobundle.
* Copy [gvim]/plugins/vimproc/autoload/vimproc_win64.dll to .vim/bundle/vimproc/autoload/ for vimshell on gvim 
* To execute cygwin command on vimshell, add path of cygwin64/bin to PATH of env.

## Setup python
1. Install [setuptools](https://pypi.python.org/pypi/setuptools)
  * Download [ez_setup.py](https://bootstrap.pypa.io/ez_setup.py) and execute "$ python ez_setup.py".
2. install pip
``` bash
$ easy_install pip
```

## Disable deflag if ssd
* Disable by "ドライブのデフラグと最適化"

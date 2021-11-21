# Windows Setup Manual (For myself)

## Contents

| Link                                                | Description                                          |
| --------------------------------------------------- | ---------------------------------------------------- |
| [Install common software](#install-common-software) | 基本的なソフトウェアをインストール                   |
| [Install cygwin](#install-cygwin)                   | cygwin のインストールとセットアップ                  |
| [Setup ssh key](#setup-ssh-key)                     | ssh-key を作成し、putty-agent で利用できるようにする |
| [Setup dot files](#setup-dot-files)                 | dotfiles(.vimrc など)の展開                          |
| [Setup vim](#setup-vim)                             | vim(gvim)の設定                                      |
| [Setup RLogin](#setup-rlogin)                       | RLogin(SSH ターミナル)の設定                         |
| [Other Setup](#other-setup)                         | その他(デフラグ無効化)                               |

## Install common software

Install following software

| Soft                                                | Description                              |
| --------------------------------------------------- | ---------------------------------------- |
| Microsoft Security Essentials (Windows7)            |                                          |
| Windows Defender (Windows 8, 10: default installed) |                                          |
| GVIM                                                | GVIM [KaoriYa](https://www.kaoriya.net/) |
| Lhaplus                                             |                                          |
| Desktops                                            |                                          |
| VLC media player                                    |                                          |
| TrueCrypt                                           | Depricated                               |
| LibreOffice                                         |                                          |

## Install cygwin

- Install position: ~/Desktop/cygwin/cygwin64
  - local position: ~/Desktop/cygwin/local
- And Install 'KaoriYa gvim', 'putty', 'teraterm' to ~/Desktop/cygwin/

Install cygwin package is

| Category | Soft                                            |
| -------- | ----------------------------------------------- |
| Devel    | ctags, gcc (c, c++, objectiv-c, etc), git, make |
| Editor   | vim, vim-common                                 |
| Net      | bind-utils, curl, openssl                       |
| Python   | python, python-crypto                           |
| Shell    | zsh                                             |
| Tcl      | expect                                          |
| Utils    | tmux                                            |
| Web      | wget                                            |

Change home directory

```bash
# $ mkpasswd -l > /etc/passwd
#
# $ vim /etc/passwd
# < home/<username>
# > /cygdrive/c/Users/<username>

$ vim .bash_profile
HOME=/cygdrive/c/Users/[user]
cd ~
source .bash_profile
```

Set cygwin options

- Looks > Transparency: Medium
- Text > Font: MS ゴシック

Setup git

```bash
$ git config --global user.name "syunkitada"
$ git config --global user.email "syun.kitada@gmail.com"
```

## Setup ssh key

### create ssh key

```bash
$ ssh-keygen -t rsa -b 4096 -C "hoge@piyo.com"
```

### Deproy ssk key

Deproy created ssh public key (.ssh/id_rsa.pub) to github or your server.

Register ssh public key to github, and ssh to github by bash and putty.

```bash
$ ssh -T git@github.com
```

To use ssh-angent on github, export path of plink.exe to GIT_SSH.

```bash
$ export GIT_SSH=plinkパス
```

Create secret key of putty (id_rsa.ppk).
And, create following shortcut.

```bash
pagent.exe C:\Users\<username>\.ssh\id_rsa.ppk
```

## Setup dot files

```bash
# In cygwin
$ git clone git@github.com:syunkitada/home.git
$ cd home
$ ./setup_win_clone_neobundle.sh
```

In exploler

- Run setup_win.bat by admin.
  - setu_win.bat create symbolic link from dot files to home directory.
- Edit .bashrc or .zshrc, and setup path plink.exe.

## Setup vim

- Run vim on cygwin. First, install plugins by dein.
- Add path of cygwin/bin to PATH of env. for GVIM.

## Setup RLogin

- Download
  - https://github.com/kmiya-culti/RLogin/releases/
- default 設定用の接続先を作成する
  - コピペ用のショートカット設定
    - キーボード
      - Key Code: INSERT + Shift
      - Assign String: $EDIT_PASTE
  - 接続先のホストを表示する
    - カラー > 背景設定
      - 「バックグランド画像にテキストを追加」にチェック
  - SSH 設定
    - 通信共有
      - 「接続が切れてもウィンドウを閉じない」にチェック
    - プロトコル
      - 「エージェント転送を有効にする」にチェック
      - 「KeepAlive パケットの送信間隔(sec) 300」にチェック
  - tmux 経由のコピペをできるようにする
    - クリップボード > 制御コードによるクリップボード操作
      - 「クリップボードの読み込みを許可」にチェック
      - 「クリップボードの書き込みを許可」にチェック
- default 設定を右クリックオプションから、「標準の設定にする」をクリック
- 以降のサーバ設定は、「サーバ」の項目の「このページ以外のオプションは標準の設定を使用します」にチェックを入れる

## Setup WSL(Ubuntu 18.04)

- オプションを開き、Ctrl+Shift+C/V によるコピペを有効にする
- [Ubuntu](ubuntu.md)

## Other setup

- Disable deflag if ssd
  - Disable by "ドライブのデフラグと最適化"

## KeePassXC

- パスワード管理用
- https://keepassxc.org/download/#windows

## drawio-desktop

- ダイアグラムエディタ
- https://github.com/jgraph/drawio-desktop/releases
- 特徴
  - 一般的なダイアグラムエディタの機能は備えている
  - ローカルで利用可能
  - エクセルのようなタブ機能がある

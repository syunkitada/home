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

| Soft                                                | Description                                    |
| --------------------------------------------------- | ---------------------------------------------- |
| Microsoft Security Essentials (Windows7)            |                                                |
| Windows Defender (Windows 8, 10: default installed) |                                                |
| GVIM                                                | GVIM [KaoriYa](https://www.kaoriya.net/)       |
| Lhaplus                                             |                                                |
| Desktops                                            |                                                |
| VLC media player                                    |                                                |
| VeraCrypt                                           | 暗号仮想ディスクの管理ソフト、TrueCrypt の後継 |
| LibreOffice                                         |                                                |

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

## Setup WSL(Ubuntu)

- Microsoft StoreからUbuntuをインストールしてください
  - バージョン固定されてるものではなく、無印のUbuntuをインストールしてください
- ターミナルヘッダを右クリックして、プロパティのオプションを開き、Ctrl+Shift+C/V によるコピペを有効にする

#### ssh の設定

1. "C:\Users\[User]\.ssh" のフォルダを、"C:\Users\[User]\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu_XXX\LocalState\rootfs\home\[User]"にコピー
2. その後ターミナルから.ssh の権限を適切に変更する

```
$ sudo chown -R owner:owner .ssh
$ chmod 700 ~/.ssh/id_* ~/.ssh/config ~/.ssh/known_hosts
```

3. ssh-agent を起動

```
$ ssh-agent
SSH_AUTH_SOCK=/tmp/ssh-XXXXXXXqFtJP/agent.88; export SSH_AUTH_SOCK;
SSH_AGENT_PID=89; export SSH_AGENT_PID;
echo Agent pid 89;
$ SSH_AUTH_SOCK=/tmp/ssh-XXXXXXXqFtJP/agent.88; export SSH_AUTH_SOCK;

$ ssh-add
```

#### shell のセットアップ

```
$ sudo apt install make
$ git clone git@github.com:syunkitada/home.git
$ cd home
$ make setup
```

#### ssh のセットアップ(ターミナル起動後に ssh が必要な場合は毎回以下を実施してください)

shell のセットアップ後は、以下で ssh-agent の起動と ssh-add ができます

```
ssh_add
```

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

## VSCode

- プラグイン
  - Vim
  - Drawio Integration
    - hoge.dio.svg, hoge.drawio.svgのファイルを作成するとVSCode上でDrawioが利用できる

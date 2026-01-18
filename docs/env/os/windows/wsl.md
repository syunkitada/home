# WSL

WSL (Windows Subsystem for Linux) は、Windows 上で Linux 環境を実行するための技術です。

WSL1は、 LxCore/Lxss というサブシステムを利用し、Linux のシステムコールを Windows NT カーネル API に翻訳（トランスレーション） して実行します。Linux カーネル自体は動作せず、Windows カーネル上で Linux バイナリを直接実行する「互換レイヤー」として機能します。

WSL2は、Hyper-V の軽量仮想マシン技術を使用し、本物の Linux カーネルを仮想マシン内で直接実行します。Microsoft がカスタマイズした Linux カーネルが Windows Update を通じて配布・更新されます。

## WSL1とWSL2の違い

| 項目 | WSL1	| WSL2 |
| --- | --- | --- |
| コア構造 | LinuxシステムコールをWindowsのAPIに変換 | Hyper-V上で本物のLinuxカーネルを実行 |
| システムコールの互換性 |	一部制限あり |	ほぼ完全な互換性 |
| ルートファイルシステム |	WindowsのNTFS上に独自の変換レイヤーを用意	 |仮想ディスク上のext4 |
| Linuxファイルシステムへのアクセス |	低速	 |高速 |
| Windowsファイルシステムへのアクセス	 |高速 |	低速 |
| ネットワーク |	Windowsと同一IPアドレス、同一ホストとして動作	 |独立した仮想NICによるNAT構成 |
| 起動速度 |	高速	 |軽量VMを起動するためやや低速 |
| メモリ使用量 |	少ない	 |やや多い(設定可能) |
| Dockerの動作 |	非対応 |	対応 |
| systemdの動作 |	非対応	| 対応 |

## 使い分け

基本的にはWSL2で困ってなければWSL2を使うのがよいと思います。

一方でWSL1を使いたい場面がいくつかあります。

- Windowsファイルシステムに頻繁にアクセスする場合
  - WSL2はWindowsファイルシステムへのアクセスが非常に遅いので、WSL1の方が都合が良い場合があります。
- セキュリティ上の理由でWSL2の利用が禁止されてる場合
  - よくある企業はセキュリティソフトウェアを従業員端末にインストールし、その端末上のプロセスや通信を監視しています。
  - しかし、WSL2はVMとして動作するため、そのVM上で動いてるプロセスやネットワーク通信などを監視することができません。
  - また、RancherなどでWSL2のVM上でコンテナなどを利用している場合は、その監視はさらに難しくなります。
  - このため、WSL2の利用自体を禁止している企業もあります。

## WSL1、WSL2の有効化

1. コントロールパネル を開く
　- （Windows キー → 「コントロールパネル」で検索）
2. プログラム → プログラムと機能 を選択
3. 左側の 「Windows の機能の有効化または無効化」 をクリック
4. リストから
   a.  WSL1を有効にするには、「Linux 用 Windows サブシステム」にチェックを入れる
   b.  WSL2を有効にするには、「仮想マシン プラットフォーム」チェックを入れる
5. 「OK」を押すと、PCの再起動を求められるので、PC を再起動する
6. PC再起動後、設定が有効になります。


## ディストリビューションのインストール

```
> wsl.exe -l --online
インストールできる有効なディストリビューションの一覧を次に示します。
'wsl.exe --install <Distro>' を使用してインストールします。

NAME                            FRIENDLY NAME
AlmaLinux-8                     AlmaLinux OS 8
AlmaLinux-9                     AlmaLinux OS 9
AlmaLinux-Kitten-10             AlmaLinux OS Kitten 10
AlmaLinux-10                    AlmaLinux OS 10
Debian                          Debian GNU/Linux
FedoraLinux-43                  Fedora Linux 43
FedoraLinux-42                  Fedora Linux 42
SUSE-Linux-Enterprise-15-SP7    SUSE Linux Enterprise 15 SP7
SUSE-Linux-Enterprise-16.0      SUSE Linux Enterprise 16.0
Ubuntu                          Ubuntu
Ubuntu-24.04                    Ubuntu 24.04 LTS
archlinux                       Arch Linux
eLxr                            eLxr 12.12.0.0 GNU/Linux
kali-linux                      Kali Linux Rolling
openSUSE-Tumbleweed             openSUSE Tumbleweed
openSUSE-Leap-16.0              openSUSE Leap 16.0
Ubuntu-20.04                    Ubuntu 20.04 LTS
Ubuntu-22.04                    Ubuntu 22.04 LTS
OracleLinux_7_9                 Oracle Linux 7.9
OracleLinux_8_10                Oracle Linux 8.10
OracleLinux_9_5                 Oracle Linux 9.5
openSUSE-Leap-15.6              openSUSE Leap 15.6
SUSE-Linux-Enterprise-15-SP6    SUSE Linux Enterprise 15 SP6
```

```
> wsl --install Ubuntu-24.04
ダウンロードしています: Ubuntu 24.04 LTS
インストールしています: Ubuntu 24.04 LTS
ディストリビューションが正常にインストールされました。'wsl.exe -d Ubuntu-24.04' を使用して起動できます
Ubuntu-24.04 を起動しています...
Provisioning the new WSL instance Ubuntu-24.04
This might take a while...
Create a default Unix user account: owner
New password:
Retype new password:
passwd: password updated successfully
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.
```

## WSL1, WSL2の変換

WSL1, WSL2は以下のように数分で変換できます。

```
# WSL2からWSL1への変換
> wsl -l -v
  NAME                    STATE           VERSION
* Ubuntu-24.04            Stopped         2

> wsl --set-version Ubuntu-24.04 1
変換中です。これには数分かかる場合があります。
この操作を正しく終了しました。

> wsl -l -v
* Ubuntu-24.04            Stopped         1
```

```
# WSL1からWSL2への変換
> wsl -l -v
* Ubuntu-24.04            Stopped         1

> wsl --set-version Ubuntu-24.04 2
変換中です。これには数分かかる場合があります。..
この操作を正しく終了しました。

> wsl -l -v
  NAME                    STATE           VERSION
* Ubuntu-24.04            Stopped         2
```

## インストールしたディストリビューションを登録解除する

```
> wsl --unregister Ubuntu-24.04
登録解除。
この操作を正しく終了しました。
```

## WSL1: SSH

```
$ mkdir ~/.ssh
$ cp /mnt/c/Users/[user]/.ssh/[key file] ~/.ssh/
$ sudo chown -R owner:owner .ssh
$ chmod 600 .ssh/[key file]

$ ssh-agent
SSH_AUTH_SOCK=/tmp/ssh-XXXXXXXqFtJP/agent.88; export SSH_AUTH_SOCK;
SSH_AGENT_PID=89; export SSH_AGENT_PID;
echo Agent pid 89;
$ SSH_AUTH_SOCK=/tmp/ssh-XXXXXXXqFtJP/agent.88; export SSH_AUTH_SOCK;

$ ssh-add
$ ssh-add -L
...

$ ssh hoge
```

## WindowsとWSL1のSSHセッション共有について

Windowsは標準でSSHクライアントをサポートしていますが、WSL1はWSL1でSSHクライアントをサポートしています。

WindowsのSSHクライアントの問題点として、セッション共有ができないという問題があります。

通常、`.ssh/config` に以下の設定を書くことで、マスターセッションを共有して他のSSHでも使い回すことができます。

しかし、WindowsのPowerShellからこれを実行すると、エラーとなりSSHができません。

一方、WSL1ではこのセッション共有を利用することができます。

```
$ vim .ssh/config
...
Host *
    ControlMaster auto
    ControlPath ~/.ssh/mux-%r@%h:%p
    ControlPersist 30m
...
```

ちなみに、PowerShellから、wsl上でコマンドを実行することもできるので、以下のようにするとWSL1上のセッション共有を使ってSSHをすることができます。

```
> wsl -d Ubuntu-24.04 -e ssh dev01.pm.local.test
```

これを応用し、以下の内容で、`wslssh.cmd` というファイル名を作っておくと、

```
@echo off
REM WSL ssh wrapper
REM Usage: ssh host [args...]

wsl -d Ubuntu-24.04 -e ssh %*
```

以下のようにsshを実行することができます。

```
> ./wslssh [hostname]
```

VSCodeから利用する場合は、"Remote SSH" の "Settings"を開き、"Remote.SSH: Path" にwslsshのパスを入れることで、VSCodeでSSHのセッション共有が利用できます。

```
    "remote.SSH.path": "C:\\mytools\\wslssh.cmd"
```


## WSL1: Node.js 24が利用できない問題（対応方法なし）

```
owner@DESKTOP-LIRV6MD:~/home$ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
owner@DESKTOP-LIRV6MD:~/home$ export NVM_DIR="$HOME/.config/nvm"
owner@DESKTOP-LIRV6MD:~/home$ [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
owner@DESKTOP-LIRV6MD:~/home$ nvm install 24
v24.13.0 is already installed.
Now using node v24.13.0
owner@DESKTOP-LIRV6MD:~/home$ node -v
zsh: exec format error: node
```

node 22は利用できた。

```
$ nvm install 22

$ node -v
v22.22.0
```

```
$ /home/owner/.config/nvm/versions/node/v22.22.0/bin/node -v
v22.22.0

$ /home/owner/.config/nvm/versions/node/v24.13.0/bin/node -v
zsh: exec format error: /home/owner/.config/nvm/versions/node/v24.13.0/bin/node
```

### WSL1からWindows側のnodeを利用するみたいなことはできない

```
wget install OpenJS.NodeJS.LTS
```

```
> node.exe -v
v24.13.0

> gcm node

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Application     node.exe                                           24.13.0.0  C:\Program Files\nodejs\node.exe
```

```
$ alias node="/mnt/c/Program\ Files/nodejs/node.exe"
$ alias npm="/mnt/c/Program\ Files/nodejs/npm"
$ alias npx="/mnt/c/Program\ Files/nodejs/npx"

$ /mnt/c/Program\ Files/nodejs/node.exe -v
v24.13.0

$ npx -h
WSL 1 is not supported. Please upgrade to WSL 2 or above.
Could not determine Node.js install directory

$ npm -h
WSL 1 is not supported. Please upgrade to WSL 2 or above.
Could not determine Node.js install directory
```
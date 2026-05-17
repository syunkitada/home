# SSH

Windows の SSH 環境を整えるための手順です。

Windows で SSH を利用する方法は３つあります。

- WSLのOpenSSH を利用する方法（推奨）
  - セッション共有機能を利用することができます。
  - VSCodeからWSLのOpenSSH を利用するには少し工夫が必要です。
- Windows標準の OpenSSH を利用する方法
  - Windows10 以降に標準で搭載されている OpenSSH の ssh-agent を利用する方法です。
  - VSCode や PowerShell などは、OpenSSH を利用して SSH 接続を行います。
  - RLogin などの一部 SSH クライアントも OpenSSH の ssh-agent を利用することができます。
  - 注意として、セッション共有機能が利用できないこと注意してください。
- pagent(PuTTY Agent)を利用する方法
  - PuTTY は、Windows 用の SSH クライアントです。
  - PuTTY は、SSH キーの生成ツールや SSH エージェント(PAGENT)を含む、SSH 関連のツールを提供しています。
  - PAGENT は、PuTTY 以外の一部の SSH クライアント(RLogin など)も利用できます。

SSHのセッション共有機能について

- セッション共有機能とは、リモートサーバに接続する際に既存のセッションを共有して接続する機能です。
- セッション共有のメリット
  - 都度セッションを確立しなくてよいのでシンプルに高速化できます。
  - 都度認証しなくてよいので、鍵認証だけでなく二要素認証などの追加認証もスキップすることができます。
- VSCodeなどでリモート開発する場合、途中経路の二要素認証を突破する手段としてセッション共有はよく使われています。
- セッション共有が必要な場合は、WSLのOpenSSHを利用する必要があります。

## WSL: OpenSSHを利用する方法

```
$ vim ~/.ssh/config
...
Host *
    ControlMaster auto
    ControlPath ~/.ssh/cm/%C
    ControlPersist 36000m
...
```

PowerShellから、wsl上でコマンドを実行することもできるので、以下のようにするとWSL1上のセッション共有を使ってSSHをすることができます。

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

## WSL: SSH Agentを利用する方法

```
$ ssh-agent
SSH_AUTH_SOCK=/tmp/ssh-XXXXXXXqFtJP/agent.88; export SSH_AUTH_SOCK;
SSH_AGENT_PID=89; export SSH_AGENT_PID;
echo Agent pid 89;
$ SSH_AUTH_SOCK=/tmp/ssh-XXXXXXXqFtJP/agent.88; export SSH_AUTH_SOCK;

$ ssh-add
$ ssh-add -L
...
```

SSH エージェント転送を利用している場合は、リモートサーバでもssh-add -Lをやったときに鍵が表示されることを確認してください。

```
$ ssh -A hoge
hoge: $ ssh-add -L
...
```

## OpenSSH Agentを利用する方法

### Enable SSH Agent Service

管理者権限で PowerShell を起動する

```
> Start-Process -Verb runas powershell
```

SSH Agent サービスを有効にします。

```
> Get-Service ssh-agent | Set-Service -StartupType Automatic -PassThru | Start-Service -PassThru | Select-Object -Property Name, StartType, Status
```

### Use OpenSSH Agent

SSH Agnet に鍵を追加します。

```
> ssh-add
```

以下で SSH できるようになります。

```
> ssh -A <user>@<target>
```

また、本ディレクトリに、ssh-adder という名前のシュートカットを配置してあるので、これを Windows のタスクバーに登録しておきます。

これによりタスクバーから ssh-add が実行できるようになります。

### Setup RLogin

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
      - 「認証キー」の「認証キーリスト」上に ssh-add したキーが表示されているのでチェックを入れる
  - tmux 経由のコピペをできるようにする
    - クリップボード > 制御コードによるクリップボード操作
      - 「クリップボードの読み込みを許可」にチェック
      - 「クリップボードの書き込みを許可」にチェック
  - フォントの設定
    - `Consolas`に設定する
- default 設定を右クリックオプションから、「標準の設定にする」をクリック
- 以降のサーバ設定は、「サーバ」の項目の「このページ以外のオプションは標準の設定を使用します」にチェックを入れる

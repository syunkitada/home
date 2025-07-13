# SSH

WindowsのSSH環境を整えるための手順です。

WindowsでSSHを利用する方法は二つあります。

- OpenSSH Agentを利用する方法
  - Windows10以降に標準で搭載されているOpenSSHのssh-agentを利用する方法です。
  - VSCodeやPowerShellなどは、OpenSSHを利用してSSH接続を行います。
  - RLoginなどの一部SSHクライアントもOpenSSHのssh-agentを利用することができます。
- pagent(PuTTY Agent)を利用する方法
  - PuTTYは、Windows用のSSHクライアントです。
  - PuTTYは、SSHキーの生成ツールやSSHエージェント(PAGENT)を含む、SSH関連のツールを提供しています。
  - PAGENTは、PuTTY以外の一部のSSHクライアント(RLoginなど)も利用できます。

## Enable SSH Agent Service

管理者権限でPowerShellを起動する

```
> Start-Process -Verb runas powershell
```

SSH Agent サービスを有効にします。

```
> Get-Service ssh-agent | Set-Service -StartupType Automatic -PassThru | Start-Service -PassThru | Select-Object -Property Name, StartType, Status
```

## Use OpenSSH Agent

SSH Agnet に鍵を追加します。

```
> ssh-add ...
```

以下でSSHできるようになります。

```
> ssh -A <user>@<target>
```

## Setup RLogin

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
      - 「認証キー」の「認証キーリスト」上にssh-addしたキーが表示されているのでチェックを入れる
  - tmux 経由のコピペをできるようにする
    - クリップボード > 制御コードによるクリップボード操作
      - 「クリップボードの読み込みを許可」にチェック
      - 「クリップボードの書き込みを許可」にチェック
  - フォントの設定
    - `Consolas`に設定する
- default 設定を右クリックオプションから、「標準の設定にする」をクリック
- 以降のサーバ設定は、「サーバ」の項目の「このページ以外のオプションは標準の設定を使用します」にチェックを入れる

## Use PAGENT

PuTTYのPAGENTを利用する場合の手順です。

OpenSSH Agentが利用できない場合や、PuTTYを利用したい場合は、以下の手順でPAGENTをセットアップします。

VSCodeやRLoginなどを利用する場合は、OpenSSHを利用できるので、この方法は必要ありません。

### PuTTYryをセットアップする

- [PuTTYrv (PuTTY-ranvis)](https://www.ranvis.com/putty) から 64bit.7z をダウンロードしてデスクトップに展開します。
- puttygen.exe
  - PuTTYのSSHキーを生成するためのツールです。
  - 既存のOpenSSHの秘密鍵をPuTTY形式に変換することもできます。
- pagent.exe
  - PuTTYのSSHエージェントです。
  - puttygen.exeで生成した秘密鍵を読み込んで利用します。
  - 以下のようにショートカットを作成しておき、タスクバーにピン留めしておくと便利です。
  - `C:\[Path...]\PuTTY-ranvis\pageant.exe C:\[Path...]\[Key Name].ppk`

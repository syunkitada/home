# SSH

Windows の SSH 環境を整えるための手順です。

Windows で SSH を利用する方法は二つあります。

- OpenSSH Agent を利用する方法
  - Windows10 以降に標準で搭載されている OpenSSH の ssh-agent を利用する方法です。
  - VSCode や PowerShell などは、OpenSSH を利用して SSH 接続を行います。
  - RLogin などの一部 SSH クライアントも OpenSSH の ssh-agent を利用することができます。
- pagent(PuTTY Agent)を利用する方法
  - PuTTY は、Windows 用の SSH クライアントです。
  - PuTTY は、SSH キーの生成ツールや SSH エージェント(PAGENT)を含む、SSH 関連のツールを提供しています。
  - PAGENT は、PuTTY 以外の一部の SSH クライアント(RLogin など)も利用できます。

ここでは、SSH Agent を利用する方法を採用します。

## Enable SSH Agent Service

管理者権限で PowerShell を起動する

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
> ssh-add
```

以下で SSH できるようになります。

```
> ssh -A <user>@<target>
```

また、本ディレクトリに、ssh-adder という名前のシュートカットを配置してあるので、これを Windows のタスクバーに登録しておきます。

これによりタスクバーから ssh-add が実行できるようになります。

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
      - 「認証キー」の「認証キーリスト」上に ssh-add したキーが表示されているのでチェックを入れる
  - tmux 経由のコピペをできるようにする
    - クリップボード > 制御コードによるクリップボード操作
      - 「クリップボードの読み込みを許可」にチェック
      - 「クリップボードの書き込みを許可」にチェック
  - フォントの設定
    - `Consolas`に設定する
- default 設定を右クリックオプションから、「標準の設定にする」をクリック
- 以降のサーバ設定は、「サーバ」の項目の「このページ以外のオプションは標準の設定を使用します」にチェックを入れる

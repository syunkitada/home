# Windows Setup Manual (For myself)

## Install common software

- Google Chrome
  - Chromeにいつものアカウント(ixxx@gmail.com)でログインし、タブやブックマークを同期する
- OneDrive
  - Ondriveにいつものアカウント(sxxx@gmail.com)でログインし、ドキュメントのみを同期する
  - デスクトップやピクチャは同期しない
- Lhaplus
  - [窓の社](https://forest.watch.impress.co.jp/library/software/lhaplus/) からインストーラをダウンロードしてインストールします。
  - Lhaplus は、LZH 形式の解凍に利用します。
  - Windows は一般的な圧縮解凍をサポートしていますが、LZH 形式はサポート外なので、Lhaplus を利用します。
- VLC media player
  - [窓の社](https://forest.watch.impress.co.jp/library/software/vlcmedia_ply/) からインストーラをダウンロードしてインストールします。
  - VLC media player は、オープンソースで開発されているメディアプレイヤーです。
- KeePassXC
  - [公式サイト](https://keepassxc.org/) からインストーラをダウンロードしてインストールします。
  - KeePassXC は、パスワード管理用のオープンソースソフトウェアです。
  - 2.7.10 において起動が失敗する問題がありましたが、これは以下の Microsoft Visual C++ Redistributable をインストールすることで解決しました。
    - https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170
- VeraCrypt
  - [窓の社](https://forest.watch.impress.co.jp/library/software/veracrypt/) からインストーラをダウンロードしてインストールします。
  - VeraCrypt は TrueCrypt の後継の暗号仮想ディスクの管理ソフトです。
- LiberOffice
  - [窓の社](https://forest.watch.impress.co.jp/library/software/libreoffice/) からインストーラをダウンロードしてインストールします。
  - LibreOffice は、オープンソースのオフィススイートです。
- フォント(moralerspace)
  - https://github.com/yuru7/moralerspace/releases/tag/v2.0.0

## Setup Git, NodeJS and VSCode

コマンドプロンプトを管理者権限で起動して、以下を実行してください。

まず、Git をインストールします。

```
> winget install -e --source winget --id Git.Git
```

その後、以下のコマンドを実行して Git の設定を行います。

```
> git config --global user.email "hoge@example.com"
> git config --global user.name "Your Name"
> git config --global commit.verbose true
> git config --global core.autocrlf false
```

次に、NodeJS をインストールします。

```
> winget install -e --source winget --id OpenJS.NodeJS.LTS
```

次に、VSCodeをインストールします

```
> winget install -e --source winget --id Microsoft.VisualStudioCode --override "/silent /mergetasks=""addcontextmenufiles,addcontextmenufolders"""
```

次に、デスクトップに移動してください。

```
> cd "~/Desktop"
```

```
> mkdir "github"
> git clone https://github.com/syunkitada/home "github\home"
> git clone https://github.com/syunkitada/home_ex "github\home_ex"
> git clone https://github.com/syunkitada/autohotkey "github\autohotkey"
```

[autohotkey](https://github.com/syunkitada/autohotkey) を参考に、Change Key/AutoHotkey のセットアップをします。
[vscode](./vscode.md) を参考に、VSCode をセットアップします。
[wsl](./wsl.md) を参考に、WSL をセットアップします。

## Disable SSD Defrag

- `ドライブのデフラグと最適化`によってデフラグを無効にします。
- SSD のデフラグは通常不要ですが、特定の状況では有効な場合があります。
  - 大読み書きする場合
  - SSD の空き容量が少ない場合
  - 特定のアプリケーションが SSD のパフォーマンスを最適化するためにデフラグを推奨している場合

## 配信の最適化で他のデバイスからのダウンロードを許可するをオフにする

設定 > Windows Update > 詳細オプション > 配信の最適化

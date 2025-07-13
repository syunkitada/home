# Windows Setup Manual (For myself)

## Install common software

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

## Setup Git and VSCode

コマンドプロンプトを管理者権限で起動して、以下を実行してください。

まず、Git をインストールします。

```
> winget install -e --id Git.Git
```

その後、以下のコマンドを実行して Git の設定を行います。

```
> git config --global user.email "hoge@example.com"
> git config --global user.name "Your Name"
> git config --global commit.verbose true
```

次に、デスクトップに移動してください。

OneDrive を利用している場合は、OneDrive のデスクトップディレクトリに移動してください。

```
> cd "%UserProfile%\Desktop"
or
> cd "%UserProfile%\OneDrive\Desktop"
```

次に、GitHub のリポジトリをクローンして、セットアップスクリプトを実行します。

```
> mkdir "github"
> git clone https://github.com/syunkitada/home "github\home"
> cd "github\home\docs\env\os\windows\vscode"
> setup.bat
```

home をプロジェクトフォルダとして、VSCode を起動して、RECOMENDED EXTENSIONS をインストールします。

## Setup KeyBind

[autohotkey](https://github.com/syunkitada/autohotkey) を参考に、Change Key/AutoHotkey のセットアップをします。

## Setup SSH Environment

[ssh](./ssh/README.md) を参考に、SSH 環境をセットアップします。

## Disable SSD Defrag

- `ドライブのデフラグと最適化`によってデフラグを無効にします。
- SSD のデフラグは通常不要ですが、特定の状況では有効な場合があります。
  - 大量の小さなファイルを頻繁に読み書きする場合
  - SSD の空き容量が少ない場合
  - 特定のアプリケーションが SSD のパフォーマンスを最適化するためにデフラグを推奨している場合

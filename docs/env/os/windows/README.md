# Windows Setup Manual (For myself)

## Contents

| Link                                      | Description                |
| ----------------------------------------- | -------------------------- |
| [Install software](#install-software)     | ソフトウェアをインストール |
| [Setup VSCode](#setup-vscode)             | VSCodeの設定               |
| [Setup RLogin](#setup-rlogin)             | RLoginの設定               |
| [Disable SSD Defrag](#disable-ssd-defrag) | SSDのデフラグを無効化      |

## Install common software

- Lhaplus
  - [窓の社](https://forest.watch.impress.co.jp/library/software/lhaplus/) からインストーラをダウンロードしてインストールします。
  - Lhaplusは、LZH形式の解凍に利用します。
  - Windowsは一般的な圧縮解凍をサポートしていますが、LZH形式はサポート外なので、Lhaplusを利用します。
- VLC media player
  - [窓の社](https://forest.watch.impress.co.jp/library/software/vlcmedia_ply/) からインストーラをダウンロードしてインストールします。
  - VLC media playerは、オープンソースで開発されているメディアプレイヤーです。
- KeePassXC
  - [公式サイト](https://keepassxc.org/) からインストーラをダウンロードしてインストールします。
  - KeePassXCは、パスワード管理用のオープンソースソフトウェアです。
  - 2.7.10 において起動が失敗する問題がありましたが、これは以下のMicrosoft Visual C++ Redistributableをインストールすることで解決しました。
    - https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170
- VeraCrypt
  - [窓の社](https://forest.watch.impress.co.jp/library/software/veracrypt/) からインストーラをダウンロードしてインストールします。
  - VeraCryptはTrueCryptの後継の暗号仮想ディスクの管理ソフトです。
- LiberOffice
  - [窓の社](https://forest.watch.impress.co.jp/library/software/libreoffice/) からインストーラをダウンロードしてインストールします。
  - LibreOfficeは、オープンソースのオフィススイートです。

## Setup by command prompt

コマンドプロンプトを管理者権限で起動して、以下を実行してください。

まず、Gitをインストールします。

```
> winget install -e --id Git.Git
```

その後、以下のコマンドを実行してGitの設定を行います。

```
> git config --global user.email "hoge@example.com"
> git config --global user.name "Your Name"
> git config --global commit.verbose true
```

次に、デスクトップに移動してください。

OneDriveを利用している場合は、OneDriveのデスクトップディレクトリに移動してください。

```
> cd "%UserProfile%\Desktop"

> cd "%UserProfile%\OneDrive\Desktop"
```

次に、GitHubのリポジトリをクローンして、セットアップスクリプトを実行します。

```
> mkdir "github"
> git clone https://github.com/syunkitada/home "github\home"
> cd "github\home\windows"
> bootstrap.bat
```

homeをプロジェクトフォルダとして、VSCodeを起動して、RECOMENDED EXTENSIONSをインストールします。

## Setup KeyBind

[autohotkey](https://github.com/syunkitada/autohotkey) を参考に、Change Key/AutoHotkey のセットアップをします。

## Setup SSH Environment

[ssh](./ssh.md) を参考に、SSH環境をセットアップします。

## Disable SSD Defrag

- `ドライブのデフラグと最適化`によってデフラグを無効にします。
- SSDのデフラグは通常不要ですが、特定の状況では有効な場合があります。
  - 大量の小さなファイルを頻繁に読み書きする場合
  - SSDの空き容量が少ない場合
  - 特定のアプリケーションがSSDのパフォーマンスを最適化するためにデフラグを推奨している場合

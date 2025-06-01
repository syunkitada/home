# Windows Setup Manual (For myself)

## Contents

| Link                                      | Description                |
| ----------------------------------------- | -------------------------- |
| [Install software](#install-software)     | ソフトウェアをインストール |
| [Setup VSCode](#setup-vscode)             | VSCodeの設定               |
| [Setup RLogin](#setup-rlogin)             | RLoginの設定               |
| [Disable SSD Defrag](#disable-ssd-defrag) | SSDのデフラグを無効化      |

## Install software

- Lhaplus
  - [窓の社](https://forest.watch.impress.co.jp/library/software/lhaplus/) からインストーラをダウンロードしてインストールします。
  - Lhaplusは、LZH形式の解凍に利用します。
  - Windowsは一般的な圧縮解凍をサポートしていますが、LZH形式はサポート外なので、Lhaplusを利用します。
- Git for Windows
  - wingetを利用してインストールします。
  - `winget install -e --id Git.Git`
  - その後、以下のコマンドを実行してGitの設定を行います。
  - `git config --global user.email "hoge@example.com"`
  - `git config --global user.name "Your Name"`
  - `git config --global commit.verbose true`
- VSCode/Neovim
  - wingetを利用してインストールします。
  - `winget install vscode --override "/silent /mergetasks=""addcontextmenufiles,addcontextmenufolders"""`
  - `winget install -e --id neovim`
- Change Key/AutoHotkey
  - [autohotkey](https://github.com/syunkitada/autohotkey) を参考に、Change Key/AutoHotkey のセットアップをします。
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
- PuTTYry
  - [PuTTYrv (PuTTY-ranvis)](https://www.ranvis.com/putty) から 64bit.7z をダウンロードしてデスクトップに展開します。
  - puttygen.exe
    - PuTTYのSSHキーを生成するためのツールです。
    - 既存のOpenSSHの秘密鍵をPuTTY形式に変換することもできます。
  - pagent.exe
    - PuTTYのSSHエージェントです。
    - puttygen.exeで生成した秘密鍵を読み込んで利用します。
    - 以下のようにショートカットを作成しておき、タスクバーにピン留めしておくと便利です。
    - `C:\[Path...]\PuTTY-ranvis\pageant.exe C:\[Path...]\[Key Name].ppk`
- RLogin
  - [Github: Releases](https://github.com/kmiya-culti/RLogin/releases/) から最新版をダウンロードして展開します。

## Setup VSCode

WIP

- プラグイン
  - VSCode Neovim
  - Drawio Integration
    - hoge.dio.svg, hoge.drawio.svgのファイルを作成するとVSCode上でDrawioが利用できます。
  - TODO
    - VIMの設定

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
  - tmux 経由のコピペをできるようにする
    - クリップボード > 制御コードによるクリップボード操作
      - 「クリップボードの読み込みを許可」にチェック
      - 「クリップボードの書き込みを許可」にチェック
  - フォントの設定
    - `Consolas`に設定する
- default 設定を右クリックオプションから、「標準の設定にする」をクリック
- 以降のサーバ設定は、「サーバ」の項目の「このページ以外のオプションは標準の設定を使用します」にチェックを入れる

## Disable SSD Defrag

- `ドライブのデフラグと最適化`によってデフラグを無効にします。
- SSDのデフラグは通常不要ですが、特定の状況では有効な場合があります。
  - 大量の小さなファイルを頻繁に読み書きする場合
  - SSDの空き容量が少ない場合
  - 特定のアプリケーションがSSDのパフォーマンスを最適化するためにデフラグを推奨している場合

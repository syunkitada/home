# Home

このリポジトリは、自分用の設定・ドキュメントを管理するためのものです。

## Contents

| Link                                         | Description                                                  |
| -------------------------------------------- | ------------------------------------------------------------ |
| [docs](docs/README.md)                       | 雑多なドキュメント類です。                                   |
| [dotfiles](dotfiles/README.md)               | $HOME に配置するドットファイル群です。                       |
| [xdgconfig](xdgconfig/README.md)             | $XDG_CONFIG_HOME に配置するファイル群です。                  |
| [legacy_dotfiles](legacy_dotfiles/README.md) | 古い環境用の最小限の設定のためのドットファイル群です。       |
| [playground](playground/README.md)           | 設定ファイルの動作を確認するための実験環境構築ツール群です。 |
| [etc](etc/README.md)                         | 雑多なファイル群です。                                       |
| [scripts](scripts/README.md)                 | 雑多なスクリプトファイル群です。                             |

## Initial setup procedures for each OS

- [Setup Windows](docs/env/os/windows/README.md)
- [Setup Ubuntu](docs/env/os/ubuntu/README.md)

Linux共通のセットアップ（Windows WSL1はサポート外）

```bash
$ git clone git@github.com:syunkitada/home.git
$ git clone git@github.com:syunkitada/home_ex.git

$ make
$ make check
```

デフォルトのshellをzshに変更します。

```bash
$ sudo chsh -s $(which zsh) $(whoami)
```

shellを変更したあと、ログインし直してshellが変更されてることを以下のコマンドで確認してください。

```bash
$ echo $SHELL
```

もし、shellが変更されてなかったら、以下のポイントをチェックしてください。

```bash
# 1. /etc/passwd内のshellが変更されているか確認してください。
$ grep $(whoami) /etc/passwd

# 2. shellのセッションが使い回されていないか確認してください。
# もし、以下のような.ssh/configでSSHセッション共有の設定をしているばあいは、セッションを明示的に閉じてから再接続してください。
$ cat .ssh/config
ControlMaster auto
ControlPath ~/.ssh/mux-%n
ControlPersist 3600

# セッションを明示的に閉じるには以下のコマンドを実行してください。
$ ssh -O exit <your ssh host>
```

## About home_ex directory

home_ex ディレクトリをホームディレクトリに配置することで、homeの設定・ドキュメントを拡張することができます。

この仕組みは、プライベート開発環境や会社用開発環境など複数の環境の設定を分けて管理できるようにするための仕組みです。

```bash
$ git clone <your external respository> ~/home_ex
```

以下のファイルがサポートされています。

```bash
home_ex/
  docs/
    cmd/  <-- For managing docs of command line tools
      *.md
    ops/  <-- For managing docs of operations
      *.md
  xdgconfig/
    confrc <-- The configuration files for overriding ./scripts/confrc
    zsh/  <-- The configuration files are loaded by zsh
      *.zsh
    nvim/  <-- The configuration files are loaded by nvim
      *.vim
```

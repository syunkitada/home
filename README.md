# Home

このリポジトリは、自分用の設定・ドキュメントを管理するためのものです。

## Index

| Link | Description |
| --- | --- |
| [archives/](archives/) | 旧設定や過去の環境用ファイルを保管しています。 |
| [agents/](agents/README.md) | エージェントの設定と共通スキル、およびリンク配置スクリプトを管理します。 |
| [docs/](docs/README.md) | OSのセットアップ手順や、このリポジトリ自体のドキュメントをまとめています。 |
| [home/](home/README.md) | `$HOME` に配置する設定ファイル群です。 |
| [home_legacy/](home_legacy/README.md) | 古い環境用の最小限の設定ファイル群です。 |
| [knowledge/](knowledge/README.md) | 技術知識や運用ノウハウなどの資料をまとめています。 |
| [playground/](playground/README.md) | 設定ファイルの動作を確認するための実験環境です。 |
| [scripts/](scripts/README.md) | セットアップ、チェック、ドキュメント生成用のスクリプト群です。 |
| [.gitignore](.gitignore) | Gitの管理対象外にするファイル・ディレクトリの定義です。 |
| [AGENTS.md](AGENTS.md) | リポジトリで作業するエージェント向けのガイドラインです。 |
| [Makefile](Makefile) | セットアップ、チェック、ドキュメント生成などの入口です。 |

## Initial setup procedures for each OS

- [Setup Windows](docs/env/os/windows/README.md)
- [Setup Ubuntu](docs/env/os/ubuntu/README.md)

## `make` でセットアップされるもの

ルートで `make` を実行すると、既定の `all` ターゲットから `scripts/setup.sh` が実行されます。設定ファイルの配置、共通の開発ツール導入、OS別のパッケージ導入を行います。

| 区分 | セットアップ内容 | 補足 |
| --- | --- | --- |
| 設定ファイル | `home/.envrc`、`home/.zshrc`、`home/.config/` 内の設定を `$HOME` と `~/.config/` にリンクします。`~/.local/` も作成します。 | Herdrの状態ディレクトリが既にある場合は、管理対象ファイルだけをリンクします。 |
| Neovim・tmux・fzf・shfmt | エディタ、ターミナル多重化、検索、シェルスクリプト整形の各ツールを導入します。 | 導入方法とバージョン管理はOSによって異なります。 |
| Python | uvを導入し、`home/.local/mypython/` の定義に従って環境を同期します。pyrightも導入します。 | Python環境はuvで管理します。 |
| Node.js・Web開発 | nvmでNode.js 22系を導入し、TypeScript、Prettier、Tailwind CSS言語サーバー、Yarn、bash-language-serverなどをnpmで導入します。 | `NODE_VERSION` のメジャーバージョンを使います。 |
| Go | Goと、gopls・goimportsを導入します。 | macOSはHomebrew、Linuxは設定されたGoバージョンを導入します。 |
| C/C++ | clang、clangd、clang-formatなどの開発ツールを導入します。 | macOSではHomebrewのLLVMからclangdとclang-formatを `~/.local/bin/` に配置します。 |
| Rust | `ENABLE_RUST=true` の場合にrustupとcargo-binstallを導入します。 | 既定値は `false` です。さらに `ENABLE_MARKDOWN_OXIDE=true` の場合はmarkdown-oxideも導入します。 |
| `home_ex` 拡張 | `~/home_ex/scripts/setup.sh` があれば続けて実行します。 | プライベート設定などを追加できます。 |

OS別に導入する主なパッケージとツールは次のとおりです。

| OS | 主な導入内容 |
| --- | --- |
| macOS | Homebrewが必要です。fd、git、ripgrep、watchexec、zsh、Neovim、tmux、fzf、shfmt、Go、LLVMを導入します。Node.jsはnvmで導入します。 |
| Ubuntu 24.04 | aptで基本ツール、Python、tmux、clang一式を導入します。watchexec、ripgrep、fdも導入します。Neovim、fzf、GoなどはLinux向けの配布物を使います。 |
| Rocky Linux 9 | dnfで基本ツール、Python、コンパイル依存パッケージ、clang一式を導入します。tmuxはソースからビルドし、Neovim、fzf、GoなどはLinux向けの配布物を使います。 |

`make check` はNeovim、tmux、fzf、npm、Go、shfmtの有無を確認します。

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

## macOS setup

Homebrewをインストールし、`brew` コマンドを実行できる状態で、リポジトリを `~/home` に配置してから実行してください。

```bash
$ make
$ make check
```

## About home_ex directory

home_ex ディレクトリをホームディレクトリに配置することで、homeの設定・ナレッジを拡張することができます。

この仕組みは、プライベート開発環境や会社用開発環境など複数の環境の設定を分けて管理できるようにするための仕組みです。

```bash
$ git clone <your external respository> ~/home_ex
```

以下のファイルがサポートされています。

```bash
home_ex/
  knowledge/
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

# scripts

| スクリプト        | 説明                                                                            |
| ----------------- | ------------------------------------------------------------------------------- |
| [setup.sh](setup.sh) | OSに合わせて各種セットアップスクリプトを実行します。 |
| [check.sh](check.sh) | セットアップ後のチェックを実行します。 |
| [confrc](confrc) | セットアップの設定値（環境変数）を管理します。 |
| [setup_common.sh](setup_common.sh) | OS非依存のセットアップ関数とHerdr CLIのセットアップ関数をまとめています。 |
| [setup_common_ex.sh](setup_common_ex.sh) | 拡張用のセットアップ関数をまとめています。 |
| [setup_macos.sh](setup_macos.sh) | Homebrewを使ってmacOS用のツールをセットアップします。 |
| [setup_rocky9.sh](setup_rocky9.sh) | Rocky Linux 9用のセットアップを実行します。 |
| [setup_ubuntu24.sh](setup_ubuntu24.sh) | Ubuntu 24.04用のセットアップを実行します。 |
| [gen_keybind_doc.go](gen_keybind_doc.go) | キーバインドドキュメントを生成します。 |

## `make` でセットアップされるもの

ルートの `make` は既定の `all` ターゲットから `scripts/setup.sh` を実行します。実行順は、OS別基本パッケージ、Herdr、設定ファイルのリンク、環境変数の読み込み、ローカル環境、各開発ツール、`home_ex` の追加セットアップです。Herdr が未導入の場合はインストールしますが、既に導入されているHerdrは更新しません。

### 設定・拡張

| 対象 | 役割 | 管理する関数・ファイル |
| --- | --- | --- |
| 設定ファイル | `home/.envrc`、`home/.zshrc`、`home/.config/` の設定をホームディレクトリで使えるようにします。 | [setup_common.sh](setup_common.sh): `setup_dotfiles`。 |
| Herdr設定 | tmuxと揃えた操作キーを設定します。 | [setup_common.sh](setup_common.sh): `setup_dotfiles`。設定は [`home/.config/herdr/config.toml`](../home/.config/herdr/config.toml)。 |
| `home_ex` | プライベート設定や追加のセットアップを実行します。 | [setup.sh](setup.sh) が `~/home_ex/scripts/setup.sh` を呼び出します。 |

### ツールの用途と管理箇所

表の管理箇所は、ツールを導入・設定する関数と、その関数を定義するファイルです。Python環境の依存ツールは、依存関係を定義するファイルも記載しています。macOSではHomebrewを事前に用意する必要があります。

| カテゴリ | ツール | 用途・役割 | 管理する関数・ファイル |
| --- | --- | --- | --- |
| ターミナル環境 | Herdr | tmux風のキー操作でペインやタブ、セッションを扱います。 | [setup_common.sh](setup_common.sh): `setup_herdr`、`setup_dotfiles`。設定は [`home/.config/herdr/config.toml`](../home/.config/herdr/config.toml)。 |
| 通信 | curl | HTTP通信でインストーラーやファイルを取得します。 | Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh) `setup_base_tools`。Rocky Linux: [setup_rocky9.sh](setup_rocky9.sh) `setup_base_tools`。macOSはOS付属のものを使用します。 |
| バージョン管理 | git | ソースコードの変更履歴を管理します。 | [setup_macos.sh](setup_macos.sh)、[setup_ubuntu24.sh](setup_ubuntu24.sh)、[setup_rocky9.sh](setup_rocky9.sh): `setup_dev_tools`。 |
| シェル | zsh | 対話操作やログインに使うシェルです。 | [setup_macos.sh](setup_macos.sh)、[setup_ubuntu24.sh](setup_ubuntu24.sh)、[setup_rocky9.sh](setup_rocky9.sh): `setup_dev_tools`。 |
| ファイル検索 | findutils | `find` など、ファイルを検索・操作するコマンドを提供します。 | Rocky Linux: [setup_rocky9.sh](setup_rocky9.sh) `setup_base_tools`。macOSとUbuntuはOS付属の `find` を使用します。 |
| 通信 | wget | URLからファイルを取得します。 | Rocky Linux: [setup_rocky9.sh](setup_rocky9.sh) `setup_dev_tools`。Ubuntuでは `watchexec` の取得に使いますが、導入はしません。 |
| 開発支援 | watchexec | ファイル変更を検知して、指定したコマンドを再実行します。 | macOS: [setup_macos.sh](setup_macos.sh) `setup_dev_tools`。Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh) `setup_dev_tools`。 |
| ファイル検索 | fd | ファイル名を高速に検索します。 | macOS: [setup_macos.sh](setup_macos.sh) `setup_dev_tools`。Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh) `setup_dev_tools`。 |
| ファイル検索 | ripgrep | ファイルの内容を高速に検索します。 | macOS: [setup_macos.sh](setup_macos.sh) `setup_dev_tools`。Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh) `setup_dev_tools`。 |
| Python | pipx | Python製CLIを個別の仮想環境にインストールし、コマンドとして使えるようにします。 | macOS: [setup_macos.sh](setup_macos.sh) `setup_dev_tools`。 |
| GitHub | gh | 端末からGitHubのリポジトリ、Issue、Pull Requestなどを操作します。 | macOS: [setup_macos.sh](setup_macos.sh) `setup_dev_tools`。Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh) `setup_gh_cli`。Rocky Linux: [setup_rocky9.sh](setup_rocky9.sh) `setup_gh_cli` が GitHub Releases のRPMを取得して検証後にインストールします。 |
| Python | Python 3 | Pythonスクリプトや開発ツールを実行します。 | LinuxのシステムPython: [setup_ubuntu24.sh](setup_ubuntu24.sh)、[setup_rocky9.sh](setup_rocky9.sh) `setup_dev_tools`。プロジェクトPython: [setup_common.sh](setup_common.sh) `setup_dev_python`。 |
| Python | python3-venv | Pythonの仮想環境を作成する機能を提供します。 | Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh) `setup_dev_tools`。 |
| Python | python3-dev / python3-devel | Python拡張モジュールのビルドに使うヘッダーを提供します。 | Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh) `setup_dev_tools`。Rocky Linux: [setup_rocky9.sh](setup_rocky9.sh) `setup_dev_tools`。 |
| Python | uv | Pythonのバージョン、仮想環境、パッケージを管理します。 | [setup_common.sh](setup_common.sh): `setup_dev_python`。 |
| Python | Pythonプロジェクト環境 | Python開発ツールをプロジェクト単位で揃えます。 | [setup_common.sh](setup_common.sh): `setup_dev_python`。定義は [`.python-version`](../home/.local/mypython/.python-version)、[`pyproject.toml`](../home/.local/mypython/pyproject.toml)、[`uv.lock`](../home/.local/mypython/uv.lock)。 |
| Python | pip | Pythonパッケージをインストールします。 | [setup_common.sh](setup_common.sh) `setup_dev_python` と [`pyproject.toml`](../home/.local/mypython/pyproject.toml)。Linuxのシステム版は [setup_ubuntu24.sh](setup_ubuntu24.sh)、[setup_rocky9.sh](setup_rocky9.sh) の `setup_dev_tools`。 |
| Python | ruff | Pythonコードのチェックと整形を行います。 | [setup_common.sh](setup_common.sh) `setup_dev_python`。依存関係は [`pyproject.toml`](../home/.local/mypython/pyproject.toml) と [`uv.lock`](../home/.local/mypython/uv.lock)。 |
| Python | black | Pythonコードを定められた形式に整形します。 | [setup_common.sh](setup_common.sh) `setup_dev_python`。依存関係は [`pyproject.toml`](../home/.local/mypython/pyproject.toml) と [`uv.lock`](../home/.local/mypython/uv.lock)。 |
| Python | flake8 | Pythonコードの問題や規約違反を検出します。 | [setup_common.sh](setup_common.sh) `setup_dev_python`。依存関係は [`pyproject.toml`](../home/.local/mypython/pyproject.toml) と [`uv.lock`](../home/.local/mypython/uv.lock)。 |
| Python | isort | Pythonのimport文を整理・整列します。 | [setup_common.sh](setup_common.sh) `setup_dev_python`。依存関係は [`pyproject.toml`](../home/.local/mypython/pyproject.toml) と [`uv.lock`](../home/.local/mypython/uv.lock)。 |
| Python | pyright | Pythonの型を検査し、エディターの補完や診断を支援します。 | [setup_common.sh](setup_common.sh): `setup_dev_python`。 |
| JavaScript / TypeScript | nvm | Node.jsのバージョンを切り替えて管理します。 | [setup_macos.sh](setup_macos.sh)、[setup_ubuntu24.sh](setup_ubuntu24.sh)、[setup_rocky9.sh](setup_rocky9.sh): `setup_dev_tools`。バージョン設定は [confrc](confrc)。 |
| JavaScript / TypeScript | Node.js | JavaScriptを実行し、Web開発ツールの実行基盤になります。 | macOS: [setup_macos.sh](setup_macos.sh) `setup_dev_tools`。Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh) `setup_dev_tools`。Rocky Linux: [setup_rocky9.sh](setup_rocky9.sh) `setup_dev_tools`。バージョン設定は [confrc](confrc)。 |
| JavaScript / TypeScript | npm | Node.js用パッケージを管理します。 | Node.jsに付属します。OS別 `setup_dev_tools` でNode.jsを管理し、グローバルパッケージは [setup_common.sh](setup_common.sh) の `setup_dev_python`、`setup_dev_web`、`setup_dev_shell` が管理します。 |
| JavaScript / TypeScript | TypeScript | JavaScriptに型を加えた言語でWebアプリケーションを開発します。 | [setup_common.sh](setup_common.sh): `setup_dev_web`。 |
| JavaScript / TypeScript | typescript-language-server | エディターにTypeScriptの補完や診断を提供します。 | [setup_common.sh](setup_common.sh): `setup_dev_web`。 |
| JavaScript / TypeScript | Prettier | JavaScriptなどのコードや設定ファイルを整形します。 | [setup_common.sh](setup_common.sh): `setup_dev_web`。 |
| JavaScript / TypeScript | prettier-plugin-organize-imports | Prettierでimport文を整理します。 | [setup_common.sh](setup_common.sh): `setup_dev_web`。 |
| JavaScript / TypeScript | @tailwindcss/language-server | Tailwind CSSの補完や診断をエディターに提供します。 | [setup_common.sh](setup_common.sh): `setup_dev_web`。 |
| JavaScript / TypeScript | Yarn | JavaScript用パッケージを管理します。 | [setup_common.sh](setup_common.sh): `setup_dev_web`。 |
| シェル | bash-language-server | Bashスクリプトの補完や診断をエディターに提供します。 | [setup_common.sh](setup_common.sh) と [setup_macos.sh](setup_macos.sh): `setup_dev_shell`。 |
| エディター | Neovim | キーボード操作を中心に使うテキストエディターです。 | Linux: [setup_common.sh](setup_common.sh) `setup_nvim`。macOS: [setup_macos.sh](setup_macos.sh) `setup_nvim`。バージョン設定は [confrc](confrc)。 |
| ターミナル環境 | tmux | 1つの端末内で複数のペインや作業セッションを管理します。 | macOS: [setup_macos.sh](setup_macos.sh)。Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh)。Rocky Linux: [setup_rocky9.sh](setup_rocky9.sh)。各ファイルの `setup_tmux`。 |
| コマンド検索 | fzf | 入力候補やファイル名を曖昧検索します。 | Linux: [setup_common.sh](setup_common.sh) `setup_fzf`。macOS: [setup_macos.sh](setup_macos.sh) `setup_fzf`。バージョン設定は [confrc](confrc)。 |
| シェル | shfmt | シェルスクリプトを整形します。 | Linux: [setup_common.sh](setup_common.sh) `setup_dev_shell`。macOS: [setup_macos.sh](setup_macos.sh) `setup_dev_shell`。バージョン設定は [confrc](confrc)。 |
| Go | Go | Goプログラムの実行・ビルドに使う言語処理系です。 | Linux: [setup_common.sh](setup_common.sh) `setup_dev_go`。macOS: [setup_macos.sh](setup_macos.sh) `setup_dev_go`。バージョン設定は [confrc](confrc)。 |
| Go | gopls | エディターにGoの補完や診断を提供します。 | [setup_common.sh](setup_common.sh) と [setup_macos.sh](setup_macos.sh): `setup_dev_go`。 |
| Go | goimports | Goのimport文を整理し、コードを整形します。 | [setup_common.sh](setup_common.sh) と [setup_macos.sh](setup_macos.sh): `setup_dev_go`。 |
| C / C++ | LLVM | C/C++開発用コンパイラーや関連ツールを提供する基盤です。 | macOS: [setup_macos.sh](setup_macos.sh) `setup_dev_clang`。 |
| C / C++ | clang | C言語のソースコードをコンパイルします。 | Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh) `setup_dev_clang`。Rocky Linux: [setup_rocky9.sh](setup_rocky9.sh) `setup_dev_clang`。macOS: [setup_macos.sh](setup_macos.sh) `setup_dev_clang`。 |
| C / C++ | clangd | エディターにC/C++の補完や診断を提供します。 | Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh) `setup_dev_clang`。Rocky Linux: [setup_rocky9.sh](setup_rocky9.sh) `setup_dev_clang`。macOS: [setup_macos.sh](setup_macos.sh) `setup_dev_clang`。 |
| C / C++ | clang-format | C/C++のコードを整形します。 | Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh) `setup_dev_clang`。Rocky Linux: [setup_rocky9.sh](setup_rocky9.sh) `setup_dev_clang`。macOS: [setup_macos.sh](setup_macos.sh) `setup_dev_clang`。 |
| C / C++ | build-essential | UbuntuでC/C++のコンパイルやビルドに使う基本ツール群です。 | [setup_ubuntu24.sh](setup_ubuntu24.sh): `setup_dev_tools`。 |
| C / C++ | gcc | C言語のコンパイラーです。 | Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh) `setup_dev_tools` の `build-essential`。Rocky Linux: [setup_rocky9.sh](setup_rocky9.sh) `setup_dev_tools`。 |
| C / C++ | gcc-c++ | C++言語のコンパイラーです。 | Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh) `setup_dev_tools` の `build-essential`。Rocky Linux: [setup_rocky9.sh](setup_rocky9.sh) `setup_dev_tools`。 |
| ビルド依存 | ncurses-dev / ncurses-devel | tmuxの端末表示や操作を支えるライブラリーの開発ファイルです。 | Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh) `setup_dev_tools`。Rocky Linux: [setup_rocky9.sh](setup_rocky9.sh) `setup_dev_tools`、`setup_tmux`。 |
| ビルド依存 | libevent-devel | Rocky Linuxでtmuxをビルドする際に使う開発ファイルです。 | [setup_rocky9.sh](setup_rocky9.sh): `setup_dev_tools`、`setup_tmux`。 |
| システム管理 | snapd | Snap形式のアプリを管理するためのサービスです。 | [setup_ubuntu24.sh](setup_ubuntu24.sh): `setup_dev_tools`。 |
| システム管理 | man | コマンドのマニュアルを端末で読むためのツールです。 | [setup_rocky9.sh](setup_rocky9.sh): `setup_dev_tools`。 |
| ビルド依存 | bison | tmuxのビルドで使う構文解析器生成ツールです。 | [setup_rocky9.sh](setup_rocky9.sh): `setup_tmux`。 |
| ビルド依存 | make | Makefileに記述された手順でソフトウェアをビルドします。 | Ubuntu: [setup_ubuntu24.sh](setup_ubuntu24.sh) `setup_dev_tools` の `build-essential`。Rocky Linux: [setup_rocky9.sh](setup_rocky9.sh) `setup_tmux`。 |
| ビルド依存 | pkgconfig | ビルド時にライブラリーの場所やフラグを調べます。 | [setup_rocky9.sh](setup_rocky9.sh): `setup_tmux`。 |
| ビルド依存 | autoconf | ソフトウェアのビルド設定スクリプトを生成します。 | [setup_rocky9.sh](setup_rocky9.sh): `setup_tmux`。 |
| ビルド依存 | automake | ビルド用のMakefileを生成します。 | [setup_rocky9.sh](setup_rocky9.sh): `setup_tmux`。 |
| Rust | rustup | RustコンパイラーやCargoなどの開発環境を管理します。 | [setup_common.sh](setup_common.sh) と [setup_macos.sh](setup_macos.sh): `setup_dev_rust`。有効化設定は [confrc](confrc)。 |
| Rust | cargo-binstall | Rust製ツールのビルド済み配布物を導入します。 | [setup_common.sh](setup_common.sh) と [setup_macos.sh](setup_macos.sh): `setup_dev_rust`。バージョン設定は [confrc](confrc)。 |
| Rust | markdown-oxide | Markdown文書の編集を支援する言語サーバーです。 | [setup_common.sh](setup_common.sh) と [setup_macos.sh](setup_macos.sh): `setup_dev_rust`。有効化設定とバージョン設定は [confrc](confrc)。 |

Rustカテゴリのツールは既定で無効です。[confrc](confrc) で `ENABLE_RUST=true` にするとrustupとcargo-binstallが対象になり、markdown-oxideにはさらに `ENABLE_MARKDOWN_OXIDE=true` が必要です。

`make check` はNeovim、tmux、fzf、npm、Go、shfmtがPATH上にあるかを確認し、不足があれば非0で終了します。LinuxではNeovimとtmuxのバージョン違いを警告します。

## セットアップスクリプトの使い方

```
# セットアップを実施
$ ./setup.sh

# セットアップ後のチェックを実施
$ ./check.sh
```

各種セットアップスクリプトは単体でも利用できます

```
$ ./setup_common.sh help

$ ./setup_common.sh setup_dotfiles
```

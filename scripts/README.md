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

`setup_dotfiles` は通常 `home/.config/` 直下の設定ディレクトリを `~/.config/` にリンクします。Herdr の設定ディレクトリが既にある場合は既存のローカル状態を残し、その中の管理対象ファイルを個別にリンクします。同名の既存ファイルは `.local-backup.<日時>` へ退避してからリンクします。

`setup.sh` は `setup_dotfiles` より前に `setup_herdr` を実行します。Herdr が未導入なら公式インストーラーを実行し、導入済みなら `herdr update` で更新します。

`~/home_ex/scripts/setup.sh` が存在する場合、`setup.sh` の最後に自動実行されます。`home_ex` 側のプライベート設定は `~/home_ex/scripts/setup.sh` を直接実行してセットアップすることもできます。

## セットアップスクリプトの使い方

```
# セットアップを実施
$ ./setup.sh

# セットアップ後のチェックを実施
$ ./check.sh
```

各種セットアップスクリプトは単体でも利用できます

Ubuntuではファイル検索ツールのfdを`fd-find`パッケージでインストールします。実行時のコマンド名は`fdfind`です。

```
$ ./setup_common.sh help

$ ./setup_common.sh setup_dotfiles
```

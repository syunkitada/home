# scripts

| スクリプト        | 説明                                                                            |
| ----------------- | ------------------------------------------------------------------------------- |
| [setup.sh](setup.sh) | OSに合わせて各種セットアップスクリプトを実行します。 |
| [check.sh](check.sh) | セットアップ後のチェックを実行します。 |
| [confrc](confrc) | セットアップの設定値（環境変数）を管理します。 |
| [setup_common.sh](setup_common.sh) | OS非依存のセットアップ関数をまとめています。 |
| [setup_common_ex.sh](setup_common_ex.sh) | 拡張用のセットアップ関数をまとめています。 |
| [setup_rocky9.sh](setup_rocky9.sh) | Rocky Linux 9用のセットアップを実行します。 |
| [setup_ubuntu24.sh](setup_ubuntu24.sh) | Ubuntu 24.04用のセットアップを実行します。 |
| [gen_keybind_doc.go](gen_keybind_doc.go) | キーバインドドキュメントを生成します。 |

`~/home_ex/scripts/setup.sh` が存在する場合、`setup.sh` の最後に自動実行されます。`home_ex` 側のプライベート設定は `~/home_ex/scripts/setup.sh` を直接実行してセットアップすることもできます。

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

# Herdr

Herdr のユーザー設定です。`scripts/setup_common.sh` の `setup_dotfiles` が `config.toml` を `~/.config/herdr/config.toml` にリンクします。既に Herdr の設定ディレクトリがある場合は、セッション情報などの既存状態を保ち、同名の設定ファイルを `.local-backup.<日時>` に退避してからリンクします。

## Index

| パス | 役割 |
| --- | --- |
| [`config.toml`](./config.toml) | tmux の操作に合わせた Herdr のプレフィックスとキーバインド |

`config.toml` は tmux と同じ `ctrl+b` プレフィックスを使い、ペイン分割・移動・サイズ変更、タブ移動、ズーム、コピー、再読込を対応付けています。tmux の `s` は上下分割、`v` は左右分割です。

tmux のペイン入力同期 (`synchronize-panes`) に相当する Herdr の操作はありません。キーバインドの詳細は [Herdr 設定ドキュメント](https://herdr.dev/tui/docs/configuration/#keybindings)を参照してください。

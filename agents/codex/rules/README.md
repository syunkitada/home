# Codex 実行ルール

Codex に許可するコマンド実行ルールを管理します。[`../../setup.sh`](../../setup.sh) の `codex` は `*.rules` を `CODEX_HOME/rules/` へファイル単位でリンクします。

## Index

| パス | 役割 |
| --- | --- |
| [`my.rules`](./my.rules) | 開発用 VM で利用するコマンドの許可ルール |

Codex が TUI から追加する `default.rules` はローカル専用です。このディレクトリに存在してもセットアップ対象にせず、Git 管理からも除外します。

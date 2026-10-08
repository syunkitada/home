# Codex 設定

全プロジェクトで使う Codex のユーザー設定とコマンド実行ルールの正本です。レビュー時の運用前提は [`AGENTS.md`](./AGENTS.md) を参照してください。

[`../setup.sh`](../setup.sh) の `codex` または `all` で、管理対象の各ファイルを `CODEX_HOME`（既定は `~/.codex`）へシンボリックリンクします。認証情報、履歴、ログなども入る `CODEX_HOME` 全体はリンクしません。

## Index

| パス | 役割 |
| --- | --- |
| [`docs/`](./docs/README.md) | Codex の導入手順と設定項目の整理 |
| [`hooks/`](./hooks/README.md) | Codex のライフサイクル hook スクリプト |
| [`rules/`](./rules/README.md) | Codex のコマンド実行ルール |
| [`AGENTS.md`](./AGENTS.md) | この設定をレビューする際の運用前提 |
| [`config.toml`](./config.toml) | Codex のモデル、承認、サンドボックス、プロジェクト設定 |

## ローカルへの配置

```bash
./agents/setup.sh codex
```

同じ正本へのリンクは変更しません。通常ファイル・ディレクトリ・別のリンク・リンク切れが配置先にある場合は上書きせず、選択した全対象の事前確認で停止します。`home_ex` など旧配置へのリンクも自動移行しません。

`AGENTS.md` はこの設定のレビュー用であり、`CODEX_HOME/AGENTS.md` には配置しません。README と docs も配置対象外です。

参照元と配置先は `CODEX_SOURCE_DIR` と `CODEX_HOME` で変更できます。詳しい使い方は [`../README.md`](../README.md) を参照してください。

# エージェント設定

エージェントの設定と共通スキルの正本を管理します。ローカルにはシンボリックリンクで配置し、変更をこのリポジトリで管理します。

## Index

| パス | 役割 |
| --- | --- |
| [`codex/`](./codex/README.md) | Codex の設定、実行ルール、hooks |
| [`_skills/`](./_skills/README.md) | エージェント間で共有する自分用スキル |
| [`_scrapes/`](./_scrapes/README.md) | 外部スキルの参考資料と取得定義 |
| [`antigravity/`](./antigravity/README.md) | Antigravity 向けの資料 |
| [`opencode/`](./opencode/README.md) | OpenCode 向けの資料 |
| [`setup.sh`](./setup.sh) | Codex 設定と共通スキルのリンク配置 |

## セットアップ

リポジトリルートで実行します。スクリプトを絶対パスで指定すれば、別の作業ディレクトリからも実行できます。

```bash
./agents/setup.sh          # Codex とスキルの両方（all と同じ）
./agents/setup.sh codex    # Codex 設定のみ
./agents/setup.sh skills   # 共通スキルのみ
./agents/setup.sh --help
```

Codex は `config.toml`、`rules/*.rules`（`default.rules` を除く）、`hooks/*.sh` を `~/.codex` 内にファイル単位で配置します。スキルは `SKILL.md` を持つ直下ディレクトリを `~/.agents/skills/<skill-name>` に個別リンクします。README、docs、Codex 設定のレビュー用 `AGENTS.md`、外部参考資料は配置しません。

同じ正本へのリンクは変更しません。選択した全対象の参照元・配置先を事前確認し、通常ファイル、ディレクトリ、別のリンク、リンク切れとの競合があれば、リンクを作成せず非ゼロで終了します。`home_ex` など旧配置へのリンクも自動移行しません。必要な配置先ディレクトリは作成します。

参照元と配置先は次の環境変数で変更できます。相対パスは実行時の作業ディレクトリを基準に解釈します。

| 変数 | 既定値 |
| --- | --- |
| `CODEX_SOURCE_DIR` | スクリプトと同じディレクトリ内の `codex/` |
| `CODEX_HOME` | `$HOME/.codex` |
| `AGENT_SKILLS_SOURCE_DIR` | スクリプトと同じディレクトリ内の `_skills/` |
| `AGENT_SKILLS_HOME` | `$HOME/.agents/skills` |

CLI のインストールやログインは行いません。Codex の導入は [`codex/docs/`](./codex/docs/README.md) を参照してください。OS セットアップの `scripts/setup.sh` とは独立して実行します。

# 自分用スキル

自分の作業に合わせて作成・カスタマイズしたスキルの正本を管理します。使い方は各スキルの README を参照してください。保守契約や参考資料を分離している skill では、README からリンクされた SPEC.md を参照してください。

## Index

| パス | 役割 |
| --- | --- |
| [`AGENTS.md`](./AGENTS.md) | 配下の skill に共通する文書構成、参考資料、構成変更の管理ルール |
| [`task-planning/`](./task-planning/README.md) | 要件を作業計画、受け入れ条件、検証方法へ整理する skill |
| [`implementation/`](./implementation/README.md) | 仕様に基づいてコード、設定、ドキュメントを変更する skill |
| [`tdd/`](./tdd/README.md) | 挙動変更やバグ修正をテスト駆動で進める skill |
| [`verification/`](./verification/README.md) | 完了前に要件、検証結果、差分を確認する skill |
| [`code-review/`](./code-review/README.md) | 変更差分をレビューし、仕様と根拠に基づいて不具合や回帰を報告するスキル |
| [`git-workflow/`](./git-workflow/README.md) | ブランチ、コミット、PR、競合解消などの Git 操作を安全に進める skill |
| [`security-review/`](./security-review/README.md) | 入力、認証・認可、秘密情報、外部サービスなどを専門的に確認する skill |
| [`japanese-writing-polish/`](./japanese-writing-polish/README.md) | AIが生成した不自然な日本語を自然で読みやすい文章へ推敲する skill |

## 配置方針

各スキルをこのディレクトリの `<skill-name>/` から `~/.agents/skills/<skill-name>` へ個別にシンボリックリンクします。リポジトリルートで次を実行します。

```bash
./agents/setup.sh skills
```

同じ正本へのリンクがあれば変更せず、同名の通常ファイル・ディレクトリ・別のリンク・リンク切れがあれば、選択した全対象の事前確認で上書きせずに停止します。参照元は `AGENT_SKILLS_SOURCE_DIR`、配置先は `AGENT_SKILLS_HOME` で変更できます。

各直下ディレクトリには `SKILL.md` が必要です。参考として取得した外部スキルは [`../_scrapes/`](../_scrapes/README.md) に分離し、ここへ自動配置しません。

## 開発ライフサイクル

通常は、`task-planning` で要件と計画を整理し、`implementation` で変更します。`implementation` はコード、設定、ドキュメントに加え、構成変更に伴う README、目次やファイル一覧などの構成説明、相対リンクの同期も扱います。挙動変更では `tdd`、完了前には `verification`、実装後には `code-review` を使います。コミット、PR、競合解消などの Git 操作は `git-workflow` に分けます。

外部資料を根拠にした API 調査や知識整理が増えた場合は、`research` または `source-research` を追加候補とします。実装の責務と重複する `planning-and-task-breakdown`、`incremental-implementation`、`verification-before-completion` は既存 skill に統合します。一般的なデバッグ手順は独立 skill とせず、エージェントの判断で進めます。

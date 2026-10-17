# getsentry/skills 調査ノート

> これは、外部リポジトリ `getsentry/skills` のスナップショットを調査した中間資料です。調査日現在のローカル取得物を根拠としており、上流の最新状態や、ここに記載していない実行環境の挙動を保証するものではありません。

## Index

| パス | 役割 |
| --- | --- |
| [`README.md`](./README.md) | `getsentry_skills` の構成、機能、導入・検証方法をまとめた本ノート |

## 対象・調査時点

- 対象: [`_repos/getsentry_skills`](../../_repos/getsentry_skills/)
- 調査日: 2026-09-23
- HEAD: `c2f99a5b04b4cd992ec3022d7c2c3e23e938d241`
- HEAD の日時・件名: 2026-08-25 07:33:48 -07:00、`fix(iterate-pr): Remove default Claude attribution (#169)`
- 直近コミット（HEAD から過去）:
  - `aaa8515` — `fix(iterate-pr): Remove default Claude attribution`
  - `6abccd6` — `chore(skills): Remove replay-ux-research (#167)`
  - `10e64d1` — `fix(skills): Remove reference`
  - `6e790d8` — `chore(skills): Remove replay-ux-research`
- 取得元として確認できた情報: Git の `origin` は `https://github.com/getsentry/skills.git`。ローカル checkout は detached HEAD だが、同じコミットをローカル `main` ref が指している。
- 取得日時、クローン方法、上流での公開状態は、このスナップショットの Git メタデータだけからは確認できない。

## 目的と全体像

`getsentry/skills` は、Sentry 社内の開発・文書作成・レビュー・セキュリティ確認などを支援するエージェント技能集である。README は [Agent Skills のオープン形式](https://agentskills.io) に従うと説明しており、正規の技能ソースをルートの `skills/` に置く。

このリポジトリは単なるプロンプト置き場ではなく、次の三つを兼ねる構成になっている。

1. Claude Code の marketplace/plugin のルート。`.claude-plugin/marketplace.json` がルート自身を `sentry-skills` plugin として登録する。
2. `npx skills add getsentry/skills` で配布する skills.sh 対応パッケージ。
3. GitHub、Sentry MCP、Notion/Linear MCP、`gh` CLI、`uv` などの外部サービスを使う実務ワークフローと、技能の静的検証・評価資材を含むリポジトリ。

README によると、公開対象は canonical な `skills/` 以下の技能であり、`.agents/skills` は同じツリーを指すローカル向けシンボリックリンクである。従って `.agents/skills` を別実装として扱わない。

## 主要機能

### スキル一覧（27件）

下表の説明は主に各 `SKILL.md` の frontmatter とリポジトリ README を要約したもの。参照ファイルを持つ技能は、実行時に必要な資料を `references/` へ分離する設計になっている。

| 分野 | スキル | 概要 |
| --- | --- | --- |
| エージェント運用 | [`agents-md`](../../_repos/getsentry_skills/skills/agents-md/SKILL.md) | `AGENTS.md` / `CLAUDE.md` を調査・作成・保守する。重複を避け、参照元に基づく短い指示を作る。 |
| 文書・ブランド | [`blog-writing-guide`](../../_repos/getsentry_skills/skills/blog-writing-guide/SKILL.md) | Sentry 技術ブログ向けの声、構成、技術的品質、SEO、レビュー基準。 |
| 文書・ブランド | [`brand-guidelines`](../../_repos/getsentry_skills/skills/brand-guidelines/SKILL.md) | UI、エラーメッセージ、ドキュメント、マーケティング文などの Sentry ブランド文体。Plain Speech と Sentry Voice を使い分ける。 |
| 開発環境 | [`claude-settings-audit`](../../_repos/getsentry_skills/skills/claude-settings-audit/SKILL.md) | リポジトリの技術スタックを検出し、Claude Code の読み取り系 `settings.json` 権限を提案する。 |
| レビュー | [`code-review`](../../_repos/getsentry_skills/skills/code-review/SKILL.md) | Sentry の実務基準で、実行時エラー、性能、副作用、テスト、設計、セキュリティをコードレビューする。 |
| レビュー | [`code-simplifier`](../../_repos/getsentry_skills/skills/code-simplifier/SKILL.md) | 挙動を変えず、最近変更されたコードを明快・保守しやすく整理する。Anthropic 由来部分の attribution がある。 |
| Git | [`commit`](../../_repos/getsentry_skills/skills/commit/SKILL.md) | Sentry 形式の conventional commit と issue reference を作る。コミット前にブランチ状態も確認する。 |
| Git | [`create-branch`](../../_repos/getsentry_skills/skills/create-branch/SKILL.md) | Sentry の命名規則に従って作業ブランチを作る。 |
| Django | [`django-access-review`](../../_repos/getsentry_skills/skills/django-access-review/SKILL.md) | Django/DRF の認可、IDOR、所有権、tenant isolation をデータフロー調査付きでレビューする。ORM・view・permission の参考資料を持つ。 |
| Django | [`django-perf-review`](../../_repos/getsentry_skills/skills/django-perf-review/SKILL.md) | Django ORM の N+1、クエリ、インデックス、キャッシュ、ページネーション等の性能レビュー。 |
| 文書作成 | [`doc-coauthoring`](../../_repos/getsentry_skills/skills/doc-coauthoring/SKILL.md) | ドキュメント、提案、技術仕様、意思決定文書を、文脈収集・反復・読者検証の手順で共同作成する。 |
| Sentry API | [`document-api-endpoint`](../../_repos/getsentry_skills/skills/document-api-endpoint/SKILL.md) | `drf-spectacular` の `@extend_schema`、TypedDict、パラメータ型、実装との型ずれを整え、API endpoint を PUBLIC 化する場合の手順も扱う。 |
| レビュー | [`find-bugs`](../../_repos/getsentry_skills/skills/find-bugs/SKILL.md) | 現在ブランチの変更からバグ、脆弱性、品質問題を探す。 |
| GitHub | [`gh-review-requests`](../../_repos/getsentry_skills/skills/gh-review-requests/SKILL.md) | チームへのレビュー依頼、またはチームメンバーが開いた未読・未マージ PR を取得する。補助 Python スクリプト付き。 |
| GitHub Actions | [`gha-security-review`](../../_repos/getsentry_skills/skills/gha-security-review/SKILL.md) | `pull_request_target`、expression injection、資格情報、サプライチェーン、runner 等の CI 攻撃経路を、PoC 可能性とともにレビューする。 |
| GitHub | [`iterate-pr`](../../_repos/getsentry_skills/skills/iterate-pr/SKILL.md) | actionable な CI failure と high/medium レビュー指摘を直して PR を反復する。承認・draft・merge gate は待ち続けず停止する。 |
| GitHub | [`pr-link-issue`](../../_repos/getsentry_skills/skills/pr-link-issue/SKILL.md) | 現在の PR 説明に GitHub issue と対応する Linear ticket のリンクを追加する。 |
| GitHub | [`pr-writer`](../../_repos/getsentry_skills/skills/pr-writer/SKILL.md) | Sentry の慣行に沿って、レビュアー向け PR title/body を作成・更新する。 |
| プレゼンテーション | [`presentation-creator`](../../_repos/getsentry_skills/skills/presentation-creator/SKILL.md) | React/Vite/Recharts と Sentry デザインでデータ駆動スライドを作り、単一 HTML にする。実データがない場合はグラフを捏造しない。 |
| プロンプト | [`prompt-optimizer`](../../_repos/getsentry_skills/skills/prompt-optimizer/SKILL.md) | system/developer/agent prompt を評価セットと外部文脈の因果性を保ちながら改善し、OpenAI・Claude・Gemini 間の適応も扱う。 |
| セキュリティ | [`security-review`](../../_repos/getsentry_skills/skills/security-review/SKILL.md) | 入力の出所と防御を調査してから、injection、XSS、認証・認可、SSRF、暗号、データ保護等を確信度付きで報告する。 |
| セキュリティ | [`skill-scanner`](../../_repos/getsentry_skills/skills/skill-scanner/SKILL.md) | 技能自体の prompt injection、危険スクリプト、過剰権限、秘密情報、サプライチェーンを静的検査する。 |
| 技能開発 | [`skill-writer`](../../_repos/getsentry_skills/skills/skill-writer/SKILL.md) | Agent Skills 仕様に沿って技能を調査・作成・改善し、`SKILL.md`、`SPEC.md`、references、登録、検証を進める。 |
| SRED | [`sred-project-organizer`](../../_repos/getsentry_skills/skills/sred-project-organizer/SKILL.md) | GitHub/Notion/Linear の Work Summary を SRED プロジェクト記述へ整理する。 |
| SRED | [`sred-work-summary`](../../_repos/getsentry_skills/skills/sred-work-summary/SKILL.md) | 過去年度の GitHub PR、Notion 文書、Linear ticket を収集してプロジェクト別の Notion Work Summary にまとめる。 |
| Sentry 運用 | [`triage-frontend-issues`](../../_repos/getsentry_skills/skills/triage-frontend-issues/SKILL.md) | `sentry/javascript` の非アクショナブルな issue だけを分類し、明示承認後に `untilEscalating` で archive する。解決・削除・担当変更はしない。 |
| Python | [`typing-exclusion-worker`](../../_repos/getsentry_skills/skills/typing-exclusion-worker/SKILL.md) | 指定された mypy 除外モジュールを小さなバッチで外し、型エラー修正・mypy・pytest・pre-commit と定型報告を行う。 |

### サブエージェント

- [`agents/code-simplifier.md`](../../_repos/getsentry_skills/agents/code-simplifier.md): `opus` を指定し、機能を保ったコード簡素化を行う。最近変更されたコードを主対象とする。Anthropic 公式 plugin の同名 agent を基にした attribution がある。
- [`agents/senpai.md`](../../_repos/getsentry_skills/agents/senpai.md): `opus` と `green` 表示色を指定した Sentry 新入社員向け技術メンター。回答前に Sentry 開発者ドキュメント、GitHub、関連リポジトリを調査し、段階的説明と参照を返す。`Read`、`Grep`、`Glob`、`Bash`、`WebFetch`、`WebSearch` を許可する。

### 補助スクリプトとコマンド

実行用スクリプトはすべて Python で、PEP 723 の依存宣言を持つものは `uv run` で実行する方針である。GitHub 系は `gh` の認証・ネットワーク・対象リポジトリが必要。

| 場所 | 内容 |
| --- | --- |
| [`gh-review-requests/scripts/fetch_review_requests.py`](../../_repos/getsentry_skills/skills/gh-review-requests/scripts/fetch_review_requests.py) | `--org`（既定 `getsentry`）と必須 `--teams` を受け、チームメンバー・チーム宛レビュー依頼・未読通知を突き合わせ、未クローズ PR を JSON で返す。 |
| [`iterate-pr/scripts/fetch_pr_checks.py`](../../_repos/getsentry_skills/skills/iterate-pr/scripts/fetch_pr_checks.py) | PR の checks と失敗 workflow のログ断片を取得し、actionable pending と人手承認 gate を分離する。 |
| [`iterate-pr/scripts/fetch_pr_feedback.py`](../../_repos/getsentry_skills/skills/iterate-pr/scripts/fetch_pr_feedback.py) | inline/conversation comment と review thread を取得し、LOGAF の high/medium/low、情報 bot、resolved に分類する。Sentry/Warden/Cursor 等の review bot は actionable 対象として扱う。 |
| [`iterate-pr/scripts/monitor_pr_checks.py`](../../_repos/getsentry_skills/skills/iterate-pr/scripts/monitor_pr_checks.py) | checks をポーリングし、`ALL_CHECKS_PASSED`、`CHECKS_DONE_WITH_FAILURES`、`NO_CHECKS_REGISTERED`、`DRAFT_PR_WITH_NO_CHECKS`、`CHECKS_BLOCKED_BY_REVIEW_GATE` の marker を出す。 |
| [`iterate-pr/scripts/reply_to_thread.py`](../../_repos/getsentry_skills/skills/iterate-pr/scripts/reply_to_thread.py) | GitHub GraphQL mutation で review thread への返信を複数件まとめて投稿する。 |
| [`skill-scanner/scripts/scan_skill.py`](../../_repos/getsentry_skills/skills/skill-scanner/scripts/scan_skill.py) | frontmatter、URL、prompt injection、難読化、秘密情報、危険コード、構造的攻撃を検出し、所見と severity を JSON で出力する。機械的検出なので意図と false positive は人が確認する。 |
| [`skill-writer/scripts/quick_validate.py`](../../_repos/getsentry_skills/skills/skill-writer/scripts/quick_validate.py) | `SKILL.md` の存在、YAML frontmatter、`name` とディレクトリ名、`description`、ローカル参照の存在を検証する。20,000文字超は警告であり、失敗ではない。 |

## ディレクトリ・主要ファイル

以下は Git 管理対象の構成を、利用上重要な単位でまとめたもの。`skills/` 以下には上表の各技能と、その `SKILL.md`、必要に応じた `SPEC.md`、`SOURCES.md`、`references/`、`scripts/`、`evals/` がある。

| パス | 役割 |
| --- | --- |
| [`.claude-plugin/marketplace.json`](../../_repos/getsentry_skills/.claude-plugin/marketplace.json) | marketplace 名、所有者、plugin 一覧を定義。現スナップショットでは `./` を source とする `sentry-skills` 一件を登録。 |
| [`.claude-plugin/plugin.json`](../../_repos/getsentry_skills/.claude-plugin/plugin.json) | ルート plugin の名前・説明・作者（Sentry）。 |
| [`.claude/settings.json`](../../_repos/getsentry_skills/.claude/settings.json) | Claude の許可コマンド、WebFetch ドメイン、27スキルの allowlist、MCP 有効化、`plugin-dev` の有効化を設定。 |
| [`.agents/skills`](../../_repos/getsentry_skills/.agents/skills) | `../skills` を指す symlink。canonical source のミラーであり、別の技能実装ではない。 |
| [`agents/`](../../_repos/getsentry_skills/agents/) | ルートで配布するサブエージェント定義。現在 `code-simplifier` と `senpai`。 |
| [`skills/`](../../_repos/getsentry_skills/skills/) | canonical な 27 スキルのルート。 |
| [`AGENTS.md`](../../_repos/getsentry_skills/AGENTS.md) | 技能の構造、登録手順、frontmatter、サイズ、`uv run` 等の開発規約。 |
| [`CLAUDE.md`](../../_repos/getsentry_skills/CLAUDE.md) | `AGENTS.md` を指す symlink。Claude 側の入口。 |
| [`README.md`](../../_repos/getsentry_skills/README.md) | 導入、利用可能スキル/エージェント、リポジトリ構造、技能作成、marketplace、ライセンスの案内。 |
| [`CONTRIBUTING.md`](../../_repos/getsentry_skills/CONTRIBUTING.md) | ローカル plugin の導入、再起動、技能の明示/自動起動確認、追加・登録手順。 |
| [`warden.toml`](../../_repos/getsentry_skills/warden.toml) | `**/skills/**` に対して `skill-scanner` を PR の opened/synchronize と local trigger で起動。high で失敗、medium を報告。 |
| [`LICENSE`](../../_repos/getsentry_skills/LICENSE) | ルートのライセンスファイル。README は Apache-2.0 と記載。個別にも `django-perf-review` と `security-review` に LICENSE がある。 |
| [`.gitignore`](../../_repos/getsentry_skills/.gitignore) | Claude の local settings、AXIS report、OS/editor のローカルファイルを除外。 |

### 参考資料・評価資材の構成

- セキュリティ系: `django-access-review/references/` に Django 認可、`gha-security-review/references/` に Actions の攻撃類型、`security-review/references/` に脆弱性・言語・インフラ別の資料を配置。
- 技能開発系: `skill-writer/references/` は source discovery、実行形、router、hook、subagent fork、評価、登録・検証等に分割。`skill-writer/evals/` と `pr-writer/evals/` に AXIS 設定とシナリオがある。
- 出力系: `presentation-creator/references/` にチャート設計・Sentry SVG、`prompt-optimizer/references/` にモデルファミリー・最適化ループ・変換例がある。
- 契約ファイル: `agents-md`、`iterate-pr`、`pr-writer`、`prompt-optimizer`、`skill-writer`、`triage-frontend-issues` には `SPEC.md` があり、意図・範囲・検証・制約を `SKILL.md` から分離している。`agents-md`、`prompt-optimizer`、`skill-writer` には `SOURCES.md` もある。

## 利用・導入・実行ワークフロー

### Claude Code plugin として

README の手順は次の通り。

```bash
claude plugin marketplace add getsentry/skills
claude plugin install sentry-skills@sentry-skills
```

インストール後に Claude Code を再起動し、関連する依頼を記述すると技能が自動起動する。更新は `claude plugin marketplace update` と `claude plugin update sentry-skills@sentry-skills`、または `/plugin` から行う。ローカル開発時は `claude plugin marketplace add ~/sentry-skills` → `claude plugin install sentry-skills` とする。

Sparse checkout を使う場合、ルート manifest が `skills/` と `agents/` を読むため、`.claude-plugin` だけでなく両ディレクトリも取得する必要がある。

### skills.sh 対応エージェントとして

README は次の導入を案内し、Claude Code、Cursor、Cline、GitHub Copilot など互換エージェントで動くと説明している。

```bash
npx skills add getsentry/skills
```

ただし、各ハーネスでの実際のインストール結果や、個別スキルの全機能互換性はこの調査では実行確認していない。

### 実務ワークフローの例

- PR 反復: 現在ブランチの PR を `gh pr view` で特定 → review feedback を high/medium/low 等に分類 → checks と失敗ログを確認 → ローカル検証 → commit/push → checks と新規 feedback を再確認する。人間の承認、draft、merge gate は修正可能な CI と区別して停止する。
- フロントエンド issue triage: Sentry MCP で `sentry/javascript` の unresolved queue を取得 → `references/archive-criteria.md` で `archive`/`skip`/`needs-human` を分類 → 完全な計画をユーザーに提示 → `apply` の明示承認があった項目だけ `update_issue` する。archive は必ず `status=ignored`、`ignoreMode=untilEscalating`、理由付き。
- 技能の作成・更新: `skill-writer` の mode/source discovery/synthesis/authoring/registration-validation の経路を選び、`SKILL.md` を runtime router、`SPEC.md` を保守契約、references を必要時に開く知識として分ける。
- SRED: `sred-work-summary` で GitHub/Notion/Linear の前年実績を集約し、`sred-project-organizer` で SRED 判定、技術的不確実性、実験、成果を Notion 文書へ展開する。Notion と Linear の MCP、GitHub MCP または `gh` が前提。
- プレゼンテーション: 実データの有無を先に判定し、データがあるスライドだけ Recharts を使う。React/Vite のアプリを作り、Sentry の SVG とデザイン規約を使って単一 HTML に build する。

## 設定・配布・連携・対応ハーネス

- Claude Code: marketplace の plugin manifest、`.claude/settings.json` の `Skill(sentry-skills:<name>)` allowlist、WebFetch 許可ドメインを使用する。`settings.json` には `hooks` エントリはなく、リポジトリ側で確認できる自動フック定義はない。
- Codex: `iterate-pr/agents/openai.yaml` だけに Codex 用表示名・既定 prompt と `policy.allow_implicit_invocation: true` がある。リポジトリ全体に Codex 用設定があるとは確認できない。
- Warden: [`warden.toml`](../../_repos/getsentry_skills/warden.toml) が `skill-scanner` を技能配下に適用する。high を fail、medium を report とする。
- GitHub: `gh` CLI を直接呼ぶ Python スクリプトがあり、PR、checks、comments、review threads、workflow logs を扱う。
- Sentry: `triage-frontend-issues` は `mcp.sentry.dev` の `search_issues`、`get_sentry_resource`、`update_issue` を必須とする。
- Notion/Linear: SRED 系スキルが MCP 接続を前提とする。これらの MCP サーバー定義自体はリポジトリにはない。
- 外部ハーネス: README が skills.sh と Claude Code、Cursor、Cline、GitHub Copilot 等を挙げる。ただし marketplace/plugin の詳細実装と、skills.sh 側の変換仕様はこのスナップショットには含まれない。
- Claude 固有機能: frontmatter の `disable-model-invocation`、技能 allowlist、plugin marketplace、サブエージェント定義を使う。実際に hook-backed 技能をこのリポジトリで使っているわけではなく、`skill-writer` の reference に設計資料がある。

## テスト・検証方法

### リポジトリが案内する確認

[`CONTRIBUTING.md`](../../_repos/getsentry_skills/CONTRIBUTING.md) は、ローカル clone を marketplace に登録・install → Claude Code を再起動 → `/skill-name` または自然言語で起動 → 期待する guidance と edge case を確認、という手動検証を案内する。アプリケーションの unit test suite や CI workflow は Git 管理対象として確認できなかった。

### 静的・構造検証

- `uv run skills/skill-writer/scripts/quick_validate.py skills/<name>`: frontmatter とローカル参照の整合性を確認する。
- `uv run skills/skill-scanner/scripts/scan_skill.py skills/<name>`: prompt injection、難読化、secret、危険コード、権限、URL、構造攻撃の候補を JSON 化する。セキュリティ技能が攻撃パターンを説明するだけの false positive は、スクリプトの結果を人が意図確認する必要がある。
- `uv run -m py_compile skills/iterate-pr/scripts/*.py`: `iterate-pr/SPEC.md` が案内するスクリプト構文確認。
- `warden.toml`: PR の opened/synchronize と local trigger で技能の `skill-scanner` を実行し、high で fail、medium で report する。
- `skills/pr-writer/evals/` と `skills/skill-writer/evals/`: AXIS の評価設定とシナリオを持つ。前者は docs-only PR writer、後者は技能の改善・参照分割・小規模 inline workflow を評価する。

### 品質上の特徴

- `AGENTS.md` は frontmatter を先頭行に置く、`name` とディレクトリ名を一致させる、trigger keyword を description に含める、`SKILL.md` を 500 行未満にする、Python は `uv run` で実行する、といった authoring 規約を定める。
- 複雑な技能では runtime 指示、保守契約、参考資料、評価シナリオを分離し、`iterate-pr` や `triage-frontend-issues` では非アクショナブル状態や承認境界を明示する。
- security review 系は単純なパターン一致で脆弱性と断定せず、入力の出所・攻撃経路・フレームワーク防御・確信度を確認する方針である。
- presentation 系は実データのないグラフを禁止し、ブランド SVG を再利用する。これは生成物の正確性とデザイン一貫性のための明示的な制約である。

## 制約・残課題・未確認事項

- このノートは 2026-09-23 時点のローカル snapshot に基づく。上流の現在の変更、依存サービスの API 仕様、CLI のログイン状態は確認していない。
- GitHub 系の実行には `gh` の認証と対象リポジトリの権限が必要。Sentry triage には Sentry MCP、SRED には Notion/Linear MCP が必要で、いずれもこのリポジトリ内では提供されない。
- `gh` 出力の JSON schema、GitHub review thread GraphQL、Sentry MCP の resource 表現に依存するため、外部 API 変更でスクリプト・技能が壊れ得る。`iterate-pr/SPEC.md` もこの点を制約として記載する。
- `skill-scanner` と `quick_validate` は静的・構造的検査であり、技能の実行品質や悪意の有無を自動的に確定しない。scan findings は文脈を読んで評価する必要がある。
- Sentry triage は `get_sentry_resource` が activity feed や完全な stack trace を十分に返さない場合があり、分類は `needs-human` に寄せる設計。分類基準は `sentry/javascript` 一プロジェクト由来で、他プロジェクトへそのまま適用できない。
- ルートに通常のアプリケーション manifest、依存 lockfile、test directory、`.github/workflows/` は確認できない。したがって `npm test` 等のリポジトリ全体の標準テストコマンドは特定できない。
- README は `plugins/<plugin-name>/` を将来の domain-specific plugin の追加先として説明するが、今回確認した HEAD には `plugins/` ディレクトリは存在しない。
- `agents-md` 等の説明・参照資料には外部ドキュメント URL が含まれる。URL の現行内容やリンク切れは本調査では検証していない。

## 代表的な参照ファイル

- 導入・機能一覧・設計: [`README.md`](../../_repos/getsentry_skills/README.md)
- 開発規約: [`AGENTS.md`](../../_repos/getsentry_skills/AGENTS.md)、[`CONTRIBUTING.md`](../../_repos/getsentry_skills/CONTRIBUTING.md)
- plugin 配布: [`marketplace.json`](../../_repos/getsentry_skills/.claude-plugin/marketplace.json)、[`plugin.json`](../../_repos/getsentry_skills/.claude-plugin/plugin.json)
- 実行権限と skill 登録: [`settings.json`](../../_repos/getsentry_skills/.claude/settings.json)
- PR 反復の runtime/契約: [`iterate-pr/SKILL.md`](../../_repos/getsentry_skills/skills/iterate-pr/SKILL.md)、[`iterate-pr/SPEC.md`](../../_repos/getsentry_skills/skills/iterate-pr/SPEC.md)
- 技能作成と構造検証: [`skill-writer/SKILL.md`](../../_repos/getsentry_skills/skills/skill-writer/SKILL.md)、[`quick_validate.py`](../../_repos/getsentry_skills/skills/skill-writer/scripts/quick_validate.py)
- 技能セキュリティ: [`skill-scanner/SKILL.md`](../../_repos/getsentry_skills/skills/skill-scanner/SKILL.md)、[`scan_skill.py`](../../_repos/getsentry_skills/skills/skill-scanner/scripts/scan_skill.py)
- Sentry issue 操作の境界: [`triage-frontend-issues/SKILL.md`](../../_repos/getsentry_skills/skills/triage-frontend-issues/SKILL.md)、[`triage-frontend-issues/SPEC.md`](../../_repos/getsentry_skills/skills/triage-frontend-issues/SPEC.md)
- Sentry API の型・公開化: [`document-api-endpoint/SKILL.md`](../../_repos/getsentry_skills/skills/document-api-endpoint/SKILL.md)
- サブエージェント: [`agents/senpai.md`](../../_repos/getsentry_skills/agents/senpai.md)、[`agents/code-simplifier.md`](../../_repos/getsentry_skills/agents/code-simplifier.md)

## `session-retrospective` での参照

| 項目 | 内容 |
| --- | --- |
| 調査日 | 2026-10-18 |
| 対象コミット | `c2f99a5b04b4cd992ec3022d7c2c3e23e938d241` |
| 参照したファイル | [`skills/skill-writer/SKILL.md`](../../_repos/getsentry_skills/skills/skill-writer/SKILL.md)、[`references/design-principles.md`](../../_repos/getsentry_skills/skills/skill-writer/references/design-principles.md)、[`references/skill-evals.md`](../../_repos/getsentry_skills/skills/skill-writer/references/skill-evals.md) |
| 採用した内容 | 更新時の出典記録、短い runtime router、progressive disclosure、少数の観測可能な手動評価ケース。外部 runner や runtime 依存は追加しなかった。 |
| 未確認事項 | この skill の手動評価ケースを実際のモデル実行で採点した結果と、外部ハーネスでの発動結果は確認していない。 |

## 調査範囲と作成物

- 確認範囲: `AGENTS.md`、`CLAUDE.md`、README、CONTRIBUTING、LICENSE、plugin/marketplace manifest、Claude settings、`warden.toml`、Git 履歴・remote、全 Git 管理対象のファイル一覧、27 `SKILL.md`、サブエージェント定義、補助 Python スクリプト、技能の SPEC/SOURCES/EVAL と主要 references の構成。
- 作成/変更ファイル: [`README.md`](./README.md) のみ。
- 他レポジトリのノート、親側 README、AGENTS.md、調査対象の外部リポジトリ本体は変更していない。

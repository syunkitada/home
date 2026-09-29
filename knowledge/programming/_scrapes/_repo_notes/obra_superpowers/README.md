# obra/superpowers 調査ノート

> この文書は、外部リポジトリ `obra/superpowers` のローカルスナップショットに基づく中間調査資料です。調査時点は 2026-09-23。最新の仕様・配布状態を保証するものではないため、必要に応じて記載コミットとソースファイルを再確認してください。

## 対象と調査時点

| 項目 | 内容 |
| --- | --- |
| ソース | [`_repos/obra_superpowers/`](../../_repos/obra_superpowers/) |
| 取得元（確認できた範囲） | `https://github.com/obra/superpowers.git`（ローカル Git の `origin`） |
| 対象 HEAD | `5bf4e78011075bcfc0dc295f0724994cd123ee71` (`5bf4e78`) |
| HEAD の日時・件名 | 2026-09-18 17:31:35 -07:00、`Release v6.4.1: diagnosing-superpowers, Native plan execution, OpenCode 2.0 and Muse support (#2338)` |
| ブランチ状態 | detached HEAD。調査時点の作業ツリーに変更なし |
| バージョン | 各マニフェストおよび [`package.json`](../../_repos/obra_superpowers/package.json) で `6.4.1` |

「直近コミット」は上記 HEAD であり、リリースコミットの本文には `v6.4.1` が初回出荷で、`v6.4.0` は未出荷と記載されています（[`RELEASE-NOTES.md`](../../_repos/obra_superpowers/RELEASE-NOTES.md)）。

## 目的と全体像

Superpowers は、コーディングエージェントにソフトウェア開発の方法論を与える、Markdown ベースのスキルライブラリとハーネス別のランタイム統合です（[`README.md`](../../_repos/obra_superpowers/README.md)、[`package.json`](../../_repos/obra_superpowers/package.json)）。主な設計は次の三層です。

1. `skills/*/SKILL.md` に、設計、計画、TDD、デバッグ、レビュー、worktree、完了処理などの行動規約を置く。
2. `using-superpowers` をセッション開始時に注入し、エージェントが必要なスキルを自動的に確認・呼び出すようにする。
3. 各ハーネスのプラグインマニフェスト、フック、JavaScript/TypeScript/Python 拡張で、スキルの発見とブートストラップ注入を実装する。

プロダクトアプリケーションの実装コードではなく、複数のエージェント実行環境に配布する開発ワークフロー・プラグインである。`package.json` に通常の依存関係はなく、配布物の中心は Markdown、シェルスクリプト、各ハーネス用の薄いアダプターである。

## 主要なスキル・エージェントワークフロー

`skills/` には以下の 15 スキルがある。各スキルは YAML front matter の `name`/`description` と本文を持ち、必要な補助プロンプトやリファレンスを同じディレクトリに置く構成である。

| 分類 | スキル | 役割 |
| --- | --- | --- |
| 導入・メタ | [`using-superpowers`](../../_repos/obra_superpowers/skills/using-superpowers/SKILL.md) | スキルを確認して適切なものを呼び出すためのブートストラップ |
| 導入・メタ | [`brainstorming`](../../_repos/obra_superpowers/skills/brainstorming/SKILL.md) | 要求の意図を確認し、設計を段階的に合意する。必要に応じてビジュアル補助も使う |
| 導入・メタ | [`writing-skills`](../../_repos/obra_superpowers/skills/writing-skills/SKILL.md) | 新しいスキルの設計、構成、TDD 的な検証方法 |
| 計画・実行 | [`writing-plans`](../../_repos/obra_superpowers/skills/writing-plans/SKILL.md) | ファイルパスと検証手順を含む細粒度の実装計画を作る |
| 計画・実行 | [`executing-plans`](../../_repos/obra_superpowers/skills/executing-plans/SKILL.md) | 現セッション自身が計画を実行し、最後に一度レビューする Native/inline 実行 |
| 計画・実行 | [`subagent-driven-development`](../../_repos/obra_superpowers/skills/subagent-driven-development/SKILL.md) | タスクごとに実装サブエージェントとレビューを回す実行方式 |
| 並列化・隔離 | [`dispatching-parallel-agents`](../../_repos/obra_superpowers/skills/dispatching-parallel-agents/SKILL.md) | 独立した調査・作業を専門サブエージェントへ並列委譲 |
| 並列化・隔離 | [`using-git-worktrees`](../../_repos/obra_superpowers/skills/using-git-worktrees/SKILL.md) | ネイティブ機能を優先し、必要なら Git worktree で作業領域を分離 |
| 品質 | [`test-driven-development`](../../_repos/obra_superpowers/skills/test-driven-development/SKILL.md) | RED-GREEN-REFACTOR と失敗を見届けるテスト先行 |
| 品質 | [`systematic-debugging`](../../_repos/obra_superpowers/skills/systematic-debugging/SKILL.md) | 根本原因調査、パターン分析、仮説検証、修正の4段階デバッグ |
| 品質 | [`verification-before-completion`](../../_repos/obra_superpowers/skills/verification-before-completion/SKILL.md) | 完了・成功を宣言する前に実際の検証結果を確認 |
| レビュー | [`requesting-code-review`](../../_repos/obra_superpowers/skills/requesting-code-review/SKILL.md) | 独立したレビュー用サブエージェントを作り、計画と差分をレビュー |
| レビュー | [`receiving-code-review`](../../_repos/obra_superpowers/skills/receiving-code-review/SKILL.md) | レビュー指摘を検証してから受け入れ、必要なら技術的に反論 |
| レビュー・診断 | [`diagnosing-superpowers`](../../_repos/obra_superpowers/skills/diagnosing-superpowers/SKILL.md) | 現在または過去セッションの記録を行単位の証拠で診断 |
| 完了 | [`finishing-a-development-branch`](../../_repos/obra_superpowers/skills/finishing-a-development-branch/SKILL.md) | テスト、統合/PR/保持の選択、worktree の後始末 |

サブエージェントの実体を固定した独自エージェント定義ディレクトリは確認できない。代わりに SDD の [`implementer-prompt.md`](../../_repos/obra_superpowers/skills/subagent-driven-development/implementer-prompt.md)、タスクレビュー用・再レビュー用テンプレート、並列エージェント用のプロンプト構造が、各ハーネスのサブエージェント機能へ渡す役割を担う。Muse のマニフェストでは `commands` と `mcpServers` は空であり、専用コマンドを配布する設計ではない（[`.muse-plugin/plugin.json`](../../_repos/obra_superpowers/.muse-plugin/plugin.json)）。

### 基本ワークフロー

README が示す標準経路は、概ね次の順序である。

1. `brainstorming` で意図と設計を確認し、承認された設計を保存する。
2. `using-git-worktrees` で隔離環境とクリーンなベースラインを準備する。
3. `writing-plans` で小さなタスク、対象ファイル、完全なコード方針、検証を記述する。
4. `subagent-driven-development` または `executing-plans` で実装する。
5. `test-driven-development`、`requesting-code-review`、`verification-before-completion` で実装・レビュー・検証を進める。
6. `finishing-a-development-branch` で統合、PR 作成、保持のいずれかを選ぶ。

この順序や「実装前にスキルを確認する」規約は、単なる README の推奨ではなく、`using-superpowers` と各 SKILL.md の行動指示として実装されている。

## ハーネス連携、設定、フック、配布

### ブートストラップ実装

- [`hooks/session-start`](../../_repos/obra_superpowers/hooks/session-start) は `using-superpowers/SKILL.md` を読み込み、ハーネスごとに異なる JSON 形式で追加コンテキストを出力する。Cursor、Claude Code、Muse、Copilot CLI/未知の環境を環境変数で分岐する。
- [`hooks/run-hook.cmd`](../../_repos/obra_superpowers/hooks/run-hook.cmd) は Windows の CMD と Unix 系の双方から Bash スクリプトを起動するポリグロット・ディスパッチャーである。Claude Code 用 [`hooks/hooks.json`](../../_repos/obra_superpowers/hooks/hooks.json) は `startup|clear|compact`、Cursor 用 [`hooks/hooks-cursor.json`](../../_repos/obra_superpowers/hooks/hooks-cursor.json) は `sessionStart` に接続する。
- OpenCode は [`index.js`](../../_repos/obra_superpowers/index.js) から [`.opencode/plugins/superpowers.js`](../../_repos/obra_superpowers/.opencode/plugins/superpowers.js) を読み、スキル登録とセッション/コンパクション後のブートストラップを in-process で行う。V1 と V2 を分け、V2 は 2.0.4 以降を対象とする。
- Pi は [`.pi/extensions/superpowers.ts`](../../_repos/obra_superpowers/.pi/extensions/superpowers.ts) で `resources_discover`、`session_start`、`session_compact`、`context` を使う。スキルディレクトリを登録し、コンパクション後にも bootstrap を再注入する。
- Hermes は [`.hermes-plugin/__init__.py`](../../_repos/obra_superpowers/.hermes-plugin/__init__.py) で全 SKILL.md を登録し、最初の `pre_llm_call` に `using-superpowers` とツールマッピングを注入する。Hermes は post-compaction hook を持たないため、長いセッションで bootstrap が失われ得ると README が注意している。
- Codex はスキルをネイティブに扱う前提で、[`.codex-plugin/plugin.json`](../../_repos/obra_superpowers/.codex-plugin/plugin.json) の `hooks: {}` により `hooks/hooks.json` の自動発見を明示的に抑制する。Codex 用の SessionStart フックは登録しない。

### 対応ハーネスとマニフェスト

README の導入手順は Claude Code、Antigravity、Codex App/CLI、Cursor、Devin CLI、Factory Droid、Gemini CLI、GitHub Copilot CLI、Grok Build CLI、Kimi Code、OpenCode、Pi、Qwen Code、Hermes Agent、Muse を列挙する。専用ファイルが確認できる連携は次の通りである。

| パス | 役割 |
| --- | --- |
| [`.claude-plugin/plugin.json`](../../_repos/obra_superpowers/.claude-plugin/plugin.json) | Claude Code プラグインのメタデータ。`skills/` と `hooks/` は規約による発見 |
| [`.claude-plugin/marketplace.json`](../../_repos/obra_superpowers/.claude-plugin/marketplace.json) | Claude 用ローカル marketplace エントリ |
| [`.codex-plugin/plugin.json`](../../_repos/obra_superpowers/.codex-plugin/plugin.json) | Codex 用 skills と配布 UI 情報。hooks は空オブジェクト |
| [`.agents/plugins/marketplace.json`](../../_repos/obra_superpowers/.agents/plugins/marketplace.json) | Codex marketplace 側のインストールエントリ |
| [`.cursor-plugin/plugin.json`](../../_repos/obra_superpowers/.cursor-plugin/plugin.json) | Cursor の skills と `hooks-cursor.json` の指定 |
| [`.devin-plugin/plugin.json`](../../_repos/obra_superpowers/.devin-plugin/plugin.json) | Devin CLI 用メタデータ |
| [`.hermes-plugin/plugin.yaml`](../../_repos/obra_superpowers/.hermes-plugin/plugin.yaml) | Hermes のバージョンと `pre_llm_call` hook 宣言 |
| [`.kimi-plugin/plugin.json`](../../_repos/obra_superpowers/.kimi-plugin/plugin.json) | Kimi の skills、sessionStart、ツール名マッピング |
| [`.muse-plugin/plugin.json`](../../_repos/obra_superpowers/.muse-plugin/plugin.json) | Muse の skills と SessionStart hook。15 スキルを明示 |
| [`.muse-plugin/marketplace.json`](../../_repos/obra_superpowers/.muse-plugin/marketplace.json) | Muse marketplace エントリ |
| [`gemini-extension.json`](../../_repos/obra_superpowers/gemini-extension.json) | Gemini 拡張の名前・バージョン・`GEMINI.md` コンテキスト指定 |
| [`package.json`](../../_repos/obra_superpowers/package.json) | OpenCode の `main` と Pi の extension/skills 配布指定 |
| [`.opencode/INSTALL.md`](../../_repos/obra_superpowers/.opencode/INSTALL.md) | OpenCode V1/V2 の導入、設定、ツールマッピング |

配布バージョンの同期対象は [`.version-bump.json`](../../_repos/obra_superpowers/.version-bump.json) に集約され、`package.json`、各プラグインマニフェスト、marketplace、Gemini manifest の計 10 箇所が列挙されている。Codex 向けには [`scripts/package-codex-plugin.sh`](../../_repos/obra_superpowers/scripts/package-codex-plugin.sh)（zip 既定、tar.gz も可）と [`scripts/sync-to-codex-plugin.sh`](../../_repos/obra_superpowers/scripts/sync-to-codex-plugin.sh) がある。

## 主要ディレクトリ・ファイル構成

| パス | 役割 |
| --- | --- |
| [`skills/`](../../_repos/obra_superpowers/skills/) | 15 個のスキル本体と補助資料・プロンプト・スクリプト |
| [`hooks/`](../../_repos/obra_superpowers/hooks/) | セッション開始のコンテキスト注入と Windows/Unix 共通起動 |
| [`scripts/`](../../_repos/obra_superpowers/scripts/) | バージョン同期、shell lint、Codex 配布・同期 |
| [`tests/`](../../_repos/obra_superpowers/tests/) | ハーネス統合、マニフェスト、bootstrap、スクリプトの決定的テスト |
| [`docs/`](../../_repos/obra_superpowers/docs/) | Kimi/OpenCode の導入、ハーネス移植、テスト、Windows hook 設計 |
| [`assets/`](../../_repos/obra_superpowers/assets/) | Codex 等の UI 用アイコン（PNG/SVG） |
| [`.claude-plugin/`、`.codex-plugin/`、`.cursor-plugin/`、`.devin-plugin/`、`.hermes-plugin/`、`.kimi-plugin/`、`.muse-plugin/`](../../_repos/obra_superpowers/) | ハーネス別 manifest/marketplace/実装 |
| [`.opencode/`](../../_repos/obra_superpowers/.opencode/) | OpenCode plugin と導入ガイド |
| [`.pi/`](../../_repos/obra_superpowers/.pi/) | Pi extension |
| [`README.md`](../../_repos/obra_superpowers/README.md) | 利用者向け概要、導入、標準ワークフロー、機能一覧、制約 |
| [`AGENTS.md`](../../_repos/obra_superpowers/AGENTS.md) | コントリビューター向け canonical ガイドライン |
| [`RELEASE-NOTES.md`](../../_repos/obra_superpowers/RELEASE-NOTES.md) | リリース単位の機能・対応ハーネス・修正履歴 |

`evals/` は `.gitignore` により外部 eval リポジトリ用のローカル領域として除外されており、このスナップショットの Git 管理対象ではない。

## 利用・導入・実行ワークフロー

導入はハーネスごとに別々に行う。README に記載された代表例は以下の通りである。

- Claude Code: official marketplace の `superpowers` をインストール。
- Codex App/CLI: Plugins から検索・インストール。
- Cursor: `/add-plugin superpowers` または marketplace。
- OpenCode: V1 は `plugin`、V2 (2.0.4+) は `plugins` に Git package またはリポジトリディレクトリを指定し、再起動。
- Pi: `pi install git:github.com/obra/superpowers`。ローカル確認は `pi -e /path/to/superpowers`。
- Hermes: `hermes plugins install obra/superpowers --enable`。
- Muse: `muse plugins install ./` の後に `muse plugins approve superpowers`。新規セッションで acceptance prompt を確認。
- Gemini、Devin、Kimi、Antigravity、Factory、Copilot、Grok、Qwen についても README に各 CLI の install/update コマンドがある。ここでは実際の CLI を動かしたことまでは確認していない。

導入後はセッション開始時に `using-superpowers` が注入され、ユーザーが明示的にスキル名を入力しなくても、設計・計画・実装・検証の局面に応じてスキルを選ぶことを狙う。OpenCode と Pi は再開/コンパクション時の扱いも実装しているが、Hermes は post-compaction hook がないという制約がある。

## テスト・検証方法

[`docs/testing.md`](../../_repos/obra_superpowers/docs/testing.md) は検証を二種類に分けている。

1. `tests/`: Bash、Node.js、Python による plugin 非LLMコードのテスト。brainstorm-server、OpenCode、Codex sync、Kimi、Claude Code、各マニフェスト、hook、shell lint、version bump、Pi、Hermes 等を対象にする。
2. `evals/`: 実際の coding-agent CLI と LLM セッションを使うスキル行動評価。外部の `superpowers-evals` リポジトリを `evals/` に取得して使う想定で、時間と権限のリスクがあるため、静的ゲートと live eval を分ける設計である。

主な入口は以下の通り。

| 入口 | 検証内容・条件 |
| --- | --- |
| [`tests/opencode/run-tests.sh`](../../_repos/obra_superpowers/tests/opencode/run-tests.sh) | plugin loading、bootstrap caching、session bootstrap、V2 skill registration。`--integration` で OpenCode 実体の tools/priority テストを追加 |
| [`tests/claude-code/run-skill-tests.sh`](../../_repos/obra_superpowers/tests/claude-code/run-skill-tests.sh) | Claude CLI を headless 実行する fast テスト。`--integration` は実ワークフローで 10–30 分想定 |
| [`tests/antigravity/run-tests.sh`](../../_repos/obra_superpowers/tests/antigravity/run-tests.sh) | Antigravity のツールマッピング統合テスト |
| [`tests/kimi/run-tests.sh`](../../_repos/obra_superpowers/tests/kimi/run-tests.sh) | Kimi manifest 検証 |
| [`tests/brainstorm-server/`](../../_repos/obra_superpowers/tests/brainstorm-server/) | Node の brainstorm visual companion/server テスト |
| [`tests/hooks/test-session-start.sh`](../../_repos/obra_superpowers/tests/hooks/test-session-start.sh) | hook の JSON 形式・ディスパッチ検証 |
| [`tests/hermes/`](../../_repos/obra_superpowers/tests/hermes/) | Hermes の plugin/bootstrap テスト |
| [`tests/pi/test-pi-extension.mjs`](../../_repos/obra_superpowers/tests/pi/test-pi-extension.mjs) | Pi extension の bootstrap と mapping 検証 |
| [`tests/codex/`](../../_repos/obra_superpowers/tests/codex/)、[`tests/codex-plugin-sync/`](../../_repos/obra_superpowers/tests/codex-plugin-sync/) | Codex manifest、決定的 package、同期処理 |
| [`tests/shell-lint/test-lint-shell.sh`](../../_repos/obra_superpowers/tests/shell-lint/test-lint-shell.sh) | `shellcheck`/`shfmt` を用いた対象ファイル選択と lint |

補助スクリプトには、宣言したマニフェストの全バージョンを検査/更新する [`scripts/bump-version.sh`](../../_repos/obra_superpowers/scripts/bump-version.sh)、変更/全体の shell を検査する [`scripts/lint-shell.sh`](../../_repos/obra_superpowers/scripts/lint-shell.sh) がある。`pre-commit` は主に `evals/*.py` の ruff/ty を対象にする（[`.pre-commit-config.yaml`](../../_repos/obra_superpowers/.pre-commit-config.yaml)）。

この調査ではファイルの読解と Git メタデータ確認を行ったが、Claude/OpenCode 等の外部 CLI、live LLM eval、ブラウザ/メディアを含む統合テストは実行していない。したがって、テスト入口と設計は確認できるが、調査時点の全ハーネスでの動作成功までは主張できない。

## 品質上の特徴、制約、残課題

### 特徴

- 設計・実装・レビュー・完了の一連の工程を、スキル間の参照と明示的なゲートで接続している。
- TDD、根本原因調査、成功宣言前の実証を強く要求し、実装サブエージェントとレビューサブエージェントを分離する。
- ハーネスの差異をスキル本文に混ぜず、manifest、bootstrap、tool mapping、ネイティブ API の薄い層で吸収する方針が [`docs/porting-to-a-new-harness.md`](../../_repos/obra_superpowers/docs/porting-to-a-new-harness.md) に整理されている。
- version bump の対象を宣言ファイルで管理し、Codex 配布はアーカイブのメタデータ・モード・チェックサムを検査する設計である。
- brainstorming の visual companion はデフォルトで Prime Radiant のロゴとバージョンを取得する telemetry を持つが、README では `SUPERPOWERS_DISABLE_TELEMETRY` 等による opt-out を明記している（[`README.md`](../../_repos/obra_superpowers/README.md)）。

### 制約・残課題（ファイルから確認できる範囲）

- スキルの品質は文章だけでなくエージェント行動に依存するため、決定的な plugin tests だけでは保証できない。live eval は外部リポジトリと実 CLI、モデル、権限に依存する。
- ハーネスごとに bootstrap の寿命と JSON schema が違う。特に Hermes は post-compaction hook がないため、長いセッションでは新規セッションが必要になる可能性がある。
- Codex は SessionStart hook を意図的に使わず、ネイティブ skill discovery に依存する。別ハーネスを追加する場合も、自動セッション開始注入が必須条件とガイドされている。
- OpenCode V2 は `2.0.4` 以降を前提にし、V1/V2 の設定キー・ローカルパス・skill registration 契約が異なる。OpenCode 実体がない環境では integration tests を完遂できない。
- `evals/` はこのリポジトリの配布スナップショットに含まれず、評価記録もローカル環境依存である。今回のノートではその結果を確認していない。
- contributor 向け [`AGENTS.md`](../../_repos/obra_superpowers/AGENTS.md) は PR の重複調査、人手レビュー、実セッションの証拠、ハーネス追加時の acceptance transcript を要求する。したがって、本文の要約だけから新しい integration の実動作を断定することはできない。

## 参照した代表的なファイル

- [README.md](../../_repos/obra_superpowers/README.md): 目的、導入、標準ワークフロー、対応ハーネス、機能、telemetry
- [AGENTS.md](../../_repos/obra_superpowers/AGENTS.md): コントリビューター向け制約と品質基準
- [package.json](../../_repos/obra_superpowers/package.json)、[gemini-extension.json](../../_repos/obra_superpowers/gemini-extension.json): 基本メタデータと Pi/Gemini 接続
- [hooks/session-start](../../_repos/obra_superpowers/hooks/session-start)、[hooks/hooks.json](../../_repos/obra_superpowers/hooks/hooks.json): SessionStart のコンテキスト注入
- [.opencode/plugins/superpowers.js](../../_repos/obra_superpowers/.opencode/plugins/superpowers.js)、[.pi/extensions/superpowers.ts](../../_repos/obra_superpowers/.pi/extensions/superpowers.ts)、[.hermes-plugin/__init__.py](../../_repos/obra_superpowers/.hermes-plugin/__init__.py): in-process/bootstrap 実装
- [.codex-plugin/plugin.json](../../_repos/obra_superpowers/.codex-plugin/plugin.json)、[scripts/package-codex-plugin.sh](../../_repos/obra_superpowers/scripts/package-codex-plugin.sh): Codex の hook 抑制と配布
- [docs/porting-to-a-new-harness.md](../../_repos/obra_superpowers/docs/porting-to-a-new-harness.md)、[docs/testing.md](../../_repos/obra_superpowers/docs/testing.md): ハーネス移植原則とテスト体系
- [RELEASE-NOTES.md](../../_repos/obra_superpowers/RELEASE-NOTES.md): 対象リリースの変更点

このノートディレクトリで作成・変更したファイルは本 `README.md` のみです。他レポジトリのノート、親側 README、ソースレポジトリ、`AGENTS.md` は変更していません。

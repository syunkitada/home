# addyosmani/agent-skills 調査ノート

> このファイルは、外部リポジトリのローカルスナップショットを対象にした中間調査資料です。内容は調査時点のファイルとGit履歴に基づくため、上流の更新後も自動では追随しません。

## 対象・調査時点

| 項目 | 内容 |
| --- | --- |
| 対象 | [`addyosmani_agent-skills`](../../_repos/addyosmani_agent-skills/) |
| 上流として確認できた取得元 | `https://github.com/addyosmani/agent-skills.git`（ローカルcloneの`origin`） |
| 調査日 | 2026-09-23 |
| HEAD | `dc27a9c2e13721158157632de61b4106c6c2a2a1` |
| HEADの直近コミット | 2026-09-20、`Merge #579: move security-and-hardening code patterns into a skill-local reference` |
| タグとの関係 | `git describe --tags --always --dirty` は `0.6.10-22-gdc27a9c`。各プラグインマニフェストのバージョンは`0.6.10` |
| 取得時の状態 | ソースcloneのワーキングツリーはclean |

直近履歴には、フック回帰テスト、負例トリガーのowner、参照リンク検証、評価結果の実行識別、UIスキルのチェックなどに関するマージコミットが確認できる。

## 目的と全体像

`agent-skills`は、AIコーディングエージェントにシニアエンジニア相当の開発手順を適用するための、Markdownベースのワークフロー集である。単なる知識集ではなく、各`SKILL.md`に「いつ使うか」「手順」「省略しがちな理由への反論」「危険信号」「検証」を持たせ、作業フェーズごとに適切なスキルを選択・実行させる設計になっている。

中心となる流れは、`DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP`。共有コアは`skills/`で、Claude Code、Codex、Gemini CLI、Antigravity CLI、OpenCode、Copilot、Cursor、Windsurf、Kiroなどには、それぞれの発見・インストール規約に合わせたアダプターまたは導入手順を提供する。スキル本体、専門家ペルソナ、スラッシュコマンド、参照チェックリストを分離し、コマンドがペルソナやスキルを組み合わせる構成である。

リポジトリ自身の[`AGENTS.md`](../../_repos/addyosmani_agent-skills/AGENTS.md)は、このリポジトリを編集するAIエージェント向けの規約であり、利用者のプロジェクトへコピーするものではない、と明記している。再利用対象は`skills/`配下のスキルである。

## 主要スキル

HEAD時点で25スキル（READMEの分類ではライフサイクル24件＋メタスキル1件）。各スキルは原則として`skills/<name>/SKILL.md`に置かれ、YAML frontmatterの`name`と`description`を持つ。

| フェーズ | スキル（ソース） | 概要 |
| --- | --- | --- |
| Meta | [`using-agent-skills`](../../_repos/addyosmani_agent-skills/skills/using-agent-skills/SKILL.md) | 作業内容から適切なスキルを選ぶルーティング規則 |
| Define | [`interview-me`](../../_repos/addyosmani_agent-skills/skills/interview-me/SKILL.md)、[`idea-refine`](../../_repos/addyosmani_agent-skills/skills/idea-refine/SKILL.md) | 一問ずつの要件聴取、曖昧なアイデアの発散・収束 |
| Define | [`spec-driven-development`](../../_repos/addyosmani_agent-skills/skills/spec-driven-development/SKILL.md)、[`constraint-driven-development`](../../_repos/addyosmani_agent-skills/skills/constraint-driven-development/SKILL.md) | 実装前の仕様化、品質基準の明文化と弱体化防止 |
| Plan | [`planning-and-task-breakdown`](../../_repos/addyosmani_agent-skills/skills/planning-and-task-breakdown/SKILL.md) | 仕様を依存順の小さく検証可能なタスクへ分解 |
| Build | [`incremental-implementation`](../../_repos/addyosmani_agent-skills/skills/incremental-implementation/SKILL.md)、[`test-driven-development`](../../_repos/addyosmani_agent-skills/skills/test-driven-development/SKILL.md) | 薄い縦切りでの実装、Red-Green-Refactor |
| Build | [`context-engineering`](../../_repos/addyosmani_agent-skills/skills/context-engineering/SKILL.md)、[`source-driven-development`](../../_repos/addyosmani_agent-skills/skills/source-driven-development/SKILL.md)、[`doubt-driven-development`](../../_repos/addyosmani_agent-skills/skills/doubt-driven-development/SKILL.md) | エージェント文脈の整備、公式資料に基づく判断、敵対的な再検討 |
| Build | [`frontend-ui-engineering`](../../_repos/addyosmani_agent-skills/skills/frontend-ui-engineering/SKILL.md)、[`api-and-interface-design`](../../_repos/addyosmani_agent-skills/skills/api-and-interface-design/SKILL.md) | UIの品質・アクセシビリティ、API/モジュール境界の設計 |
| Verify | [`browser-testing-with-devtools`](../../_repos/addyosmani_agent-skills/skills/browser-testing-with-devtools/SKILL.md)、[`debugging-and-error-recovery`](../../_repos/addyosmani_agent-skills/skills/debugging-and-error-recovery/SKILL.md) | Chrome DevTools MCPによる実ブラウザ検証、再現・局所化・修正・再発防止 |
| Review | [`code-review-and-quality`](../../_repos/addyosmani_agent-skills/skills/code-review-and-quality/SKILL.md)、[`code-simplification`](../../_repos/addyosmani_agent-skills/skills/code-simplification/SKILL.md) | 正確性・可読性・構造・安全性・性能のレビュー、振る舞いを保った簡素化 |
| Review | [`security-and-hardening`](../../_repos/addyosmani_agent-skills/skills/security-and-hardening/SKILL.md)、[`performance-optimization`](../../_repos/addyosmani_agent-skills/skills/performance-optimization/SKILL.md) | OWASP・秘密情報・境界の防御、測定先行の性能改善 |
| Ship | [`git-workflow-and-versioning`](../../_repos/addyosmani_agent-skills/skills/git-workflow-and-versioning/SKILL.md)、[`ci-cd-and-automation`](../../_repos/addyosmani_agent-skills/skills/ci-cd-and-automation/SKILL.md) | 原子的なGit運用、CI/CD品質ゲート |
| Ship | [`deprecation-and-migration`](../../_repos/addyosmani_agent-skills/skills/deprecation-and-migration/SKILL.md)、[`documentation-and-adrs`](../../_repos/addyosmani_agent-skills/skills/documentation-and-adrs/SKILL.md) | 廃止・移行、設計判断と公開変更の記録 |
| Ship | [`observability-and-instrumentation`](../../_repos/addyosmani_agent-skills/skills/observability-and-instrumentation/SKILL.md)、[`shipping-and-launch`](../../_repos/addyosmani_agent-skills/skills/shipping-and-launch/SKILL.md) | ログ・メトリクス・トレース・アラート、リリース前チェックとロールバック |

設計上の共通品質ゲートは、各`SKILL.md`の検証節、反合理化テーブル、レッドフラグである。共有チェックリストは[`references/`](../../_repos/addyosmani_agent-skills/references/)にあり、Definition of Done、テスト、セキュリティ、性能、アクセシビリティ、可観測性、ペルソナ連携を扱う。

## エージェント、コマンド、フック

### 専門家エージェント

[`agents/`](../../_repos/addyosmani_agent-skills/agents/)には単一の役割・視点・出力形式を持つ4ペルソナがある。

| ペルソナ | 用途 |
| --- | --- |
| [`code-reviewer.md`](../../_repos/addyosmani_agent-skills/agents/code-reviewer.md) | 正確性、可読性、構造、安全性、性能の5軸レビュー |
| [`security-auditor.md`](../../_repos/addyosmani_agent-skills/agents/security-auditor.md) | 脅威モデル、OWASP、秘密情報、認証・認可の監査 |
| [`test-engineer.md`](../../_repos/addyosmani_agent-skills/agents/test-engineer.md) | テスト戦略、カバレッジ、正常系・境界・失敗系の不足確認 |
| [`web-performance-auditor.md`](../../_repos/addyosmani_agent-skills/agents/web-performance-auditor.md) | Web性能のQuick/Deep監査、Core Web Vitalsと測定値の出典管理 |

ペルソナ同士は呼び出さず、ユーザーまたはコマンドがオーケストレーションする。`/ship`だけが明示された代表例で、`code-reviewer`、`security-auditor`、`test-engineer`を並列に実行し、メインコンテキストでGo/No-Goとロールバック計画へ統合する。

### ライフサイクルコマンド

Claude Code用のMarkdownコマンドは[`.claude/commands/`](../../_repos/addyosmani_agent-skills/.claude/commands/)、Gemini CLI用とAntigravity CLI用のTOMLはそれぞれ[`.gemini/commands/`](../../_repos/addyosmani_agent-skills/.gemini/commands/)と[`commands/`](../../_repos/addyosmani_agent-skills/commands/)にある。両系統で検証対象となる9コマンドは次の通り。

`/spec`（仕様化）、`/plan`または`/planning`（計画）、`/build`（TDD付き段階実装）、`/test`（TDD）、`/constraints`（品質制約）、`/review`（5軸レビュー）、`/code-simplify`（簡素化）、`/webperf`（Web性能監査）、`/ship`（並列専門家レビューと出荷判定）。`/build auto`は仕様の存在、作業ツリー、ユーザーの一回の承認を確認してから全タスクを一件ずつテスト・コミットするモードである。

### フック

[`hooks/`](../../_repos/addyosmani_agent-skills/hooks/)はホストへ個別に接続する補助機能で、Claude Code/Codexのネイティブなスキルルーティングとは重ねて使わない前提である。

- [`session-start.sh`](../../_repos/addyosmani_agent-skills/hooks/session-start.sh)：`using-agent-skills`をSessionStart標準JSONの`additionalContext`へ注入する。ネイティブルーターを持たないホスト向けで、`jq`がない場合のフォールバックも持つ。
- [`sdd-cache-pre.sh`](../../_repos/addyosmani_agent-skills/hooks/sdd-cache-pre.sh) / [`sdd-cache-post.sh`](../../_repos/addyosmani_agent-skills/hooks/sdd-cache-post.sh)：URL、ETag、Last-Modifiedを使う取得結果キャッシュの前後処理。テストでは304時にキャッシュ内容を再利用する挙動を確認している。
- [`simplify-ignore.sh`](../../_repos/addyosmani_agent-skills/hooks/simplify-ignore.sh)：Read前に保護ブロックをハッシュ付きプレースホルダーへ置き換え、Edit/Write後に再フィルタし、Stop時に復元する。`jq`と`shasum`または`sha1sum`を利用する。
- `*-test.sh`：上記フックのJSON、キャッシュ再検証、プレースホルダーのバイト忠実なラウンドトリップを回帰検証する。

## 構成

### 主要ディレクトリ・ファイル

| パス | 役割 |
| --- | --- |
| [`skills/`](../../_repos/addyosmani_agent-skills/skills/) | 25個の共有ワークフロー。各サブディレクトリの`SKILL.md`が本体 |
| [`agents/`](../../_repos/addyosmani_agent-skills/agents/) | 4つの専門家ペルソナ |
| [`commands/`](../../_repos/addyosmani_agent-skills/commands/) | Antigravity CLI向けの9つのレガシーTOMLラッパー |
| [`.claude/`](../../_repos/addyosmani_agent-skills/.claude/) | Claude Codeのコマンドと貢献ルール |
| [`.gemini/`](../../_repos/addyosmani_agent-skills/.gemini/) | Gemini CLIのコマンド |
| [`.opencode/skills`](../../_repos/addyosmani_agent-skills/.opencode/skills) | `../skills/`を指すシンボリックリンク |
| [`references/`](../../_repos/addyosmani_agent-skills/references/) | スキルから参照する7つの共有チェックリスト |
| [`hooks/`](../../_repos/addyosmani_agent-skills/hooks/) | セッション開始、取得キャッシュ、保護ブロックのホスト連携 |
| [`scripts/`](../../_repos/addyosmani_agent-skills/scripts/) | 構造・リンク・コマンド・バージョン検証と評価ランナー |
| [`evals/`](../../_repos/addyosmani_agent-skills/evals/) | 25スキル分のトリガー/行動評価ケースとfixture |
| [`docs/`](../../_repos/addyosmani_agent-skills/docs/) | 共通導入、スキル設計、各ハーネス向け設定ガイド |
| [`.claude-plugin/`](../../_repos/addyosmani_agent-skills/.claude-plugin/) | Claude Codeプラグイン・マーケットプレイス定義 |
| [`.codex-plugin/`](../../_repos/addyosmani_agent-skills/.codex-plugin/)、[`.agents/plugins/`](../../_repos/addyosmani_agent-skills/.agents/plugins/) | Codexプラグイン定義とマーケットプレイス登録 |
| [`plugin.json`](../../_repos/addyosmani_agent-skills/plugin.json) | ルートの汎用プラグインメタデータ |
| [`README.md`](../../_repos/addyosmani_agent-skills/README.md) | 機能一覧、導入例、対応ハーネス、設計方針 |
| [`AGENTS.md`](../../_repos/addyosmani_agent-skills/AGENTS.md)、[`CLAUDE.md`](../../_repos/addyosmani_agent-skills/CLAUDE.md)、[`CONTRIBUTING.md`](../../_repos/addyosmani_agent-skills/CONTRIBUTING.md) | リポジトリ編集時のエージェント規約、Claude向け補足、貢献ルール |
| [`.github/workflows/test-plugin-install.yml`](../../_repos/addyosmani_agent-skills/.github/workflows/test-plugin-install.yml) | GitHub Actionsの検証・プラグインインストールCI |

### マニフェストと配布

主要マニフェストはすべてバージョン`0.6.10`を持ち、[`validate-versions.js`](../../_repos/addyosmani_agent-skills/scripts/validate-versions.js)が最新Gitタグとの一致を検査する。

- Claude Code：`.claude-plugin/plugin.json`が`skills`と両コマンドディレクトリを登録し、`.claude-plugin/marketplace.json`がGitHub上の`addy-agent-skills`マーケットプレイスを定義する。
- Codex：`.codex-plugin/plugin.json`がルート`skills/`を参照し、`.agents/plugins/marketplace.json`がローカルルートをプラグインソースとして登録する。
- Antigravity CLI：ルート`plugin.json`と`commands/`を利用する。ドキュメントによれば、影響を受ける一部バージョンではTOMLの「変換済み」ラッパーが発見できないため、名前空間付きのスキルを直接呼び出す。
- Gemini CLI：`.gemini/commands/`にネイティブTOMLコマンドを置く。
- OpenCode：`.opencode/skills`が共有`skills/`を指し、`AGENTS.md`の意図→スキル対応とライフサイクル規則を併用する。
- Copilot CLI：ルート`plugin.json`がメタデータを提供し、READMEでは`skills/`を規約で発見すると説明する。Cursor、Windsurf、Kiroなどは各導入ガイドに従って共有Markdownをコピーまたは配置する。

一つのスキルだけをCLIでコピーする場合、リポジトリルートの`references/`が同梱されず共有チェックリストへのリンクが使えない可能性がある。この portability gap はREADMEと[`docs/skill-anatomy.md`](../../_repos/addyosmani_agent-skills/docs/skill-anatomy.md)が既知の制約として扱っている。

## 利用・導入ワークフロー

1. 全体を導入する場合は、公開skills CLIの`npx skills add addyosmani/agent-skills`、または対象ハーネスの導入手順を使う。Claude Codeはマーケットプレイス追加後にプラグインをインストールし、Codexは`codex plugin marketplace add`と`codex plugin add`を使う。
2. ホストがスキルをネイティブ発見する場合は、`using-agent-skills`を常時コンテキストへ重ねず、frontmatterの説明からオンデマンドで選ばせる。ネイティブ発見を持たないエージェントでは、メタスキルを最初に読み込む。
3. 作業は通常、`/spec` → `/plan` → `/build` → `/test` → `/review` → `/ship`の順で進める。UI、API、デバッグ、セキュリティ、性能などの作業では対応する専門スキルを追加で使う。
4. 各スキルの検証節と共有チェックリストを完了条件にする。`/build auto`では仕様が既知のパスにあることと、無関係な未コミット変更がないことを確認してから承認を求める。
5. 既存プロジェクトへ展開する場合も、ソースリポジトリの`AGENTS.md`/`CLAUDE.md`をそのままコピーしない。必要なスキルとプロジェクト固有の規約を通常の場所へ配置する。

## テスト・検証方法

### リポジトリが提供する検証

[`evals/README.md`](../../_repos/addyosmani_agent-skills/evals/README.md)では次の3層を定義している。

1. 構造検証：frontmatter、命名、必須セクション、コマンド対応をCIで検査する。
2. トリガー/ルーティング評価：説明文を語幹化TF-IDFでランキングし、正例が上位に来るか、負例で別スキルが優先されるか、説明文同士の衝突がないかを決定的に確認する。
3. 行動評価：ヘッドレスClaudeで実行または対話評価を行い、`expectations[]`を採点する。execution評価はfixtureから一時Gitリポジトリを作り、dialogue評価は会話自体を成果物とする。

主なコマンドは、`node scripts/validate-skills.js`、`node scripts/validate-commands.js`、`node scripts/validate-artifact-paths.js`、`node scripts/validate-reference-links.js`、`node scripts/validate-versions.js`、`node scripts/run-evals.js`。CI（[`test-plugin-install.yml`](../../_repos/addyosmani_agent-skills/.github/workflows/test-plugin-install.yml)）ではNode.js 24を使い、これらに加えてNode組み込みテスト、フック回帰テスト、Claudeプラグインのvalidate/installを実行する。

### この調査で実行した結果

ソースのHEADで次を実行し、すべて終了コード0だった。

- `validate-skills`：25スキル、エラー0・警告0
- `validate-versions`：全マニフェストが`0.6.10`
- `validate-commands`：9コマンドの対応・説明同期ともに合格
- `validate-artifact-paths`：7ファイル合格
- `validate-reference-links`：25スキル、エラー0
- `node --test`で主要6テストファイル：90テスト合格
- `session-start-test.sh`：合格
- `simplify-ignore-test.sh`：49 passed / 0 failed
- `sdd-cache-test.sh`：29 passed / 0 failed

## 品質上の特徴、制約・残課題

### ファイルから確認できる特徴

- スキルを手順・検証・反合理化まで含む実行規約として設計し、参照資料を必要時だけ読み込むprogressive disclosureを採用している。
- スキル名とディレクトリ名の一致、kebab-case、descriptionのトリガー文、必須セクション、既知スキルへの参照をlintする。`using-agent-skills`と`idea-refine`は明示的なセクション検査例外である。
- Claude/Gemini/Antigravityのコマンド記述を同期検証し、成果物パス（`SPEC.md`、`docs/SPEC.md`、`tasks/plan.md`等）や共有参照リンクのドリフトをCIで防ぐ。
- 各スキルに評価ケースを要求し、正例3件・負例2件・行動評価1件を最低要件としている。CIのルーティングrank-1下限は95%である。
- フックには、JSON形式の厳密な出力、304キャッシュ、秘密/大きなコードブロックを一時的に隠す処理、Bash 5.2やjqなしの分岐など、回帰しやすい境界のテストがある。

### 制約・未確認事項

- 本調査では、外部サービスへの実際のプラグイン公開・各CLIへのインストール・Chrome DevTools MCPを使った実ブラウザ監査は実施していない。READMEと導入ガイドに記載された対応状況をファイルから確認した範囲である。
- `node scripts/run-evals.js`の決定的な評価は今回の検証一覧には含めず、Claudeを必要とする行動評価も実行していない。したがって、今回確認したのは構造・リンク・フックと関連テストの通過であり、全スキルの実行品質を保証するものではない。
- 個別スキルだけを配布するとルート`references/`が欠落する portability gap が残る。全体プラグイン導入、clone、または必要な参照の同梱が必要になる。
- Antigravity CLIの一部リリースでは、レガシーTOMLラッパーが変換済みと報告されても発見できないという既知の制約が文書化されている。直接スキルを呼ぶ運用が案内されている。
- ソースはドキュメント・スクリプト中心で、ルートに`package.json`や通常のアプリケーションビルド設定はない。CIはNode.jsスクリプト、Bash、ホストCLIの検証を直接呼び出す構成である。

## 代表的な参照ファイル

- 全体像・導入：[`README.md`](../../_repos/addyosmani_agent-skills/README.md)、[`docs/getting-started.md`](../../_repos/addyosmani_agent-skills/docs/getting-started.md)
- 編集規約：[`AGENTS.md`](../../_repos/addyosmani_agent-skills/AGENTS.md)、[`CONTRIBUTING.md`](../../_repos/addyosmani_agent-skills/CONTRIBUTING.md)
- スキル形式：[`docs/skill-anatomy.md`](../../_repos/addyosmani_agent-skills/docs/skill-anatomy.md)、[`scripts/lib/skill-lint.js`](../../_repos/addyosmani_agent-skills/scripts/lib/skill-lint.js)
- ペルソナと連携：[`docs/agents.md`](../../_repos/addyosmani_agent-skills/docs/agents.md)、[`references/orchestration-patterns.md`](../../_repos/addyosmani_agent-skills/references/orchestration-patterns.md)
- 評価：[`evals/README.md`](../../_repos/addyosmani_agent-skills/evals/README.md)、[`scripts/run-evals.js`](../../_repos/addyosmani_agent-skills/scripts/run-evals.js)
- 配布：[`docs/codex-setup.md`](../../_repos/addyosmani_agent-skills/docs/codex-setup.md)、[`docs/antigravity-setup.md`](../../_repos/addyosmani_agent-skills/docs/antigravity-setup.md)、[`.claude-plugin/plugin.json`](../../_repos/addyosmani_agent-skills/.claude-plugin/plugin.json)、[`.codex-plugin/plugin.json`](../../_repos/addyosmani_agent-skills/.codex-plugin/plugin.json)
- CI：[`.github/workflows/test-plugin-install.yml`](../../_repos/addyosmani_agent-skills/.github/workflows/test-plugin-install.yml)

## `session-retrospective` での参照

| 項目 | 内容 |
| --- | --- |
| 調査日 | 2026-10-18 |
| 対象コミット | `dc27a9c2e13721158157632de61b4106c6c2a2a1` |
| 参照したファイル | [`docs/skill-anatomy.md`](../../_repos/addyosmani_agent-skills/docs/skill-anatomy.md) |
| 採用した内容 | `SKILL.md` を短く保ち、必要な詳細を reference へ分ける構成と、入力・手順・検証の区切り。 |
| 未確認事項 | Codexでのskill discoveryと、個別skill配布時のreference同梱を実際には確認していない。 |

以上。

# mattpocock/skills 調査ノート

> これは、外部リポジトリのローカルスナップショットを対象にした中間調査資料です。将来の upstream の変更を自動追従するものではありません。記載内容は、特記がない限り調査時点のファイルから確認した事実です。

## 対象と調査時点

| 項目 | 内容 |
| --- | --- |
| 対象 | `mattpocock/skills`、ローカル取得先 [`_repos/mattpocock_skills/`](../../_repos/mattpocock_skills/) |
| 調査日 | 2026-09-23 |
| HEAD | `c55ee46073ed923f86ce59a5eb3b6d895095d1b7` |
| HEAD の短縮表記 | `c55ee46` |
| HEAD の日時 | 2026-09-18 11:12:29 +01:00 |
| HEAD の内容 | `Modified the PR body template to make it easier to scan` |
| 直近の履歴 | `74ca5fe`（2026-09-17、HTML artifact section の削除）、`35f5926`（2026-09-17、PR body の execution evidence 説明の改善） |
| 取得元として確認できた範囲 | Git remote `origin`: `https://github.com/mattpocock/skills.git` |
| 作業ツリー | 調査開始時点で未コミット変更なし |

## 目的と全体像

このリポジトリは、Claude Code、Codex、その他の agent harness で利用する、実務的なソフトウェア開発・生産性向けの agent skill 集である。トップレベル README は、GSD、BMAD、Spec-Kit のように開発プロセス全体を囲い込むのではなく、小さく適応可能で composable な技能を組み合わせる方針を示している。

中心となる考え方は次の三つである。

1. 仕様や設計を、質問を重ねる grilling、共有語彙、ADR、`CONTEXT.md` で明確にする。
2. 実装は TDD の red-green-refactor、狭い tracer-bullet ticket、深い module と seam を通じて、小さなフィードバックループで進める。
3. 実装後は、固定点からの diff を Standards と Spec の二軸で review する。

配布上は二つの経路がある。Claude Code では、安定版の `engineering` と `productivity` を明示列挙した read-only plugin として導入する。他の agent では `skills.sh` が通常ファイルとしてスキルをコピーし、利用者が選択・編集できる。README と [`install-block.md`](../../_repos/mattpocock_skills/.agents/install-block.md) は、この二つを同時導入せず、どちらか一方を選ぶよう説明している。

## 構成規模と分類

調査時点で Git 管理対象は 169 ファイル、`SKILL.md` は 38 個である。

| バケット | 個数 | 位置づけ | 配布 |
| --- | ---: | --- | --- |
| `engineering` | 18 | 日常のコード作業向け安定版 | Claude Code plugin に収録、docs ページあり |
| `productivity` | 7 | コードに限定しない安定版 | Claude Code plugin に収録、docs ページあり |
| `in-progress` | 9 | 公開 beta、フィードバック目的。仕様変更・消滅の可能性あり | plugin と安定版 docs から除外、`skills.sh` で個別導入 |
| `misc` | 4 | 保持しているが、通常は昇格しない補助ツール | plugin とトップ README から除外 |
| `deprecated` | 0 | 廃止済み | 空バケット |

各スキルには `SKILL.md` と [`agents/openai.yaml`](../../_repos/mattpocock_skills/skills/engineering/code-review/agents/openai.yaml) が置かれる。前者は動作指示、後者は Codex UI の表示名・短い説明と invocation policy を持つ。`disable-model-invocation: true` と `allow_implicit_invocation: false` の組み合わせが user-invoked、未指定が model-invoked である。安定版では user-invoked 14 個、model-invoked 11 個を確認した。

## 主要機能・スキル

### Engineering

詳細な一覧は [`skills/engineering/README.md`](../../_repos/mattpocock_skills/skills/engineering/README.md) にあり、各項目から対応する `SKILL.md` にリンクされている。

| 種別 | スキル | 要約 |
| --- | --- | --- |
| User-invoked | [`ask-matt`](../../_repos/mattpocock_skills/skills/engineering/ask-matt/SKILL.md) | 状況に合う skill/flow を案内する router。idea から ship までの主経路、bug、triage、巨大で不確かな作業、語彙整理を分岐させる。 |
| User-invoked | [`grill-with-docs`](../../_repos/mattpocock_skills/skills/engineering/grill-with-docs/SKILL.md) | `grilling` と `domain-modeling` を呼び、作業ディレクトリに質問結果、`CONTEXT.md`、ADR を残す入口。 |
| User-invoked | [`setup-matt-pocock-skills`](../../_repos/mattpocock_skills/skills/engineering/setup-matt-pocock-skills/SKILL.md) | repo ごとの issue tracker、triage label、domain docs の場所を対話的に設定する一度きりの setup。 |
| User-invoked | [`to-spec`](../../_repos/mattpocock_skills/skills/engineering/to-spec/SKILL.md) | 既存の会話と repo 理解を interview し直さず spec にまとめ、tracker に `ready-for-agent` として公開する。 |
| User-invoked | [`to-tickets`](../../_repos/mattpocock_skills/skills/engineering/to-tickets/SKILL.md) | spec や計画を、完成した縦切りの tracer-bullet ticket に分解し、blocking edge を付けて公開する。広範な機械的変更は expand-migrate-contract で扱う。 |
| User-invoked | [`implement`](../../_repos/mattpocock_skills/skills/engineering/implement/SKILL.md) | spec/ticket を実装し、可能なら `tdd` を事前合意した seam で駆動し、最後に `code-review` を実行する。 |
| User-invoked | [`triage`](../../_repos/mattpocock_skills/skills/engineering/triage/SKILL.md) | issue と設定対象の外部 PR を、canonical な triage role の状態機械に沿って分類・検証・brief 化する。 |
| User-invoked | [`wayfinder`](../../_repos/mattpocock_skills/skills/engineering/wayfinder/SKILL.md) | 一つの session に収まらない大きな作業を、`wayfinder:map` と decision ticket の共有 map にして、実装前の不確実性を解く。 |
| User-invoked | [`improve-codebase-architecture`](../../_repos/mattpocock_skills/skills/engineering/improve-codebase-architecture/SKILL.md) | shallow module の deepening 候補を探索し、視覚的 HTML report を一時ディレクトリへ出して選択後に grilling する。 |
| Model-invoked | [`diagnosing-bugs`](../../_repos/mattpocock_skills/skills/engineering/diagnosing-bugs/SKILL.md) | bug 固有の再現ループを先に作り、再現・最小化、3〜5 個の仮説、計測、回帰テスト、cleanup の順で診断する。 |
| Model-invoked | [`tdd`](../../_repos/mattpocock_skills/skills/engineering/tdd/SKILL.md) | 外部から観測可能な振る舞いを seam 越しに test-first で実装し、red-green-refactor を一つの縦切りごとに回す。 |
| Model-invoked | [`code-review`](../../_repos/mattpocock_skills/skills/engineering/code-review/SKILL.md) | 固定点からの diff を Standards と Spec の二軸で、二つの sub-agent に並列 review させて集約する。 |
| Model-invoked | [`codebase-design`](../../_repos/mattpocock_skills/skills/engineering/codebase-design/SKILL.md) | module、interface、depth、seam、adapter、leverage、locality という deep-module 設計語彙を提供する。 |
| Model-invoked | [`domain-modeling`](../../_repos/mattpocock_skills/skills/engineering/domain-modeling/SKILL.md) | `CONTEXT.md` の glossary と ADR を基準に、曖昧な用語や edge case を問い直し、必要なときだけ文書を更新する。 |
| Model-invoked | [`prototype`](../../_repos/mattpocock_skills/skills/engineering/prototype/SKILL.md) | state/logic または UI の設計疑問に対する throwaway artifact を作る。 |
| Model-invoked | [`research`](../../_repos/mattpocock_skills/skills/engineering/research/SKILL.md) | high-trust primary source の調査を background agent に委譲し、引用付き Markdown を残す。 |
| Model-invoked | [`resolving-merge-conflicts`](../../_repos/mattpocock_skills/skills/engineering/resolving-merge-conflicts/SKILL.md) | merge/rebase の conflict を hunk ごとに両側の意図から解決し、操作を完了する。 |
| Model-invoked | [`wizard`](../../_repos/mattpocock_skills/skills/engineering/wizard/SKILL.md) | credential、CI secret、第三者 dashboard など人間しか行えない手順を対話的 bash wizard にする。 |

### Productivity

一覧は [`skills/productivity/README.md`](../../_repos/mattpocock_skills/skills/productivity/README.md) にある。

| 種別 | スキル | 要約 |
| --- | --- | --- |
| User-invoked | [`grill-me`](../../_repos/mattpocock_skills/skills/productivity/grill-me/SKILL.md) | repo の文書を更新せず、計画・設計を relentless interview で詰める。 |
| Model-invoked | [`grilling`](../../_repos/mattpocock_skills/skills/productivity/grilling/SKILL.md) | 一度に一 round の質問を行う interview primitive。facts は agent が調査し、decisions は人に確認する。 |
| User-invoked | [`handoff`](../../_repos/mattpocock_skills/skills/productivity/handoff/SKILL.md) | 現在の会話を別 agent/session が引き継げる Markdown に圧縮する。 |
| User-invoked | [`teach`](../../_repos/mattpocock_skills/skills/productivity/teach/SKILL.md) | workspace を状態として使い、複数 session で概念を教える。mission、lesson、knowledge、skill、reference を保存する。 |
| User-invoked | [`to-questionnaire`](../../_repos/mattpocock_skills/skills/productivity/to-questionnaire/SKILL.md) | 自分だけでは決められない事項について、回答者と必要な返答を先に整理した questionnaire を作る。 |
| User-invoked | [`wait-what`](../../_repos/mattpocock_skills/skills/productivity/wait-what/SKILL.md) | 直前の説明が伝わらなかったとき、相手に不足している context と `CONTEXT.md` の語彙で言い直す。 |
| Model-invoked | [`writing-for-agents`](../../_repos/mattpocock_skills/skills/productivity/writing-for-agents/SKILL.md) | skill、AGENTS.md、CLAUDE.md など agent が読む文書の情報階層、context pointer、分割、pruning を整える。 |

### In-progress と misc

`in-progress` は `loop-me`、`writing-beats`、`writing-fragments`、`writing-shape`、`claude-handoff`、`implement-spec`、`pr`、`retro`、`setup-ts-deep-modules` の 9 個である。公開 beta だが plugin には含めず、README の指示どおり `skills.sh` の `--skill=<name>` で導入する。`pr` だけは model-invoked で、残りは user-invoked である。詳細な一行一覧は [`skills/in-progress/README.md`](../../_repos/mattpocock_skills/skills/in-progress/README.md) にある。

`misc` は [`git-guardrails-claude-code`](../../_repos/mattpocock_skills/skills/misc/git-guardrails-claude-code/SKILL.md)、`migrate-to-shoehorn`、`scaffold-exercises`、`setup-pre-commit` の 4 個で、いずれも plugin に昇格していない補助スキルである。`deprecated` の README は retired skill を削除する方針を示し、現在は空である。

## 主要ディレクトリ・ファイル

| パス | 役割 |
| --- | --- |
| [`README.md`](../../_repos/mattpocock_skills/README.md) | 目的、導入手順、代表的な失敗モード、安定版スキルの索引。 |
| [`AGENTS.md`](../../_repos/mattpocock_skills/AGENTS.md) | bucket、plugin 収録条件、docs 同期、invocation、symlink install、文体規約を定める maintainer 向け規約。 |
| [`CLAUDE.md`](../../_repos/mattpocock_skills/CLAUDE.md) | Claude 側の repo 運用指示。 |
| [`CONTEXT.md`](../../_repos/mattpocock_skills/CONTEXT.md) | issue、triage role、decision ticket など、skill が共有する語彙。 |
| [`.agents/`](../../_repos/mattpocock_skills/.agents/) | install block、invocation 方針、docs 作成規約、ADR。 |
| [`.claude-plugin/plugin.json`](../../_repos/mattpocock_skills/.claude-plugin/plugin.json) | Claude Code plugin の metadata と、安定版 25 skill の明示的な収録リスト。version は `1.2.3`。 |
| [`.claude-plugin/marketplace.json`](../../_repos/mattpocock_skills/.claude-plugin/marketplace.json) | repo 自身を単一 plugin marketplace として表す fallback metadata。公式 marketplace 経由が通常の導入経路。 |
| [`skills/engineering/`](../../_repos/mattpocock_skills/skills/engineering/) | コード作業用の安定版 skill と補助文書。 |
| [`skills/productivity/`](../../_repos/mattpocock_skills/skills/productivity/) | 非コード作業用の安定版 skill。 |
| [`skills/in-progress/`](../../_repos/mattpocock_skills/skills/in-progress/) | 公開 beta skill。 |
| [`skills/misc/`](../../_repos/mattpocock_skills/skills/misc/) | 非昇格の補助 skill。hook と migration などを含む。 |
| [`docs/engineering/`](../../_repos/mattpocock_skills/docs/engineering/) | engineering skill ごとの人間向け docs。skill の mirror で、公開 URL は `skills-<name>` 形式。 |
| [`docs/productivity/`](../../_repos/mattpocock_skills/docs/productivity/) | productivity skill ごとの人間向け docs。 |
| [`scripts/link-skills.sh`](../../_repos/mattpocock_skills/scripts/link-skills.sh) | `~/.claude/skills` と `~/.agents/skills` に skill directory の symlink を作る maintainer 用 script。`deprecated` と `misc` は除外し、`in-progress` は含める。 |
| [`scripts/list-skills.sh`](../../_repos/mattpocock_skills/scripts/list-skills.sh) | `SKILL.md` の全パスを列挙する script。 |
| [`scripts/sync-plugin-version.mjs`](../../_repos/mattpocock_skills/scripts/sync-plugin-version.mjs) | `package.json` の version を `plugin.json` に同期。`--check` は変更せず不一致なら終了コード 1。 |
| [`package.json`](../../_repos/mattpocock_skills/package.json) / [`package-lock.json`](../../_repos/mattpocock_skills/package-lock.json) | private npm package の version、Changesets、同期チェック、Node/npm の依存と lock。package manager は `npm@10.9.4`。 |
| [`.changeset/`](../../_repos/mattpocock_skills/.changeset/) | Changesets の変更記録と release 運用。 |
| [`.github/workflows/release.yml`](../../_repos/mattpocock_skills/.github/workflows/release.yml) | main push 時に Node 22、`npm ci`、Changesets action で version PR を作る release workflow。 |

## 導入・利用ワークフロー

### 利用者側

1. Claude Code では `claude plugins install mattpocock-skills` または session 内の `/plugin install mattpocock-skills` を使う。公式 marketplace に登録済みで、更新は自動到着すると README は説明する。
2. Codex とその他の agent では `npx skills@latest add mattpocock/skills` を実行し、導入する skill と対象 harness を選ぶ。engineering skill を使うなら `setup-matt-pocock-skills` を選ぶことが明示されている。
3. repo ごとに `/setup-matt-pocock-skills` を一度実行する。remote、既存の `AGENTS.md`/`CLAUDE.md`、domain docs、`.scratch` などを探索し、issue tracker、triage label、domain docs 配置を確認してから書き込む。
4. 通常の feature は `grill-with-docs` → 必要なら `prototype`/`handoff` → `to-spec` → `to-tickets` → `implement` → 内部の `tdd` → `code-review` という流れを取る。`ask-matt` がこの route を案内する。
5. 新規流入 issue は `triage`、難しい bug は `diagnosing-bugs`、複数 session にまたがる不確かな大規模作業は `wayfinder`、設計負債の探索は `improve-codebase-architecture` から入る。

### リポジトリ開発者側

- `scripts/link-skills.sh` はローカルの Claude Code/Codex 互換 skill directory に symlink を作る。既存の通常ディレクトリを同名 symlink に置き換える処理を含むため、maintainer 用であり supported installer ではない。
- skill の追加・改名・削除・挙動変更時は、`engineering`/`productivity` の docs、bucket README、トップ README の invocation 分類、`ask-matt` router、plugin manifest を同期する。`AGENTS.md` は manifest 変更後に `claude plugin validate . --strict` を実行するよう指示する。
- user-invoked skill は人間の明示的 invocation 専用で、model-invoked skill との依存は明示的な Skill tool 呼び出しとして記述する。ただし、別 skill から user-invoked skill を自動呼び出ししてはならない。

## 設定・配布・ハーネス連携

### 設定

`setup-matt-pocock-skills` は対象 repo の既存状態を見て次のファイルを生成・更新する設計である。

- `docs/agents/issue-tracker.md`: GitHub、GitLab、local Markdown、またはユーザー記述の tracker workflow。
- `docs/agents/triage-labels.md`: `needs-triage`、`needs-info`、`ready-for-agent`、`ready-for-human`、`wontfix` の canonical role と実際の label 名。
- `docs/agents/domain.md`: `CONTEXT.md`/`CONTEXT-MAP.md` と `docs/adr/` の読み方。
- `CLAUDE.md` があればそれを、なければ `AGENTS.md` を編集して `## Agent skills` block を挿入する。どちらもなければ作成先をユーザーに選ばせる。

hard dependency を持つ `triage`、`to-spec`、`to-tickets`、`wayfinder`、`code-review` などは tracker 設定を要求し、未設定なら人間に setup を促す。`CONTEXT.md` や ADR がない場合は、domain-modeling が必要になった時点まで黙って遅延作成する方針である。

### 配布

- Claude Code plugin: [`.claude-plugin/plugin.json`](../../_repos/mattpocock_skills/.claude-plugin/plugin.json) が stable bucket の 25 skill を個別 path で列挙する。`marketplace.json` は repo 自身を単一 plugin marketplace とする fallback である。
- skills.sh: repo 内の通常ファイルとして導入し、選択した skill を利用者が所有・編集する。`in-progress` は個別導入可能だが、`misc` と `deprecated` は開発者用 install script でも除外される。
- Codex: 2026-09-23 時点で native Codex plugin は roadmap 上であり、この repo の公式 plugin は Claude Code 向けである。skills.sh と `agents/openai.yaml` による互換を提供する設計と読める。

### Agent / hook 的な連携

agent の常駐実装やサーバーコードは確認できない。連携は skill 指示と sub-agent 委譲で実現する。`code-review` は Standards/Spec を並列 sub-agent に分け、`research` は background agent に調査を委譲し、`improve-codebase-architecture` は探索用 sub-agent を使う。`wayfinder` は research、prototype、grilling を ticket 種別として扱う。

明示的な hook 相当としては、非昇格の [`block-dangerous-git.sh`](../../_repos/mattpocock_skills/skills/misc/git-guardrails-claude-code/scripts/block-dangerous-git.sh) があり、`git push`、`git reset --hard`、`git clean`、強制 push などを Claude Code tool input の command から検出して exit 2 で拒否する。`diagnosing-bugs` には人間操作を含む再現用 [`hitl-loop.template.sh`](../../_repos/mattpocock_skills/skills/engineering/diagnosing-bugs/scripts/hitl-loop.template.sh) がある。

## テスト・検証方法

この repo 自体はアプリケーション実装ではなく、通常の unit/integration test suite、test runner、lint script は確認できなかった。`skills/engineering/tdd/tests.md` は利用者の repo に対する良い/悪いテストの指針であり、この repo の自動テストではない。

調査環境で実行・確認できた検証は次のとおりである。

| 検証 | 結果 |
| --- | --- |
| `npm run check-plugin-version` | 成功。`plugin.json version is 1.2.3 (already in sync)` |
| `bash scripts/list-skills.sh` | 38 件を列挙。Git 管理上の `SKILL.md` 数と一致。 |
| `plugin.json` の skill path と `engineering`/`productivity` ディレクトリの比較 | 25 対 25、missing/extra なし。 |
| `claude plugin validate . --strict` | `claude` CLI が調査環境に存在しなかったため未実行。AGENTS.md が要求する検証手段として記録のみ確認。 |

品質上の特徴は、bucket README、トップ README、plugin manifest、docs の同期を maintainer 規約として明文化している点、user/model invocation を二つの harness の metadata で二重に表現している点、install 文面を `install-block.md` に集約している点である。また、Changesets と GitHub Actions による version PR 作成を release path として持つ。

制約・残課題は以下である。

- 自動テストや lint/typecheck の repo 内 workflow がなく、SKILL.md の YAML、Markdown link、plugin discovery の全体整合性を一括検証する仕組みは確認できない。
- `claude plugin validate` は規約上重要だが、実行には Claude Code CLI が必要である。
- plugin は Claude Code 専用で、Codex native plugin は roadmap 上である。Codex/他ハーネスへの導入は skills.sh と個別 metadata に依存する。
- `in-progress` は公開されている一方で、変更・消滅の可能性が明記された beta であり、安定した依存先とはみなせない。
- 実行時の issue tracker や `docs/agents/*` は導入先 repo に生成されるため、このスナップショットだけから特定の利用 repo の実際の設定結果は判断できない。

## 参照した代表ファイル

- [トップ README](../../_repos/mattpocock_skills/README.md)
- [AGENTS.md](../../_repos/mattpocock_skills/AGENTS.md)
- [CONTEXT.md](../../_repos/mattpocock_skills/CONTEXT.md)
- [install-block.md](../../_repos/mattpocock_skills/.agents/install-block.md)
- [invocation.md](../../_repos/mattpocock_skills/.agents/invocation.md)
- [ADR 0002: Claude Code plugin として配布する判断](../../_repos/mattpocock_skills/.agents/adr/0002-ship-as-a-claude-code-plugin.md)
- [package.json](../../_repos/mattpocock_skills/package.json)
- [plugin.json](../../_repos/mattpocock_skills/.claude-plugin/plugin.json)
- [release workflow](../../_repos/mattpocock_skills/.github/workflows/release.yml)
- [engineering bucket README](../../_repos/mattpocock_skills/skills/engineering/README.md)
- [productivity bucket README](../../_repos/mattpocock_skills/skills/productivity/README.md)
- [setup skill](../../_repos/mattpocock_skills/skills/engineering/setup-matt-pocock-skills/SKILL.md)
- [ask-matt router](../../_repos/mattpocock_skills/skills/engineering/ask-matt/SKILL.md)
- [code-review skill](../../_repos/mattpocock_skills/skills/engineering/code-review/SKILL.md)
- [diagnosing-bugs skill](../../_repos/mattpocock_skills/skills/engineering/diagnosing-bugs/SKILL.md)
- [tdd test guidance](../../_repos/mattpocock_skills/skills/engineering/tdd/tests.md)
- [link-skills.sh](../../_repos/mattpocock_skills/scripts/link-skills.sh)
- [sync-plugin-version.mjs](../../_repos/mattpocock_skills/scripts/sync-plugin-version.mjs)

## 調査範囲と未確認事項

確認範囲は、source repo の `AGENTS.md`、`README.md`、`CLAUDE.md`、`CONTEXT.md`、`package.json`、lockfile の存在、plugin manifests、release workflow、Changesets、全 Git 管理ファイル一覧、全 `SKILL.md` の front matter と bucket README、主要 skill 本文、実行・検証 script、hook template である。

外部ネットワークから upstream の最新状態を再取得したか、各 skill を Claude Code/Codex の実環境で実行したか、公式 marketplace の現在の登録状態が HEAD と一致するかは、この調査では確認していない。したがって、導入コマンドの実サービス上の可用性、全 harness での実行互換性、未実行の strict plugin validation の結果は断定しない。

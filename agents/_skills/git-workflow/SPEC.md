# Git ワークフローの契約と設計根拠

このファイルは git-workflow skill の操作範囲、確認基準、外部影響の扱いを定義する保守契約です。参考資料、採用内容、自分用の調整、履歴上の経緯もここで管理します。取得した参照リポジトリは実行時依存ではありません。

## 適用範囲

対象は、ユーザーが依頼した次の Git 操作と、その前後の読み取り専用の確認です。

- ブランチの作成、切り替え、削除
- linked worktree の作成、確認、削除
- staged・unstaged・未追跡の変更確認とコミット
- merge、rebase、merge conflict の確認・解消
- push、PR、release などの外部操作
- tag、ローカル merge などの履歴・作業ツリー操作

操作前に対象範囲、比較元、生成される履歴、未コミット変更への影響を確認し、操作後に状態、差分、履歴、必要な検証結果を確認します。

## 操作の契約

- ユーザーが明示していない commit、branch、merge、tag、push、PR、release などの状態変更を実行しない。
- base や比較元は `main`・`master` と決め打ちせず、解決した参照名と SHA を記録する。
- staged・unstaged・未追跡の変更を分け、意図しない変更を操作対象へ含めない。
- worktree の作成・削除では、既存の worktree、未コミット変更、未追跡ファイル、配置先の衝突を確認する。
- merge conflict は `ours`・`theirs` の機械的な採用を避け、両側の意図と hunk ごとの整合性を確認する。
- 破壊的な操作や履歴書き換えは、対象、影響、復旧方法を確認せずに実行しない。
- 操作完了時は、変更ファイル、branch、commit、worktree、検証結果、外部操作、未確認事項を報告する。

## 対象外

- ユーザーの依頼に含まれない外部サービスやリモートリポジトリの変更
- `reset --hard`、`clean`、force push、未 merge branch の強制削除などの自動実行
- 変更内容と関係のないファイル、履歴、作業ツリーの整理
- 特定のホスティングサービス、GitHub CLI、課題管理ツール、ブランチ命名規則の必須化
- プロジェクトが採用していない release 手順、version、changelog、成果物の一律確認

## 参考資料と採用内容

| 参考資料 | リビジョン | 参照したパス | 取り入れた内容 |
| --- | --- | --- | --- |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills/blob/dc27a9c2e13721158157632de61b4106c6c2a2a1/skills/git-workflow-and-versioning/SKILL.md) | `dc27a9c2e13721158157632de61b4106c6c2a2a1` | `skills/git-workflow-and-versioning/SKILL.md` | commit を保存点、branch を隔離領域、history を記録として扱う考え方、atomic commit、worktree、release の確認観点 |
| [mattpocock/skills](https://github.com/mattpocock/skills/blob/c55ee46073ed923f86ce59a5eb3b6d895095d1b7/docs/engineering/resolving-merge-conflicts.md) | `c55ee46073ed923f86ce59a5eb3b6d895095d1b7` | `docs/engineering/resolving-merge-conflicts.md` | 競合をテキストの問題だけとして扱わず、commit・PR・issue の意図を確認し、hunk ごとに検証する考え方 |
| [obra/superpowers](https://github.com/obra/superpowers/tree/5bf4e78011075bcfc0dc295f0724994cd123ee71/skills) | `5bf4e78011075bcfc0dc295f0724994cd123ee71` | `skills/using-git-worktrees/SKILL.md`、`skills/finishing-a-development-branch/SKILL.md` | linked worktree の検出、作業分離、project-local worktree の安全確認、merge・PR・cleanup の扱い |
| [getsentry/skills](https://github.com/getsentry/skills/tree/c2f99a5b04b4cd992ec3022d7c2c3e23e938d241/skills) | `c2f99a5b04b4cd992ec3022d7c2c3e23e938d241` | `skills/create-branch/SKILL.md`、`skills/commit/SKILL.md` | base branch の解決、branch 名の衝突確認、staged diff と検証を確認してから commit する考え方 |

## このリポジトリ向けの調整

- commit、branch、merge、tag、push、PR、release など、ローカル履歴・作業ツリーまたは外部状態を変える操作は、ユーザーの明示的な依頼なしに実行しない。
- Sentry 固有の branch 命名、issue reference、GitHub CLI、課題管理ツール、特定のホスティングサービスは必須にせず、リポジトリの規約がある場合だけ従う。
- `reset --hard`、`clean`、force push、未 merge branch の強制削除、未確認の worktree cleanup を自動化せず、対象・影響・復旧方法を確認する。
- staged・unstaged・未追跡の変更を分けて扱い、PR や release の比較元は解決した SHA として記録する。
- worktree は project-local 配置の ignore を確認しつつ、ユーザーが明示したリポジトリ外の配置先を ignore の有無だけで拒否しない。
- release の version、tag、changelog、成果物の確認は、対象プロジェクトがその運用を採用している場合だけ行う。

Git 履歴上、この skill は 2026-09-29 のコミット `8275484c` で追加され、2026-10-01 のコミット `f3b9a25` で現在の `agents/_skills/` 配下へ移動されています。上表は今回整理した設計根拠の記録であり、元の追加コミットに残っていた厳密な著作・出典記録ではありません。

## 維持・改善

`SKILL.md` の方針、参考資料のリビジョン、採用・不採用の判断を変更した場合は、この SPEC を同期します。実際の利用で誤操作、見逃し、過剰な確認が見つかった場合は、発生条件と検証結果を追記して手順を調整します。

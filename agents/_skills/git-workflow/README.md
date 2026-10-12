# Git ワークフロー

ブランチ、作業ツリー、コミット、PR、競合解消などの Git 操作を安全に進める skill です。実行入口は [SKILL.md](./SKILL.md) です。

## 目次

| パス | 役割 |
| --- | --- |
| [SKILL.md](./SKILL.md) | Git の範囲確認、branch・worktree・履歴操作、外部操作、競合解消、破壊的操作の手順 |

## 利用例

~~~text
$git-workflow この変更だけをコミットできる状態に整理し、staged diff と検証結果を確認してください。コミットはまだ作成しないでください。
~~~

push、PR、release など外部状態を変更する操作と、merge、tag などローカルの履歴や作業ツリーを変更する操作は、明示的に依頼された場合だけ行います。

## 参考資料と自分用の調整

以下は、この skill の設計・改善時に参照した資料と、そこから取り入れた考え方です。参考リポジトリは実行時依存ではありません。元の skill が追加された時点で、これらの資料が明示的な出典として記録されていたことを示すものではありません。

| 参考資料 | リビジョン | 参照したパス | 取り入れた内容 |
| --- | --- | --- | --- |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills/blob/dc27a9c2e13721158157632de61b4106c6c2a2a1/skills/git-workflow-and-versioning/SKILL.md) | `dc27a9c2e13721158157632de61b4106c6c2a2a1` | `skills/git-workflow-and-versioning/SKILL.md` | commit を保存点、branch を隔離領域、history を記録として扱う考え方、atomic commit、worktree、release の確認観点 |
| [mattpocock/skills](https://github.com/mattpocock/skills/blob/c55ee46073ed923f86ce59a5eb3b6d895095d1b7/docs/engineering/resolving-merge-conflicts.md) | `c55ee46073ed923f86ce59a5eb3b6d895095d1b7` | `docs/engineering/resolving-merge-conflicts.md` | 競合をテキストの問題だけとして扱わず、commit・PR・issue の意図を確認し、hunk ごとに検証する考え方 |
| [obra/superpowers](https://github.com/obra/superpowers/tree/5bf4e78011075bcfc0dc295f0724994cd123ee71/skills) | `5bf4e78011075bcfc0dc295f0724994cd123ee71` | `skills/using-git-worktrees/SKILL.md`、`skills/finishing-a-development-branch/SKILL.md` | linked worktree の検出、作業分離、project-local worktree の安全確認、merge・PR・cleanup の扱い |
| [getsentry/skills](https://github.com/getsentry/skills/tree/c2f99a5b04b4cd992ec3022d7c2c3e23e938d241/skills) | `c2f99a5b04b4cd992ec3022d7c2c3e23e938d241` | `skills/create-branch/SKILL.md`、`skills/commit/SKILL.md` | base branch の解決、branch 名の衝突確認、staged diff と検証を確認してから commit する考え方 |

### このリポジトリ向けの調整

- commit、branch、merge、tag、push、PR、release など、ローカル履歴・作業ツリーまたは外部状態を変える操作は、ユーザーの明示的な依頼なしに実行しない。
- Sentry 固有の branch 命名、issue reference、GitHub CLI、課題管理ツール、特定のホスティングサービスは必須にせず、リポジトリの規約がある場合だけ従う。
- `reset --hard`、`clean`、force push、未 merge branch の強制削除、未確認の worktree cleanup を自動化せず、対象・影響・復旧方法を確認する。
- staged・unstaged・未追跡の変更を分けて扱い、PR や release の比較元は解決した SHA として記録する。
- worktree は project-local 配置の ignore を確認しつつ、ユーザーが明示したリポジトリ外の配置先を ignore の有無だけで拒否しない。
- release の version、tag、changelog、成果物の確認は、対象プロジェクトがその運用を採用している場合だけ行う。

Git 履歴上、この skill は 2026-09-29 のコミット `8275484c` で追加され、2026-10-01 のコミット `f3b9a25` で現在の `agents/_skills/` 配下へ移動されています。上表は今回整理した設計根拠の記録であり、元の追加コミットに残っていた厳密な著作・出典記録ではありません。

## 維持・改善

`SKILL.md` の方針、参考資料のリビジョン、採用・不採用の判断を変更した場合は、この節も同期します。実際の利用で誤操作、見逃し、過剰な確認が見つかった場合は、発生条件と検証結果を追記して手順を調整します。

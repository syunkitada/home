# 実装スキルの契約と設計根拠

このファイルは implementation skill の適用範囲、変更の契約、検証方針、設計根拠を定義する保守契約です。実行時の詳細手順は [SKILL.md](./SKILL.md) に記載します。

## 適用範囲

対象は、ユーザーが仕様、チケット、または明示された要件に基づいて依頼した次の変更です。

- コード、設定、ドキュメントの追加・変更
- 変更に伴う README、Index、ファイル一覧、相対リンクの同期
- 必要なテスト、lint、型検査、build などの更新と実行
- 変更範囲、検証結果、未確認事項の完了報告

## 変更の契約

- 変更前に要件、適用される `AGENTS.md`、README、仕様、既存の利用経路、関連テストを確認する。
- 既存の命名、エラー処理、設定、データ形式、依存関係を維持し、要件に必要な範囲だけを変更する。
- 複数段階の作業や要件が曖昧な場合は、実装前に受け入れ条件と検証方法を計画へ分解する。
- 複数ファイルの変更は、独立して検証できる最小の実装単位へ分け、各単位で検証する。
- ファイルやディレクトリの構成を変更した場合は、関係する README、Index、相対リンクを同じ変更で同期する。
- 挙動を変更する場合は、変更経路に応じて TDD の RED、GREEN、REFACTOR または同等の回帰検証を行う。文書・静的設定だけの変更では構造確認を行う。
- 完了を主張する前に、実行結果、差分、作業ツリー、未確認事項を確認する。
- 実装依頼だけでは commit、push、branch、PR を作成しない。必要な Git 操作は明示的な依頼後に `git-workflow` へ分ける。

## 対象外

- レビューだけを目的とした依頼。レビューは `code-review` を使う。
- 原因究明だけを目的とした依頼。再現、切り分け、根本原因の確認を優先し、診断だけでは修正しない。
- 要件と関係のない既存問題の全面的な修正や整理。
- 対象、影響、復旧方法を確認しない破壊的な削除、reset、履歴書き換え。

## 参考資料と採用内容

この skill の設計根拠として、外部skillの内容を照合し、リポジトリ内の既存skill・規約へ調整しています。参考リポジトリは実行時依存ではありません。

### 外部参考資料

| 参考資料 | リビジョン | 参照したパス | 取り入れた内容と調整 |
| --- | --- | --- | --- |
| [mattpocock/skills](https://github.com/mattpocock/skills/tree/c55ee46073ed923f86ce59a5eb3b6d895095d1b7) | `c55ee46073ed923f86ce59a5eb3b6d895095d1b7` | `skills/engineering/implement/SKILL.md` | spec・ticket起点、TDD、型検査、テスト、レビューの流れを採用。自動commitと自動reviewはこのリポジトリの明示依頼ルールに合わせて分離 |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills/tree/dc27a9c2e13721158157632de61b4106c6c2a2a1) | `dc27a9c2e13721158157632de61b4106c6c2a2a1` | `skills/incremental-implementation/SKILL.md` | 小さな検証可能な単位、実装・テスト・検証の反復、スコープ規律を採用。各単位のcommitは必須にせずGit操作を分離 |
| [obra/superpowers](https://github.com/obra/superpowers/tree/5bf4e78011075bcfc0dc295f0724994cd123ee71/skills) | `5bf4e78011075bcfc0dc295f0724994cd123ee71` | `skills/verification-before-completion/SKILL.md`、`skills/test-driven-development/SKILL.md` | 新しい検証結果を根拠に完了を報告する方針と、RED、GREEN、REFACTORを採用。厳格なTDDは文書・静的設定へ一律適用しない |

### リポジトリ内の参考資料

| 参考資料 | 参照した内容 | 採用した内容 |
| --- | --- | --- |
| [リポジトリガイドライン](../../../AGENTS.md) | READMEの役割、Index、相対リンク、構成変更時の同期 | 構成変更を実装の責務に含め、READMEを同じ変更で更新する |
| [skill directory guidelines](../AGENTS.md) | README、SKILL、SPECの役割と参考資料の管理 | 実行手順と保守契約を分離し、設計根拠をSPECに記録する |
| [task-planning/SKILL.md](../task-planning/SKILL.md) | 曖昧な要件や複数段階の作業を計画へ分解する契約 | 実装前に受け入れ条件、検証方法、リスクを整理する |
| [tdd/SKILL.md](../tdd/SKILL.md) | 挙動変更時のRED、GREEN、REFACTORとテスト方法の発見 | 挙動変更へTDDを適用し、文書・静的設定は構造確認に切り替える |
| [verification/SKILL.md](../verification/SKILL.md) | 完了前の要件、テスト、差分、未確認事項の確認 | 新しい実行結果を読んでから完了を報告する |
| [code-review/SKILL.md](../code-review/SKILL.md) | レビューと実装・修正の分離 | レビュー依頼だけでは実装を変更せず、必要時に別工程で使う |
| [git-workflow/SKILL.md](../git-workflow/SKILL.md) | commit、push、branch、PRなどの安全な扱い | 実装とGitの履歴・外部操作を分離する |

この一覧は内容を照合して整理した設計根拠です。`implementation` の初出コミット `f3b9a25` に、これらの出典が明示的に記録されていたことを示すものではありません。

## 維持・改善

`SKILL.md` の発動条件、手順、境界、検証方針を変更した場合は、この SPEC と README を同じ変更で更新します。実際の利用で過剰な変更、検証漏れ、構成説明の更新漏れが見つかった場合は、発生条件と対応方針を追記します。

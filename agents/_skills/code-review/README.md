# コードレビュー

変更の仕様適合性と不具合・回帰を確認する、自分用のコードレビュースキルです。言語やフレームワークを限定せず、対象プロジェクトの仕様と運用前提に合わせて評価します。実行入口は SKILL.md、保守契約は SPEC.md です。

## 目次

| パス | 役割 |
| --- | --- |
| [SKILL.md](./SKILL.md) | 対象差分の特定、影響範囲の確認、指摘の検証、結果の報告を行う実行入口 |
| [SPEC.md](./SPEC.md) | 対象範囲、非対象、証拠基準、出力形式の保守契約 |
| [SOURCES.md](./SOURCES.md) | 参考スキルのリビジョン、採用内容、自分用の調整、未解決の評価課題 |
| [references/](./references/README.md) | 対象選択、確認観点、検証、報告形式の詳細手順 |

## 利用例

このリポジトリ内の正本を直接指定する場合は、次のように依頼します。

~~~text
同ディレクトリの [`SKILL.md`](./SKILL.md) を使って、未コミットの変更をレビューしてください。
ステージ済み・未ステージ・未追跡の変更を含め、修正はせずに問題点を報告してください。
~~~

./scripts/setup.sh skills で ~/.agents/skills/code-review へ配置した後は、次のように呼び出せます。

~~~text
$code-review origin/main から現在のブランチまでの変更をレビューしてください。
要件は docs/spec.md にあります。後方互換性への影響を重点的に確認してください。
~~~

~~~text
$code-review ステージ済みの変更だけをレビューしてください。
同じファイルの未ステージ変更は対象外です。
~~~

指摘には重要度、確信度、場所、発生条件、影響、根拠を含めます。指摘がない場合も対象範囲と検証状況を報告します。通常の実装依頼で、レビューだけに作業を切り替えるためのスキルではありません。

## 参考資料と自分用の調整

参考にしたリビジョンと採用・不採用の判断は SOURCES.md に集約しています。参考リポジトリを取得していなくても、本スキル単体で利用できます。

| 参考資料 | 取り入れた考え方 |
| --- | --- |
| [mattpocock/skills の code-review](https://github.com/mattpocock/skills/blob/c55ee46073ed923f86ce59a5eb3b6d895095d1b7/skills/engineering/code-review/SKILL.md) | 比較元を固定し、仕様とリポジトリ規約の両方を確認する |
| [getsentry/skills の code-review](https://github.com/getsentry/skills/blob/c2f99a5b04b4cd992ec3022d7c2c3e23e938d241/skills/code-review/SKILL.md) | 正しさ、互換性、安全性、性能、テストを変更に応じて確認する |
| [addyosmani/agent-skills の code-review-and-quality](https://github.com/addyosmani/agent-skills/blob/dc27a9c2e13721158157632de61b4106c6c2a2a1/skills/code-review-and-quality/SKILL.md) | 多軸評価と構造上の問題を確認する |
| [obra/superpowers の receiving-code-review](https://github.com/obra/superpowers/blob/5bf4e78011075bcfc0dc295f0724994cd123ee71/skills/receiving-code-review/SKILL.md) | 指摘を検証してから修正へ進む |

自分用の調整点は、作業ツリー・index・コミットを区別すること、既存の利用経路から指摘を検証すること、特定の課題管理ツールや並列サブエージェントを必須にしないことです。仕様の不足だけでレビューを止めず、確認できる範囲を調べます。

## 維持・改善

発動条件、対象範囲、証拠基準、出力形式を変更した場合は SPEC.md と SOURCES.md も更新します。実際の誤検出・見逃し・改善例が蓄積した時点で、references/evidence/ に作業用集合と保留検証集合を追加します。

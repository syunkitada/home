# japanese-writing の構成と保守契約

このファイルは、`japanese-writing` の適用範囲、設計判断、参考資料、保守方針を定義します。実行時の手順は [SKILL.md](./SKILL.md)、利用者向けの入口は [README.md](./README.md) に記載します。

## 適用範囲

対象は、日本語で次の文章を新規作成または編集する依頼です。

- 技術説明、README、設計説明、使い方、トラブルシュート
- プロダクト、機能、仕様、利用価値の説明
- Confluence、Wiki、社内ナレッジ、議事録、手順書
- Slackの依頼、報告、相談、決定事項、告知

文章の読みやすさ、構成、用語、文体を扱います。事実確認そのもの、コードや設定の変更、リンク修正、文書の作業計画、ConfluenceやSlackへの投稿は対象外です。必要に応じて、既存の `task-planning`、`implementation`、`verification` と組み合わせます。

## 公開インターフェース

| 項目 | 契約 |
| --- | --- |
| skill名 | `japanese-writing` |
| 自動発動 | 日本語文章の作成・編集依頼に対して許可する |
| 任意モード | `write`、`edit` |
| 任意の形式 | `technical`、`product`、`wiki`、`slack` |
| 省略時 | 依頼内容、素材、出力先から作成・編集と形式を判定する |
| 外部依存 | なし。外部リポジトリは設計資料としてのみ参照する |

## 設計判断

### 意味保持を最上位に置く

読みやすさの改善より、主張、比重、確信度、文の働きの保持を優先します。元の情報にない事実、数値、条件、担当者、期限、効果、意見、専門用語は追加しません。新規作成でも、ユーザーの素材または確認済みの情報源に基づいて書きます。

### 形式別の判断を分離する

技術説明、プロダクト説明、Wiki、Slackでは、必要な情報の順序と適切な密度が異なります。共通原則を `SKILL.md` と `references/principles.md` に置き、形式別の判断は `references/formats/` に分離します。これにより、Slack向けの簡潔さを技術文書へ機械的に適用することを防ぎます。

### 機械的な禁止規則を初版へ入れない

太字、箇条書き、括弧、専門用語、文長には、文脈上必要な場合があります。初版では禁止語リンターを追加せず、情報源と読者を確認した自己点検を採用します。繰り返し発生する誤りが確認できた場合だけ、誤検出と例外を含めて機械検査を検討します。

### 外部資料は設計根拠として扱う

外部 skill の本文、コード、テスト、ライセンス文をこの skill の実行時資材としてコピーしません。参照した原則をこのリポジトリの規約と用途へ合わせて再構成します。

## 参考資料と採用内容

参考資料は実行時依存ではありません。リビジョンは参照時点の HEAD を記録しています。

| 参考資料 | リビジョン | 参照箇所 | 採用した内容 |
| --- | --- | --- | --- |
| [`nanaism/yomiyasu`](https://github.com/nanaism/yomiyasu) | `b14ee43c9b722cf4fd2bb1e893c6c386f1a362aa` | ローカルスナップショットの `SKILL.md`、`references/gemini-syntax.md`、ドメイン別資料 | 主張・比重・確信度・文の働きの保持、主述関係の明確化、情報の不増補、文脈に応じた比喩・専門用語の扱い |
| [`coji/natural-japanese`](https://github.com/coji/natural-japanese)<br>[調査ノート](../../_scrapes/_repo_notes/coji_natural-japanese/README.md) | `03bc944a0c4a9f0b2a66eab065b30de5c529bf08` | `skills/natural-japanese/SKILL.md` | 元にない事実・数値・意見を足さないこと、読者と目的を先に決めること、見出しと構成の点検 |
| [`seb1n/awesome-ai-agent-skills`](https://github.com/seb1n/awesome-ai-agent-skills)<br>[調査ノート](../../_scrapes/_repo_notes/seb1n_awesome-ai-agent-skills/README.md) | `75865a5d037a4cdaa7f409a4ec14ab9b0292920b` | `writing-and-content/technical-writing/SKILL.md` | 文書種別、読者、素材、構成、ナビゲーション、正確性を確認する流れ |
| [`riekelt/technical-writer`](https://github.com/riekelt/technical-writer)<br>[調査ノート](../../_scrapes/_repo_notes/riekelt_technical-writer/README.md) | `85e53729dd959a2795d593d6769068e342cf3486` | `plugins/technical-writer/skills/technical-writing/SKILL.md` | 作成前に種別・読者・目的・対象外を整理すること、情報源を一元化すること、文書種別ごとに詳細方針を分けること |

上記のうち `nanaism/yomiyasu` の調査ノートは [`agents/_scrapes/_repo_notes/nanaism_yomiyasu/README.md`](../../_scrapes/_repo_notes/nanaism_yomiyasu/README.md) に保存されています。`_scrapes/_repos/` は参照用キャッシュであり、この skill の実行時に読み込むことを要求しません。

## 構成

| パス | 役割 |
| --- | --- |
| [SKILL.md](./SKILL.md) | 発動条件、共通ワークフロー、意味保持、出力方針 |
| [README.md](./README.md) | 利用者向けの概要、Index、利用例 |
| [references/](./references/) | 共通原則、形式別ガイド、最終確認 |
| [references/principles.md](./references/principles.md) | 日本語の読みやすさと意味保持の詳細 |
| [references/formats/](./references/formats/) | 技術、プロダクト、Wiki、Slackの形式別方針 |
| [references/review.md](./references/review.md) | 出力前の確認項目 |

## 保守方針

- `SKILL.md` の発動条件、共通手順、出力契約を変更した場合は `README.md` とこの `SPEC.md` を同期する。
- 形式別の方針を変更した場合は、`references/formats/README.md`、該当資料、この `SPEC.md` の適用範囲を確認する。
- 外部資料を追加・更新した場合は、URL、参照リビジョン、参照箇所、採用内容をこの `SPEC.md` に記録する。
- 新しい形式を追加する場合は、共通原則で扱うべきか、形式別参照資料が必要かを決め、READMEのIndexと相対リンクを同期する。
- 外部 skill の更新を取り込むときは、本文のコピーではなく、目的、意味保持、誤検出、既存文書規約への影響を確認する。

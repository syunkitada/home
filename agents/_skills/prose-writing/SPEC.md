# prose-writing の構成と保守契約

このファイルは `prose-writing` の適用範囲、設計判断、参考資料、保守方針を定義します。実行時の手順は [SKILL.md](./SKILL.md)、利用者向けの入口は [README.md](./README.md) に記載します。

## 適用範囲

自然言語で人が読む文章・文書の新規作成、編集、翻訳、要約、推敲を扱います。対象にはMarkdown文書、文書内のMermaid図、技術・プロダクト説明、Wiki、Slack投稿を含みます。アプリケーションコード、設定、一般的な構造化データ、エージェント用指示の作成は対象外です。

事実確認自体やリポジトリ内の文書ファイル変更は、必要に応じて `task-planning`、`implementation`、`verification` と組み合わせます。コードベース全体を分析して依存グラフに沿った文書一式を生成することは、このskillの初版には含めません。

## 公開インターフェース

| 項目 | 契約 |
| --- | --- |
| skill名 | `prose-writing` |
| 自動発動 | 自然言語の文章・文書を作成、編集、翻訳、要約、推敲する依頼に対して許可する |
| 対象外 | コード、設定、構造化データ、エージェント用指示の作成 |
| 任意モード | `write`、`edit`、`translate`、`summarize`、`polish` |
| 任意の形式 | `technical`、`product`、`wiki`、`slack`、`markdown`、`mermaid` |
| 省略時 | 依頼、素材、出力先、既存文書から言語・操作・形式を判定する |
| 外部依存 | なし。外部リポジトリは設計資料としてのみ参照する |

## 設計判断

### 媒体を横断する文章作成skillとする

既存の技術説明、プロダクト説明、Wiki、Slackのガイドを維持し、Markdown文書の構造・リンク・コード例・表・図表の扱いを追加します。文書内のMermaid図も、内容を説明する図表として扱います。Markdownだけに限定せず、文章作成だけに対象を絞ることで、アプリケーションコードを書くskillとの発動範囲を区別します。

### 共通原則と言語固有の指針を分ける

読者と目的、情報源、意味保持、構成の原則は言語に依存しないものとして扱います。日本語の文構造や文体の注意点は `references/languages/japanese.md` に分け、他言語へ誤適用しないようにします。初版で言語別ガイドを網羅することは求めません。

### 文書の固有規約を優先する

Markdownでも、ADR、変更履歴、skill manifest、エージェント指示、ライセンスなどは固有の形式や外部規約を持つ場合があります。一般的な文体・書式ルールで上書きせず、依頼された文章部分を文書の役割を保って扱います。READMEの節順、Mermaid、バッジ、パスのリンク化などを全プロジェクトに機械的に要求しません。

### 根拠のない情報を加えない

新規作成・編集とも、素材または確認済みの情報源を根拠にします。技術文書は実装・設定・仕様と照合し、既存文書の記述をそのまま事実として引き継ぎません。未確認の情報は本文で断定せず、必要に応じて確認事項または前提として分けます。

## 参考資料と採用内容

参照元全体は [`agents/_scrapes/`](../../_scrapes/README.md) に取得・lockしています。外部skillは実行時依存ではなく、内容をこのリポジトリの用途へ再構成しています。

| 参考資料 | リビジョン | 参照箇所 | 採用した内容 |
| --- | --- | --- | --- |
| [`khasky/awesome-agent-skills`](https://github.com/khasky/awesome-agent-skills/tree/58ea4e8915de64907d04cc909a1b8c6e5cf0fcb7)<br>[調査ノート](../../_scrapes/_repo_notes/khasky_awesome-agent-skills/README.md) | `58ea4e8915de64907d04cc909a1b8c6e5cf0fcb7` | `skills/awesome-code-docs/SKILL.md`、`references/source-and-graph.md`、`references/doc-set.md` | 技術文書の主張を実装・設定などの根拠へ結び付けること、既存文書とコードの食い違いを確認すること。依存グラフに沿った一式生成、網羅的API資料、専用出力階層は初版には採用しない。 |
| [`Lukk17/agent-standards`](https://github.com/Lukk17/agent-standards/tree/fa85e2536eaea4c76eac54ce4e63bd47ba70bf34)<br>[調査ノート](../../_scrapes/_repo_notes/lukk17_agent-standards/README.md) | `fa85e2536eaea4c76eac54ce4e63bd47ba70bf34` | `.agents/skills/markdown-writer/SKILL.md`、`references/readme-and-voice.md`、`references/formatting-rules.md`、`references/multilingual.md` | Markdownが人向けか機械向けかを見分けること、事実をリポジトリから確認すること、リンク・アンカー・翻訳の対応を点検すること。固定の節順、禁止ダッシュ、常時の図表・バッジ・文書マップは採用しない。 |
| [`mitch-avis/agent-skills`](https://github.com/mitch-avis/agent-skills/tree/ce7b8d00d2825ce4044ddf020c3bbe9bb10a662a/mermaid)<br>[調査ノート](../../_scrapes/_repo_notes/mitch-avis_agent-skills/README.md) | `ce7b8d00d2825ce4044ddf020c3bbe9bb10a662a` | `mermaid/SKILL.md`、`mermaid/references/` | 図種の選び分け、Flowchart・Sequence・ER・Class・State・C4などの構文例、よくある構文エラー、レンダラー上での確認を採用。レンダリングスクリプト、依存関係、テーマの詳細、環境固有の強い制限は持ち込まない。記法の正確性は公式Mermaidドキュメントを参照する。 |
| [`nanaism/yomiyasu`](https://github.com/nanaism/yomiyasu)<br>[調査ノート](../../_scrapes/_repo_notes/nanaism_yomiyasu/README.md) | `b14ee43c9b722cf4fd2bb1e893c6c386f1a362aa` | ローカルスナップショットの `SKILL.md`、参照資料 | 主張・比重・確信度・文の働きの保持、主述関係の明確化、情報の不増補。 |
| [`coji/natural-japanese`](https://github.com/coji/natural-japanese)<br>[調査ノート](../../_scrapes/_repo_notes/coji_natural-japanese/README.md) | `03bc944a0c4a9f0b2a66eab065b30de5c529bf08` | `skills/natural-japanese/SKILL.md` | 素材にない事実や意見を足さないこと、読者と目的を先に定めること。 |
| [`seb1n/awesome-ai-agent-skills`](https://github.com/seb1n/awesome-ai-agent-skills)<br>[調査ノート](../../_scrapes/_repo_notes/seb1n_awesome-ai-agent-skills/README.md) | `75865a5d037a4cdaa7f409a4ec14ab9b0292920b` | `writing-and-content/technical-writing/SKILL.md` | 文書種別、読者、素材、構成、ナビゲーション、正確性を確認する流れ。 |
| [`riekelt/technical-writer`](https://github.com/riekelt/technical-writer)<br>[調査ノート](../../_scrapes/_repo_notes/riekelt_technical-writer/README.md) | `85e53729dd959a2795d593d6769068e342cf3486` | `plugins/technical-writer/skills/technical-writing/SKILL.md` | 文書種別・読者・目的・対象外の整理、情報源の確認、形式別指針の分離。 |

## 構成

| パス | 役割 |
| --- | --- |
| [SKILL.md](./SKILL.md) | 発動条件、共通手順、出力方針 |
| [README.md](./README.md) | 利用者向け概要、Index、利用例 |
| [references/](./references/README.md) | 共通原則、形式別・言語別ガイド、最終確認 |
| [references/formats/](./references/formats/README.md) | 技術、プロダクト、Wiki、Slack、Markdownの形式別方針 |
| [references/diagrams/](./references/diagrams/README.md) | Mermaid図の種類、構文、作成・確認手順 |
| [references/languages/](./references/languages/README.md) | 言語固有の注意点 |

## 保守方針

- 発動条件、共通手順、出力契約を変更した場合は `README.md` とこの `SPEC.md` を同期する。
- 形式別の方針を変更した場合は、該当資料、`references/formats/README.md`、この `SPEC.md` を確認する。
- 言語別資料を追加・変更した場合は、`references/languages/README.md` とこの `SPEC.md` の適用範囲を確認する。
- 外部資料を追加・更新した場合は、取得元リポジトリ全体、URL、参照コミット、調査ノート、参照箇所、採用内容を記録する。既存の無関係なlockは更新しない。
- Markdown方針を追加するときは、一般的な書式の好みを強制規則にせず、対象ホスト、プロジェクト慣例、読者の用途、誤検出を考慮する。
- Mermaidの図種・構文情報はバージョンとレンダラーで差が出るため、外部skillの記述を唯一の仕様とせず、公式資料と対象環境で確認する。

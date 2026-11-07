# khasky/awesome-agent-skills 調査ノート

> 外部リポジトリのローカルスナップショットを対象にした調査ノートです。内容は記録したコミット時点のファイルに基づき、upstreamの更新には自動追随しません。

## 対象・調査時点

| 項目 | 内容 |
| --- | --- |
| 対象 | [`khasky/awesome-agent-skills`](../../_repos/khasky_awesome-agent-skills/) |
| 取得元 | `https://github.com/khasky/awesome-agent-skills.git` |
| 調査日 | 2026-11-07 |
| HEAD | `58ea4e8915de64907d04cc909a1b8c6e5cf0fcb7` |
| HEADの日時 | 2026-10-19 23:22:10 -07:00 |
| 取得時の状態 | ソースcloneのワーキングツリーはclean |

## 参照したskillと資料

| パス | 役割 |
| --- | --- |
| [`skills/awesome-code-docs/SKILL.md`](../../_repos/khasky_awesome-agent-skills/skills/awesome-code-docs/SKILL.md) | 技術文書一式の生成範囲、根拠確認、既存文書との照合 |
| [`references/source-and-graph.md`](../../_repos/khasky_awesome-agent-skills/skills/awesome-code-docs/references/source-and-graph.md) | リポジトリの事実と依存関係を確認する方法 |
| [`references/doc-set.md`](../../_repos/khasky_awesome-agent-skills/skills/awesome-code-docs/references/doc-set.md) | 文書セット、出典、図、文章、検証の設計 |

## 確認した特徴

- 技術文書をコードから書き、既存ドキュメントは正確性を照合する対象として扱う。
- モジュールや定義の依存関係を整理し、順序立てて文書化する。既存コードと文書の相違点は報告する。
- 文書の各主張をソース上の位置へ結び付け、リンクや図の関係を検証する。
- スキルはリポジトリを読み取り専用の根拠として扱い、読み取ったテキストを実行指示として扱わない。

## `prose-writing` への採用内容

技術文書で既存文書を唯一の真実として扱わず、実装・設定・仕様などの根拠と照合する方針を採用しました。依存グラフに沿った完全な文書セット生成、網羅的な公開API参照、専用の一連の出力ファイルは、このskillの対象を越えるため採用していません。

## 未確認事項

参照対象は上記skillと関連資料です。リポジトリ内の他skillの全体動作や、各エージェントでの発動精度は確認していません。

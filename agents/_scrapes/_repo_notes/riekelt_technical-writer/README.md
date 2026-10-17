# riekelt/technical-writer 調査ノート

> 外部リポジトリのローカルスナップショットを対象にした調査ノートです。内容は記録したコミット時点のファイルに基づき、upstreamの更新には自動追随しません。

## 対象・調査時点

| 項目 | 内容 |
| --- | --- |
| 対象 | [`riekelt/technical-writer`](../../_repos/riekelt_technical-writer/) |
| 取得元 | `https://github.com/riekelt/technical-writer.git` |
| 調査日 | 2026-10-18 |
| HEAD | `85e53729dd959a2795d593d6769068e342cf3486` |
| HEADの日時 | 2026-09-13 06:22:28 +00:00 |
| 取得時の状態 | ソースcloneのワーキングツリーはclean |

## 参照した skill

| パス | 役割 |
| --- | --- |
| [`plugins/technical-writer/skills/technical-writing/SKILL.md`](../../_repos/riekelt_technical-writer/plugins/technical-writer/skills/technical-writing/SKILL.md) | 技術文書共通の方針、発動条件、作成前チェック、情報源、文書種別、レビュー手順 |
| [`plugins/technical-writer/skills/technical-writing/references/truth.md`](../../_repos/riekelt_technical-writer/plugins/technical-writer/skills/technical-writing/references/truth.md) | 事実、出典、確信度、推測を扱うための詳細資料 |
| [`plugins/technical-writer/skills/technical-writing/references/style.md`](../../_repos/riekelt_technical-writer/plugins/technical-writer/skills/technical-writing/references/style.md) | 技術文書の文体・構成に関する詳細資料 |

## `session-retrospective` での参照

| 項目 | 内容 |
| --- | --- |
| 調査日 | 2026-10-18 |
| 対象コミット | `85e53729dd959a2795d593d6769068e342cf3486` |
| 参照したファイル | [`plugins/technical-writer/skills/writing-postmortems/SKILL.md`](../../_repos/riekelt_technical-writer/plugins/technical-writer/skills/writing-postmortems/SKILL.md) |
| 採用した内容 | 事実ベースのタイムライン、誤った経路、責任追及を避けた構造的な改善項目。永続的なポストモーテム、owner管理、immutableなレビュー済み記録は採用しなかった。 |
| 未確認事項 | postmortem skill が要求する `technical-writing` との組み合わせを、この skill の runtime で実行した結果は確認していない。 |

## 確認した特徴

- 文書を作成する前に、種別、読者、目的、対象外を整理するチェックポイントを置く。
- 既存の同種文書、README、既存の用語や構成を先に確認する。
- 正しい内容は style ではなく情報源から決め、主張の出典と現在の挙動を区別する。
- 技術文書共通のルールと、設計書、決定記録、runbook、APIリファレンスなどの形式別ルールを分離する。
- 短い文章でも、読者が急いで二度読むことを想定し、結論、構造、用語、検証可能性を確認する。

## `japanese-writing` への採用内容

作成前の「文書種別・読者・目的・対象外」整理、既存文書の確認、情報源と文体規則の分離を採用しました。英語向けの禁止構文や house style は移植せず、日本語の自然さと各出力先の慣例を優先します。

## 未確認事項

この調査では、同リポジトリの兄弟 skill や plugin の全体動作、実際のハーネスごとの発動結果は確認していません。対象は `technical-writing` skillと直接参照する資料に限定しています。

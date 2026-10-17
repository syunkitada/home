# coji/natural-japanese 調査ノート

> 外部リポジトリのローカルスナップショットを対象にした調査ノートです。内容は記録したコミット時点のファイルに基づき、upstreamの更新には自動追随しません。

## 対象・調査時点

| 項目 | 内容 |
| --- | --- |
| 対象 | [`coji/natural-japanese`](../../_repos/coji_natural-japanese/) |
| 取得元 | `https://github.com/coji/natural-japanese.git` |
| 調査日 | 2026-10-18 |
| HEAD | `03bc944a0c4a9f0b2a66eab065b30de5c529bf08` |
| HEADの日時 | 2026-10-16 14:39:36 +09:00 |
| 取得時の状態 | ソースcloneのワーキングツリーはclean |

## 参照した skill

| パス | 役割 |
| --- | --- |
| [`skills/natural-japanese/SKILL.md`](../../_repos/coji_natural-japanese/skills/natural-japanese/SKILL.md) | 日本語文章の作成・編集、意味保持、読者・目的の確認、文書構造、自己点検 |
| [`skills/natural-japanese/references/doctypes/`](../../_repos/coji_natural-japanese/skills/natural-japanese/references/doctypes/) | 議事録、レポート、ガイド、メモ、スライドなどの文書種別別ガイド |
| [`skills/natural-japanese/scripts/`](../../_repos/coji_natural-japanese/skills/natural-japanese/scripts/) | 表現、構成、用語、段落、新規事実を確認する補助スクリプト |

## 確認した特徴

- 編集時に元の事実、数値、人名、日付、条件、意見、確信度を変えないことを最優先にしている。
- 新規作成では、読者、目的、主メッセージ、素材を先に決め、素材不足を一般論で埋めない。
- 文書種別ごとに詳細資料を分け、短い通常処理と長文・重要文書向けの処理を使い分ける。
- 読者が具体的に何を指しているか分からない表現を、元資料にある名前や動作へ戻す。
- lintによる機械的検出と、文脈を見て修正する判断を分離している。

## `japanese-writing` への採用内容

「元にない情報を足さない」「読者と目的を先に決める」「新規作成と編集の判断を分ける」「文書種別ごとに参照資料を分ける」という考え方を採用しました。`japanese-writing` では、初版の責務を文章作成・編集の手順に絞るため、lintスクリプトやスコアリング機能は移植していません。

## 未確認事項

この調査では、upstreamのskillを実際のCodexセッションへ導入して比較する評価は行っていません。補助スクリプトの依存関係や、上流の将来変更もこのノートの範囲外です。

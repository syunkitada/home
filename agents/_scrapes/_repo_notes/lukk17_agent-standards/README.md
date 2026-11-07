# Lukk17/agent-standards 調査ノート

> 外部リポジトリのローカルスナップショットを対象にした調査ノートです。内容は記録したコミット時点のファイルに基づき、upstreamの更新には自動追随しません。

## 対象・調査時点

| 項目 | 内容 |
| --- | --- |
| 対象 | [`Lukk17/agent-standards`](../../_repos/Lukk17_agent-standards/) |
| 取得元 | `https://github.com/Lukk17/agent-standards.git` |
| 調査日 | 2026-11-07 |
| HEAD | `fa85e2536eaea4c76eac54ce4e63bd47ba70bf34` |
| HEADの日時 | 2026-11-06 05:59:52 +01:00 |
| 取得時の状態 | ソースcloneのワーキングツリーはclean |

## 参照したskillと資料

| パス | 役割 |
| --- | --- |
| [`.agents/skills/markdown-writer/SKILL.md`](../../_repos/Lukk17_agent-standards/.agents/skills/markdown-writer/SKILL.md) | 発動条件、人向けと機械向け文書の区別、Markdown作成・監査 |
| [`references/readme-and-voice.md`](../../_repos/Lukk17_agent-standards/.agents/skills/markdown-writer/references/readme-and-voice.md) | 根拠確認、README、声調、図表、リンク、既存文書の点検 |
| [`references/formatting-rules.md`](../../_repos/Lukk17_agent-standards/.agents/skills/markdown-writer/references/formatting-rules.md) | コードブロック、リンク、見出し、リスト等の書式規則 |
| [`references/multilingual.md`](../../_repos/Lukk17_agent-standards/.agents/skills/markdown-writer/references/multilingual.md) | 翻訳文書の構造と原文との同期 |

## 確認した特徴

- 人が読むMarkdownと、機械向け・外部規約に従うMarkdownを区別する。
- リポジトリにある根拠を確認してから事実を書く。
- Markdownの見出し、リンク、アンカー、コード例、図、文書案内を監査する。
- 翻訳文書ではロケール、構造、アンカー、原文との同期を考慮する。
- 参照skillは固定された節順、ダッシュ禁止、パスの全面リンク化など強い書式規則も要求する。

## `prose-writing` への採用内容

文書の読者と機械的な役割を確認すること、事実を既存リポジトリの情報と照合すること、Markdownリンク・アンカー・コード例・図を点検することを採用しました。翻訳では既存のロケール命名規則を優先し、リンク・アンカー・コード等の対応を確認する方針を採用しました。

固定のREADME構成、ダッシュ記号の禁止、バッジの制限、すべてのパスのリンク化、常に文書マップを設ける規則は、用途とプロジェクトによって適切さが異なるため採用していません。監査前に必ず承認を求める手順も、既存の作業権限や明示された依頼を優先し、このskillの必須ゲートにはしていません。

## 未確認事項

参照対象は上記skillと直接関連する資料です。リポジトリの生成ツール、lint hook、他skillとの連携結果や、各エージェントでの発動精度は確認していません。

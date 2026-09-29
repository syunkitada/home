# コードレビューの参考資料と判断

このファイルは、現在のこのスキルの設計根拠と、参考資料からの変換内容を記録します。取得した参照リポジトリは実行時依存ではありません。

## 参考資料

| 参考元 | リビジョン | 参照したパス | 採用した内容 |
| --- | --- | --- | --- |
| [mattpocock/skills](https://github.com/mattpocock/skills/tree/c55ee46073ed923f86ce59a5eb3b6d895095d1b7) | c55ee46073ed923f86ce59a5eb3b6d895095d1b7 | skills/engineering/code-review/SKILL.md | 比較元の固定、仕様軸と規約軸、空の差分を早期に扱う考え方 |
| [getsentry/skills](https://github.com/getsentry/skills/tree/c2f99a5b04b4cd992ec3022d7c2c3e23e938d241) | c2f99a5b04b4cd992ec3022d7c2c3e23e938d241 | skills/code-review/SKILL.md | 安全性、性能、テスト、互換性を変更に応じて確認する観点 |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills/tree/dc27a9c2e13721158157632de61b4106c6c2a2a1) | dc27a9c2e13721158157632de61b4106c6c2a2a1 | skills/code-review-and-quality/SKILL.md | 多軸評価、変更サイズと構造上の問題を確認する考え方 |
| [obra/superpowers](https://github.com/obra/superpowers/tree/5bf4e78011075bcfc0dc295f0724994cd123ee71) | 5bf4e78011075bcfc0dc295f0724994cd123ee71 | skills/receiving-code-review/SKILL.md、skills/requesting-code-review/SKILL.md | レビューと修正を分離し、提案を検証してから対応する考え方 |
| [OpenAI スキル公式ドキュメント](https://learn.chatgpt.com/docs/build-skills) | 2026-09-22 閲覧 | スキルの形式と検出 | SKILL.md を入口にし、詳細を references へ段階的に分ける方針 |

## 自分用の調整

- 並列サブエージェントは必須にしない。現在の作業環境では、対象範囲と検証結果を一つのレビューで追跡できることを優先する。
- 課題管理ツールや GitHub CLI は必須にしない。ユーザーが仕様や PR 情報を提示した場合だけ利用する。
- PR の base/head を解決できない場合は、現在の HEAD を代用せず範囲エラーとして扱う。
- Sentry の Django・React 例は汎用チェックリストへ一般化し、該当する変更だけを確認する。
- P0 から P3 の重要度と日本語での報告は、このリポジトリの既存スキルの契約を維持する。
- 実行時に使う参照資料は SKILL.md から相対リンクし、報告には確信度を含める。

## 未確認事項と次に集める証拠

まだ実際の利用ログから抽出した誤検出・見逃しの保留検証例はありません。次の3ケースを実利用で確認し、必要なら references/evidence/ に匿名化して保存します。

1. ステージ済みと未ステージ変更が同じファイルにあるケース
2. テストは通るが仕様に違反するケース
3. 問題がなく、過剰な指摘を避けるケース

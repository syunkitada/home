# japanese-writing-polish の構成と保守契約

このファイルは、既存の yomiyasu skill を `japanese-writing-polish` として管理するための構成、移植元、変更範囲を記録します。既存のリライト原則と出力形式は [SKILL.md](./SKILL.md) の内容を正本とし、今回の変更ではドキュメンテーション向けのドメイン判定と参照資料を追加します。

## 構成

| パス | 役割 |
| --- | --- |
| [SKILL.md](./SKILL.md) | リライトの原則、実行手順、出力形式。実行時の入口 |
| [LICENSE](./LICENSE) | 移植元のMITライセンス本文 |
| [references/](./references/) | 構文変換原則、不自然な語彙のカタログ、ドメイン別の指針 |
| [scripts/](./scripts/) | 文章のAIっぽさを検査するリンターと、そのテスト |

## 移植元・参照元

[`agents/_scrapes/_repos/nanaism_yomiyasu/skills/yomiyasu/`](../../_scrapes/_repos/nanaism_yomiyasu/skills/yomiyasu/) を移植元・参照元として取り込みました。確認した移植元リビジョンは `b14ee43c9b722cf4fd2bb1e893c6c386f1a362aa` です。このディレクトリの内容を正本として管理し、移植元のMITライセンス本文を [LICENSE](./LICENSE) に保持します。

この skill の再構成では、次の識別情報、構成説明、ドキュメンテーション向けの参照資料を変更しています。

- ディレクトリ名を `yomiyasu` から `japanese-writing-polish` へ変更
- `SKILL.md` の frontmatter `name` と見出しを変更
- READMEの見出し、呼び出し例、Index、親ディレクトリのIndexを変更
- `README.md`、`SKILL.md`、`SPEC.md` を入口・実行手順・構成根拠として整理
- `references/domains/documentation.md` を追加し、文書種別ごとの推敲方針を追加

既存のリライト規則、参照資料の本文、リンターとテストの実装、既存のスクリプトファイル名は変更しません。新しい `documentation.md` は、移植元にないドキュメンテーション向けの追加資料です。移植元を示すパスと `yomiyasu_lint.py` などの内部資材名は、移植元との対応を保つため維持します。

## ドキュメンテーション方針の設計根拠

既存の文章推敲ルールと責務が重ならない範囲で、次の資料からドキュメンテーション向けの方針を整理しました。

| 参照元 | 参照箇所 | 採用した内容 |
| --- | --- | --- |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills/blob/dc27a9c2e13721158157632de61b4106c6c2a2a1/skills/documentation-and-adrs/SKILL.md) | `dc27a9c2e13721158157632de61b4106c6c2a2a1`、`skills/documentation-and-adrs/SKILL.md` | README、ADR、APIドキュメントの目的、背景・決定・代替案・結果の分離、既存の文書規約を優先すること、「何をしたか」だけでなく「なぜそうしたか」を残す考え方 |
| [getsentry/skills](https://github.com/getsentry/skills/blob/c2f99a5b04b4cd992ec3022d7c2c3e23e938d241/skills/doc-coauthoring/SKILL.md) | `c2f99a5b04b4cd992ec3022d7c2c3e23e938d241`、`skills/doc-coauthoring/SKILL.md` | 文書の読者・目的・形式・制約を確認し、構成と読者の疑問を意識して推敲する考え方 |
| [mattpocock/skills](https://github.com/mattpocock/skills/blob/c55ee46073ed923f86ce59a5eb3b6d895095d1b7/skills/productivity/writing-for-agents/SKILL.md) | `c55ee46073ed923f86ce59a5eb3b6d895095d1b7`、`skills/productivity/writing-for-agents/SKILL.md` | 情報階層、段階的開示、ポインタ、完了条件、重複と古い説明の整理 |

これらは文書の文章と構成を整える知識として採用しました。対話的な共同執筆の全工程、ADRやAPIスキーマの新規作成、実装との整合性検証、リンクやREADMEの構成管理は、このskillの責務に含めず、既存の `task-planning`、`implementation`、`verification` などへ分離します。

## 保守方針

- リライトの挙動や出力形式を変更する場合は、`SKILL.md` と関係する `references/` を同じ変更で更新する。
- 参照資料やスクリプトの追加・削除・改名を行う場合は、関係するREADMEのIndexと相対リンクを同期する。
- ドキュメンテーション向けの推敲方針を変更する場合は、`SKILL.md` のドメイン判定、`references/domains/README.md` のIndex、この `SPEC.md` の設計根拠を同期する。
- 移植元の更新を取り込む場合は、内容差分、ライセンス、スクリプトテストへの影響を確認してから反映する。
- skill名を変更する場合は、ディレクトリ、frontmatter、見出し、呼び出し例、親Index、配置先リンクを同期する。

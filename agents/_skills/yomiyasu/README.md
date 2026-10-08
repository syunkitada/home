# yomiyasu（よみやす）

AIが生成した不自然な日本語を、意味を保ったまま人間が読みやすい文章へ推敲する skill です。実行入口は [SKILL.md](./SKILL.md) です。

## Index

| パス | 役割 |
| --- | --- |
| [SKILL.md](./SKILL.md) | リライトの原則、実行手順、出力形式 |
| [references/](./references/) | 構文変換原則、不自然な語彙のカタログ、ドメイン別の指針 |
| [scripts/](./scripts/) | 文章のAIっぽさを検査するリンター |
| [LICENSE](./LICENSE) | 移植元のMITライセンス |

## 由来

[`agents/_scrapes/_repos/nanaism_yomiyasu/skills/yomiyasu/`](../../_scrapes/_repos/nanaism_yomiyasu/skills/yomiyasu/) を移植元・参照元として取り込みました。このディレクトリの内容を正本として管理します。元リポジトリのライセンスはMITです。

## 利用例

~~~text
$yomiyasu この文章を技術記事向けに読みやすくして。ドメインはtech。
~~~

ファイルを保存する場合や `--full` モードでは、付属の `scripts/yomiyasu_lint.py` で機械的な検査を実行します。

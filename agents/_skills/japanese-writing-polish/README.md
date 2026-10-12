# japanese-writing-polish

AIが生成した不自然な日本語を、意味を保ったまま人間が読みやすい文章へ推敲する skill です。実行入口は [SKILL.md](./SKILL.md)、構成・出典・保守情報は [SPEC.md](./SPEC.md) です。

## Index

| パス | 役割 |
| --- | --- |
| [SKILL.md](./SKILL.md) | リライトの原則、実行手順、出力形式 |
| [SPEC.md](./SPEC.md) | 構成、移植元、変更範囲、保守方針 |
| [LICENSE](./LICENSE) | 移植元のMITライセンス本文 |
| [references/](./references/) | 構文変換原則、不自然な語彙のカタログ、ドメイン別の指針 |
| [scripts/](./scripts/) | 文章のAIっぽさを検査するリンター |

## 構成・由来

構成、移植元、変更範囲、保守方針は [SPEC.md](./SPEC.md) にまとめています。このディレクトリの内容を正本として管理します。

## 利用例

~~~text
$japanese-writing-polish この文章を技術記事向けに読みやすくして。ドメインはtech。
$japanese-writing-polish READMEの導入手順を、前提条件と期待結果が伝わるように整えて。ドメインはdocumentation。
~~~

ファイルを保存する場合や `--full` モードでは、付属の `scripts/yomiyasu_lint.py` で機械的な検査を実行します。

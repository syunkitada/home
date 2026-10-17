# japanese-writing

技術説明、プロダクト説明、Confluence・Wiki、Slackなどの日本語文章を、読者と目的に合わせて作成・編集する skill です。読みやすさを高めながら、根拠のない情報を足さず、元の意味と文書の役割を保ちます。

実行入口は [SKILL.md](./SKILL.md)、設計根拠と保守契約は [SPEC.md](./SPEC.md) です。

## Index

| パス | 役割 |
| --- | --- |
| [SKILL.md](./SKILL.md) | 発動条件、共通手順、出力方針 |
| [SPEC.md](./SPEC.md) | 適用範囲、設計判断、参考資料、保守方針 |
| [references/](./references/) | 共通原則、形式別ガイド、最終確認項目 |

## 利用例

~~~text
$japanese-writing 技術説明として、この文章を読みやすく編集して
$japanese-writing write product 新機能の紹介文を作成して
$japanese-writing edit slack この内容をSlackで依頼する文章にして
~~~

形式を指定しない場合は、依頼内容と出力先から自動判定します。文章の事実確認やリポジトリの変更が必要な場合は、別の skill と組み合わせます。

## 保守

文章の共通原則や形式別の判断を変更した場合は、[SKILL.md](./SKILL.md)、該当する [references/](./references/)、[SPEC.md](./SPEC.md) を同期します。外部資料は実行時依存にせず、採用した考え方と参照リビジョンを `SPEC.md` に記録します。

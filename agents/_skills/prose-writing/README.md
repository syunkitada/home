# prose-writing

自然言語で人が読む文章・文書を、日本語を含む複数の言語と形式に合わせて作成・編集する skill です。Markdown文書や文書内のMermaid図のほか、技術・プロダクト説明、Wiki、Slack投稿を扱い、アプリケーションコードや設定の作成には使いません。

実行入口は [SKILL.md](./SKILL.md)、設計根拠と保守契約は [SPEC.md](./SPEC.md) です。

## Index

| パス | 役割 |
| --- | --- |
| [SKILL.md](./SKILL.md) | 発動条件、共通手順、出力方針 |
| [SPEC.md](./SPEC.md) | 適用範囲、設計判断、参考資料、保守方針 |
| [references/](./references/README.md) | 共通原則、形式別・言語別ガイド、最終確認 |

## 利用例

~~~text
$prose-writing write technical READMEの概要を素材に基づいて作成して
$prose-writing edit slack この依頼文を相手が判断しやすい形に整えて
$prose-writing polish Markdownの見出しとリンクを確認しながら文章を推敲して
$prose-writing mermaid この処理フローを文書に載せる図にして
~~~

形式や言語を指定しない場合は、依頼内容、素材、出力先から判断します。事実確認やリポジトリ内の文書変更を伴う場合は、必要に応じて別のskillと組み合わせます。

## 保守

共通原則、形式別ガイド、言語別ガイドを変更した場合は、[SKILL.md](./SKILL.md)、該当する [references/](./references/README.md)、[SPEC.md](./SPEC.md) を同期します。外部資料は実行時依存にせず、出典、参照コミット、採用内容を `SPEC.md` に記録します。

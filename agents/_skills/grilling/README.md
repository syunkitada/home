# grilling

計画、設計、意思決定を質問ラウンドで掘り下げ、実装前の共通理解を作る skill です。ユーザーが考えを厳しく検証したいときに明示的に使います。実装そのものは行わず、確認後に必要なら `task-planning` または `implementation` へ引き渡します。

実行入口は [SKILL.md](./SKILL.md)、設計根拠と保守契約は [SPEC.md](./SPEC.md) です。

## Index

| パス | 役割 |
| --- | --- |
| [SKILL.md](./SKILL.md) | 発動条件、質問ラウンド、共通理解の確認、引き渡し条件 |
| [SPEC.md](./SPEC.md) | 適用範囲、公開契約、設計判断、参考資料、保守方針 |

## 利用例

~~~text
$grilling この設計案の前提を厳しく検証して、実装前に決めることを質問してください。
~~~

通常の計画作成では、質問で要件を掘り下げた後に [task-planning](../task-planning/README.md) を使います。仕様がすでに確定している作業では、直接 [implementation](../implementation/README.md) を使います。

## 保守

質問ラウンド、共通理解の要約、確認前の変更禁止、他の skill への引き渡し条件を変更した場合は、[SKILL.md](./SKILL.md)、[SPEC.md](./SPEC.md)、この README の説明を同期します。外部資料を追加・更新した場合は、参照 URL、リビジョン、参照箇所、採用内容を [SPEC.md](./SPEC.md) に記録します。

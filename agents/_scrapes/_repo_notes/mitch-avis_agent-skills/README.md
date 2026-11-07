# mitch-avis/agent-skills 調査ノート

> 外部リポジトリのローカルスナップショットを対象にした調査ノートです。内容は記録したコミット時点のファイルに基づき、upstreamの更新には自動追随しません。

## 対象・調査時点

| 項目 | 内容 |
| --- | --- |
| 対象 | [`mitch-avis/agent-skills`](../../_repos/mitch-avis_agent-skills/) |
| 取得元 | `https://github.com/mitch-avis/agent-skills.git` |
| 調査日 | 2026-11-07 |
| HEAD | `ce7b8d00d2825ce4044ddf020c3bbe9bb10a662a` |
| HEADの日時 | 2026-11-04 21:23:46 -07:00 |
| 取得時の状態 | ソースcloneのワーキングツリーはclean |
| ライセンス | MIT |

## 参照した skill と資料

| パス | 役割 |
| --- | --- |
| [`mermaid/SKILL.md`](../../_repos/mitch-avis_agent-skills/mermaid/SKILL.md) | 図種選択、基本例、構文上の注意、作成後の確認 |
| [`mermaid/references/flowcharts.md`](../../_repos/mitch-avis_agent-skills/mermaid/references/flowcharts.md) | Flowchartのノード、接続、サブグラフ、配置 |
| [`mermaid/references/sequence-diagrams.md`](../../_repos/mitch-avis_agent-skills/mermaid/references/sequence-diagrams.md) | Sequenceの参加者、メッセージ、分岐、並列、ループ |
| [`mermaid/references/erd-diagrams.md`](../../_repos/mitch-avis_agent-skills/mermaid/references/erd-diagrams.md) | ERの属性、多重度、関係 |
| [`mermaid/references/class-diagrams.md`](../../_repos/mitch-avis_agent-skills/mermaid/references/class-diagrams.md) | Classのメンバー、関係、多重度 |
| [`mermaid/references/c4-diagrams.md`](../../_repos/mitch-avis_agent-skills/mermaid/references/c4-diagrams.md) | C4のContext、Container、Component |
| [`mermaid/references/syntax-rules.md`](../../_repos/mitch-avis_agent-skills/mermaid/references/syntax-rules.md) | よくある構文エラーと回避策 |
| [`mermaid/references/architecture-diagrams.md`](../../_repos/mitch-avis_agent-skills/mermaid/references/architecture-diagrams.md) | architecture-betaのグループ、サービス、接続 |
| [`mermaid/references/advanced-features.md`](../../_repos/mitch-avis_agent-skills/mermaid/references/advanced-features.md) | テーマ、配置、スタイル、アクセシビリティ等 |

## 確認した特徴

- 内容に応じてFlowchart、Sequence、ER、Class、State、C4、Architecture、Gantt、Git graphなどを選ぶ。
- 図種ごとに構文例と、ラベル、ID、矢印、サブグラフ等で起きやすいエラーを参照資料に分けている。
- 描画先の互換性、適切な規模、構文の検証をチェックリストに含めている。
- Mermaid CLIを使ったSVG・PNG・ASCII出力用スクリプト、テーマ・配置の詳細、特定環境向けの制約も同梱している。

## `prose-writing` への採用内容

図種の選択表、Flowchart・Sequence・ER・Class・Stateの短い構文例、ラベルとIDの区別、サブグラフ、予約語・特殊文字による構文エラー、アクセシビリティ、実際のレンダラーでの確認を採用しました。概要は [`prose-writing` のMermaidガイド](../../../_skills/prose-writing/references/diagrams/mermaid.md)、図種別の詳細は[参照資料Index](../../../_skills/prose-writing/references/diagrams/mermaid/README.md)にあります。

Mermaid CLIとNode.js依存関係、テーマやレンダリング設定の包括的な説明、固定のノード数上限や記号の一律禁止は採用していません。構文の正確性はupstream skillだけに依存せず、調査時点の公式Mermaidドキュメントと対象レンダラーで確認します。

## 未確認事項

upstreamの図例すべてを各Mermaidレンダラーで実行確認したわけではありません。サポートする図種やパーサー機能はホストとバージョンに依存するため、実際に使う際は対象環境での確認が必要です。

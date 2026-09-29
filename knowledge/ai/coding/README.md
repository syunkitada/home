# AI Coding

## Index

| Link | Description |
| --- | --- |
| [coding_with_copilot/](coding_with_copilot/README.md) | Copilotを利用したコーディングのメモです。 |
| [context_prompt.md](context_prompt.md) | コンテキストやプロンプトに関するメモです。 |
| [note.md](note.md) | AIコーディングの雑多なメモです。 |
| [opencode.md](opencode.md) | OpenCode に関するメモです。 |

## AI コーディング手法の分類

- リアクティブ・インライン補完（Reactive Inline Completion）
  - GitHub Copilot に代表される、既存の統合開発環境（IDE）や Vim にプラグインとして統合されるリアルタイムのコード補完。
  - この手法は「リアクティブ（反応型）」と呼ばれ、開発者がコードを記述する際、直前の文脈やコメント、関数名から次の数行、あるいは関数全体を予測して提案する。
  - このアプローチの最大の特徴は、既存の開発ワークフローへの介入を最小限に抑えつつ、定型的なコード（ボイラープレート）の記述時間を大幅に短縮できる点にある。
  - しかし、その文脈理解はアクティブなバッファ周辺に限定されることが多く、プロジェクト全体のアーキテクチャや離れたファイル間の依存関係を考慮した提案には限界がある。
- AI ネイティブ IDE およびコンテキスト・アウェア・アシスタンス（AI-Native IDEs）
  - Cursor や Windsurf（旧 Cognition 製品）に代表される AI ネイティブ IDE は、エディタそのものが AI との協調を前提に再構築されている。
  - これらのツールは、プロジェクト全体のファイルをインデックス化し、RAG（検索拡張生成）やセマンティック検索を用いることで、広範な「プロジェクト・アウェア（プロジェクト認識型）」な支援を可能にする。
  - 開発者はチャットインターフェースや特定のショートカット（例：Cursor の Cmd+K）を通じて、複数のファイルにまたがるコードの修正やリファクタリングを指示できる。
- AI 駆動開発（自律型 AI エージェントによる実装）
  - Claude Code、Devin、Gemini CLI、Copilot Agent、Codex CLI といった、自律型 AI エージェントに実装自体を任せる。
  - これらの AI エージェントは、自然言語で与えられた高レベルなタスク目標（例：「既存の認証モジュールをリファクタリングせよ」「新しい機能のテストケースを作成しデバッグせよ」）を理解し、自律的に計画、実行、検証を行う。

## 歴史

> 製品の公開日や機能は更新されるため、月単位の記述は公式発表を一次情報とする。出典のない断定は避け、ここでは公開時期と当時の位置づけを簡潔に記録する。

- 2022 年
  - GitHub Copilot が一般提供開始。OpenAI の Codex を利用したコード補完・提案ツールとして始まった。
    - [GitHub Copilot](https://github.com/features/copilot)
- 2023 年
  - Cursor が登場。VS Code を基盤とする AI 支援コードエディタ。
    - [Cursor](https://www.cursor.com/)
- 2025 年 2 月
  - Anthropic が Claude Code を発表。Claude 3.7 Sonnet の発表と同時に、エージェント型のコマンドラインツールとして紹介された。
    - [Claude 3.7 Sonnet and Claude Code](https://www.anthropic.com/news/claude-3-7-sonnet)
  - Vibe coding という呼称が広く知られるようになった。AI に実装の多くを委ね、対話とフィードバックで開発を進める手法を指すが、品質・保守性・セキュリティの確認は必要である。
- 2025 年 4 月
  - OpenAI が Codex CLI を公開。Codex CLI はターミナルから利用できるオープンソースの AI コーディングエージェントである。
    - [Introducing Codex](https://openai.com/index/introducing-codex/)
    - [OpenAI Codex リポジトリ](https://github.com/openai/codex/)
  - BMAD-METHOD など、PM、開発者、デザイナー、テスターなどの役割を複数エージェントに分担させる開発手法が公開された。
    - [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD)
- 2025 年 5 月
  - GitHub が GitHub Copilot coding agent を発表。Issue などのタスクをバックグラウンドで処理し、変更を pull request として提案する。
    - [GitHub Copilot: Meet the new coding agent](https://github.blog/news-insights/product-news/github-copilot-meet-the-new-coding-agent/)
- 2025 年 6 月
  - コンテキストエンジニアリングという考え方が AI エージェント開発で広く使われ始めた。ツール情報、プロジェクト知識、作業ルールなど、エージェントが参照すべき情報を整理・選択する実践を指す。
  - Google が Gemini CLI を公開した。
    - [Gemini CLI](https://github.com/google-gemini/gemini-cli)
- 2025 年 7 月
  - METR が、初期 2025 年の AI ツールを経験豊富な OSS 開発者が使った場合の RCT を公開した。16 名・246 タスクの研究では、AI 利用時の完了時間が平均 19%長くなった。
    - [METR の研究記事](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/)
    - この結果は対象者・リポジトリ・ツール・時期に依存するため、一般の開発者や現在のモデルへそのまま一般化しない。
  - AWS が Kiro を発表。仕様を先に整理して実装へつなげる spec-driven development を中心にした AI IDE である。
    - [Introducing Kiro](https://kiro.dev/blog/introducing-kiro/)
- 2025 年 8 月以降
  - GitHub Spec Kit が公開された。エージェントに依存しない Spec-Driven Development のプロセス、テンプレート、スクリプトを提供する。
    - [GitHub Spec Kit](https://github.com/github/spec-kit)
  - Fission AI の OpenSpec が公開された。AI コーディングアシスタント向けの Spec-Driven Development ツールである。
    - [Fission AI OpenSpec](https://github.com/Fission-AI/OpenSpec)
- 2025 年 10 月
  - Codex が一般提供開始 (GA)。Codex CLI の公開時期とは別の出来事である。
    - [Codex is generally available](https://openai.com/index/codex-now-generally-available/)
- 2025 年 11 月
  - Google が Google Antigravity を発表。IDE とエージェント管理を組み合わせたエージェント型開発プラットフォームとして公開プレビューを開始した。
    - [Introducing Google Antigravity](https://www.antigravity.google/blog/introducing-google-antigravity)

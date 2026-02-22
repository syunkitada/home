# AI

## Services

- [ChatGPT](https://chatgpt.com/)
- [NotebookLM](https://notebooklm.google.com/)
  - URL を入れるとそのサイトを要約してくれる
  - ラジオ風に要約してくれることができて、これが神
    - [LLM 推論に関する技術メモ](https://zenn.dev/cube/books/460bb068d9613a/viewer/3b18b4) を入れてやってみてほしい
- [DeepWiki](https://deepwiki.com/)
  - GitHub の「「ttps://github.com/r488it/claude_hands 」という URL を「https://deepwiki.com/r488it/claude_hands 」に変換するだけ
  - リポジトリのコードの解説 Wiki を作成してくれる
- [Gemini](https://gemini.google.com/)
  - Deep Research
  - Create Image
  - Canvas
  - Guided Learning

## LLM(Open Model)

- Gemma
  - Company: Google
- Llama
  - Company: Meta
- gpt-oss
  - Company: Open AI
- Sarashina
  - Company: Softbank

## AI Agent

- Copilot Agent
  - Copilot の Agent 板
- Copilot CLI
  - https://github.com/github/copilot-cli (Public Preview)
- Gemini CLI
  - OSS(Apache License 2.0): https://github.com/google-gemini/gemini-cli
- Claude Code
  - [Zenn: Anthropic が提案する Claude Code のベストプラクティス](https://zenn.dev/ueshiii/articles/6b7561f1a1daae)

## AI Agent(OSS)

- https://github.com/google-gemini/gemini-fullstack-langgraph-quickstart
- https://github.com/langchain-ai/open_deep_research

## AI Library

- [LiteLLM](https://github.com/BerriAI/litellm)
  - OpenAI の形式で、様々な LLM API(Bedrock, Huggingface, VertexAI, TogetherAI, Azure, OpenAI, Groq etc.)を利用することができる

## AI Agent Flamework

- [Google: Agent Development Kit](https://google.github.io/adk-docs/)
- [Pydantic AI](https://ai.pydantic.dev/)
- [Langchain](https://github.com/langchain-ai/langchain)

## RAG

- ChromaDB

## MCP Flamework

## コスト(2025/12/28)

- Github Copilot
  - 個人向け
    - 無料の Free プラン
    - Pro($10/Month)
    - Pro+($39/Month)
  - 法人向け
    - Business(1User $19/Month)
    - Enterprise(1User $39/Month)
- Claude
  - 個人向け
    - 料金
      - Pro($20/Month)
        - 月額料金 $20（米国）。年間プランの場合、年額$200 を前払いで割引適用
        - 利用可能モデル Claude Sonnet 4.5
        - メッセージ数 5 時間ごとに約 10 ～ 40 プロンプト（Claude のブラウザ使用における 45 メッセージに相当）
        - 推奨用途 小規模なリポジトリでの軽作業
      - Max 5x($100/Month)
        - 月額料金 $100
        - 利用可能モデル Claude Sonnet 4.5 と Claude Opus 4.1 の両方（/model コマンドで切り替え可能）
        - メッセージ数 5 時間ごとに約 50 ～ 200 件のプロンプト（Claude のブラウザ使用における 225 メッセージに相当）
        - 推奨用途 大規模なコードベースでの日常的な使用、またはパワーユーザー向け
      - Max 20x($200/Month)
        - 月額料金 $200
        - 利用可能モデル Claude Sonnet 4.5 と Claude Opus 4.1（/model コマンドで切り替え可能）
        - メッセージ数 5 時間ごとに約 200 ～ 800 プロンプト（Claude のブラウザ使用における 900 メッセージに相当）
        - 推奨用途 大規模なコードベースでの日常的な使用、またはパワーユーザー向け

## リテラシー

- OpenCodeなどのサードパーティ エージェントを利用する際の注意点
  - 許可されているLLMプロバイダ以外は利用しない
    - Claude Pro/Max契約で、OpenCodeなどのサードパーティ エージェント経由で利用していたらBanされたらしい。
      - そもそも規約でサードパーティのハーネスなどからの利用は規約で禁止されている。
    - GitHub Copilotなどに関しても同様で、サードパーティ エージェント経由で利用するとBanされる可能性がありそう。
    - [OpenCodeにおける一部のサードパーティプロバイダーは治安が悪すぎる](https://zenn.dev/nuits_jp/articles/2026-01-11-opencode-third-party-provider)

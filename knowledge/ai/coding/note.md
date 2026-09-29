# メモ書き

## コーディングのための MCP サーバ

- Context7
  - ライブラリやフレームワークの最新ドキュメントを検索・取得できます。
  - 最新の技術ドキュメントを AI に提供し、ハルシネーション（嘘の回答）を防ぐことができます。
  - 料金
    - 個人開発で利用するなら Free プランで十分
    - 企業で利用する場合は、Enterprise プランを利用する必要がある？
  - 参考
    - https://context7.com/
    - https://github.com/upstash/context7
- Ref
  - ライブラリやフレームワークの最新ドキュメントを検索・取得できます。
  - 最新の技術ドキュメントを AI に提供し、ハルシネーション（嘘の回答）を防ぐことができます。
  - 料金
    - 個人開発で利用するなら Free プランで十分
    - 企業で利用する場合は、Enterprise を利用する必要がある？
  - 参考
    - https://ref.tools/
    - https://github.com/ref-tools/ref-tools-mcp
- Serena
  - LSP（Language Server Protocol）を活用した、コード解析を行うためのサーバです。
  - 最近は LSP サーバ自体が MCP をサポートしていて、Serena は不要かもしれない。
  - 一方 IDE(VSCode など) 以外の環境、例えば Claude Code(CLI)の環境では有用かもしれない。
  - 料金
    - ローカル動作する OSS(MIT) のサーバで、外部 API に依存せず、無料で利用可能です。
  - 参考
    - https://github.com/oraios/serena
- Cipher
  - コーディングエージェントのための「永続的な記憶（メモリ）」を提供するサーバです。
  - ナレッジなどを保存するためのものだが、そのようなものはファイルとして git レポジトリにそのまま保存して、プロンプトから参照するだけでも十分だったりする。
  - 料金
    - ローカル動作する OSS(Elastic License 2.0) のサーバで、外部 API に依存せず、無料で利用可能です。
  - 参考
    - https://github.com/campfirein/cipher
- Playwright
  - Playwright を用いたブラウザ自動化機能を提供するサーバです。
  - E2E テストを実施するだけなら、MCP サーバは不要です。
  - 料金
    - ローカル動作する OSS(Apache 2.0) のサーバで、外部 API に依存せず、無料で利用可能です。
  - 参考
    - https://github.com/microsoft/playwright-mcp

## ツール

- Vibe Kanban
  - カンバンボード形式でタスク管理ができるツールです。
  - タスクを AI エージェントに割り当てることで、AI がコードを実装してくれます。
  - MCP サーバーを使うことで、AI エージェント側からタスクの追加や更新を行うこともできます。
  - 参考
    - https://www.vibekanban.com/

## メモ

- MCP は使わなくていいかも？
  - ツールを使うよりもプロンプトで指示出しするので十分かも
  - MCP はツール登録だけでコンテキストを消費するので注意
- 便利スクリプトも不要かも？
  - スクリプトを作り込むよりプロンプトで指示出しするので十分かも
- 秘密情報の取り扱いに注意する
  - AI エージェントが動いている環境で、環境変数などに秘密情報を埋め込まない
- PLANS.md
  - ファイル名は何でも良いが、ファイルにタスク一覧を書いておきそれを AI Agent に実施させるようにすると安定してタスクを遂行できるようになる
- Skills(Claude Code)
  - 特定の仕事のやり方（プロンプト）をスキルとして分離するための仕組み
  - 一つのコンテキストにすべての仕事のやり方を含めるのではなく、別のプロンプトとして分離して必要に応じて参照するというもの

## AI にコードを書かせる技術

- 役割: AI エージェントのスコープを狭める
- プロジェクトの方針を決める
  - 何を、なぜ作るか、ゴールは何かを決める
  - どのようには書かない
- 設計
  - Requirements（要件定義書）を作る
    - 何ができる必要があるかを決める
  - ユーザストーリーを作る(BDD)
  - DDD をベースにドキュメントを作る
    - ドメイン知識、ユビキタス言語の構築
    - ドメインを階層化する
- ドメインごとに設計の質を上げる
- 分解：AI に任せられる単位にタスクを切る
  - インターフェイスを作成する
  - 最小限のテストを書く
  - 最小限の実装をする
- 検証：成果物が要件を満たしているか判断する
- 技術選定：トレードオフを理解し、何を使うか決める
- リスク管理：何を禁止し、どこにガードレールを置くか
- TDD を利用し品質を上げる
  - 以下のサイクルを回す
  1. RED：まず「こう振る舞ってほしい」を表すテストを書く（失敗する）
  2. GREEN：そのテストが通る最小限の実装を書く
  3. REFACTOR：テストが通ったまま、重複などを消して設計を整える

## いろんな開発フロー

- BDD(振る舞い駆動開発)
- TDD(テスト駆動開発)
- DocDD(ドキュメント駆動開発)
- DDD(ドメイン駆動開発)
- SDD(仕様起動開発)

### BDD

1. 共通言語でシナリオを定義する

- Given-When-Then 形式でユーザストーリを自然言語で記述する
  - Given: ユーザがログインして商品ページにいる
  - When: 「カートに追加」ボタンをクリックする
  - Then: カートに商品が追加され成功メッセージが表示される

2. シナリオを自動テストに変換

- Cucumber などのツールを使って自動テストを作成

3. 振る舞いを満たすコードを実装

- テストが通るように機能を実装し、リファクタリング

### TDD

1. RED：まず「こう振る舞ってほしい」を表すテストを書く（失敗する）
2. GREEN：そのテストが通る最小限の実装を書く
3. REFACTOR：テストが通ったまま、重複などを消して設計を整える

```
## Test-Driven Development (TDD)

Favor test-driven development whenever you implement a new feature or fix a defect. For each behavior you change, add or refine the smallest automated test that would catch a regression before you touch production code.

Follow a tight RED–GREEN–REFACTOR loop:

1. **RED** – Add or adjust a test that expresses the desired behavior or bug fix. Run the full test suite and observe the new test failing for the expected reason.
2. **GREEN** – Write the minimal implementation needed to make the new test pass without breaking existing tests. Do not add speculative code that is not exercised by tests.
3. **REFACTOR** – Improve the design of the code and tests while keeping the suite green. Prefer many small, safe refactorings over large unverified rewrites.

Treat test results as primary evidence, not afterthought. Do not declare a milestone complete until the ExecPlan clearly shows which tests fail before the change and pass after it, and how to run them. Avoid testing mock behavior instead of real behavior; if mocks become complex, consider whether an integration-style test would better demonstrate the intended outcome.
```

## 参考

- [2025/08/18: i3DESIGN: AI 時代のクラウドネイティブ開発！ TDD・BDD など 4 つの手法 ×AI 活用を徹底解説](https://www.i3design.jp/in-pocket/15303)

# Spec Kit

- https://github.com/github/spec-kit

## 仕様書駆動開発の考え方

- 憲法（Constitution）を定義するということ
  - AI がコードを生成する際の、絶対に守らなければならない最上位のルールです。
  - そのプロジェクト、あるいは組織全体における「交渉の余地がない不変の原則」を記述します。
  - 例
    - 技術スタック: フロントエンドは必ず Next.js、バックエンドは.NET を使用する。
    - クラウドサービス: デプロイには Azure Functions と Azure CLI のみを使用する。
    - 品質保証: すべての機能には単体テストを記述し、カバレッジは 80%以上を維持する。
    - セキュリティ: 「最小権限の原則」を遵守し、セキュアバイデザインを徹底する。
- 仕様書から考えるということ
  - 仕様書には、Why/What のみを記載し、How（技術的実装方法）は書かない
    - 「What/Why（目的・要件）」を「How（技術的実装方法）」分離する
    - 手段が柔軟に変化できるようにするため
    - 手段が目的化しないようにするため
  - Why
    - アプリケーションの目的は？
    - なぜ私たちはこれを作る必要があるのか？
    - それはどんな問題を解決するのか？
    - 顧客やビジネスにとってどんな価値があるのか？（例：ユーザーがお気に入りのトピックを簡単に見つけられるようにするため）
  - What
    - 具体的に何を作ろうとしているのか？
    - それはどんな機能を持つのか？
    - ターゲットなるユーザは？
    - ユーザーはそれをどのように使うのか？
    - 例
      - ユーザーがエピソードをタグで検索できるポッドキャストの Web サイト
- 計画（Plan）する
  - 仕様が固まったら、次はその仕様を「どのように（How）」実現するかを考えるのが計画（Plan）です。
  - 例えば、「Next.js と TypeScript を使って実装して」といった技術的な指示を与えます。
  - AI は、仕様書（Spec）をインプットとして、具体的なプロジェクト構成、使用するライブラリ、API 設計、テスト方針などを盛り込んだ技術計画書（Plan）を立案します。
- タスクに落とし込み、実装をする
  - 計画をいくつかのタスクに分解し、タスクを一つづつ実施していきます。
  - タスク分割しないと、コンテキストが膨大になってしまうためです。
- 仕様は不変なものではなく、変化するドキュメントであるということ
  - プロジェクトが進む中で要件が変わったりなどした場合は、仕様書を柔軟に更新していきます。
  - 仕様書を更新し、それを元に AI に再度計画やコードを生成させることで、変更に対応していきます。

## Spec Kit とは？

- Spec Kit は、「仕様書駆動開発のためのプロンプトエンジニアリング」をサポートするツールキットです。
- その実態は、カスタムプロンプトとそれをサポートするスクリプト郡です。

## 利用方法

### 1. プロジェクトの初期化

```
$ uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
$ specify init <PROJECT_NAME>
$ specify check
```

その内容としては以下を実施しています。

1. テンプレートの取得
   - 以下の GitHub 上の Spec Kit リポジトリから、最新のテンプレートファイルをダウンロードします。
   - https://github.com/github/spec-kit/releases
2. プロジェクトフォルダの作成
3. ファイルの展開

   - ダウンロードしたテンプレートを、作成したフォルダ内に展開します。
   - これには、仕様書（Spec）、計画書（Plan）、タスクリスト（Tasks）の雛形となるマークダウンファイルや、プロセスを補助するスクリプトなどが含まれます。
   - 例えば、Github Copilot であれば、github/prompts/[command].prompt.md というファイルが配置されており、/[command] [arg] といったコマンドが実行できるようになります。
   - カスタムコマンドを実行すると、プロンプトファイルに引数が挿入されて、AI Agent に最終的なプロンプトとして渡されます。
   - 参考: https://code.visualstudio.com/docs/copilot/customization/prompt-files

### 2. Establish project principles

spec-kit の README だと、以下のようなプロンプトで、.specify/memory/constitution.md を生成しています。

```
/constitution Create principles focused on code quality, testing standards, user experience consistency, and performance requirements
```

しかし、これだとかなり過剰な constitution.md となってしまい、AI Agent にとっても足かせになっていると思います。

コード品質や、テスト駆動開発、ユーザ体験、パフォーマンス、ドキュメンテーションの充実など大事なことが書かれるのですが、目的に合わせてもっとシンプルにすると良いと思います。

特にプロトタイプ開発をやりたいとかだったら、以下みたいなシンプルな constitution.md で良いのではないかと思います。

また、/constitution hoge.. 一回で生成を済まさずに、実際に constitution.md を読んでみて、必要に応じて AI と相談しながら修正して constitution.md をちゃんと練ったほうが良いと思います。

そして、いい感じの constitution.md が生成できたら /constitution コマンドは使わずに、直接 constitution.md を配置するのが良いと思います。

### 3. Specify

```
/specify Build an application that can help me organize my photos in separate photo albums. Albums are grouped by date and can be re-organized by dragging and dropping on the main page. Albums are never in other nested albums. Within each album, photos are previewed in a tile-like interface.
```

### 4. Plan

```
/plan The application uses Vite with minimal number of libraries. Use vanilla HTML, CSS, and JavaScript as much as possible. Images are not uploaded anywhere and metadata is stored in a local SQLite database.
```

### 5. Tasks

```
/tasks
```

### 6. Implement

/implement は、一発で実装完了しない場合もあるため、何度か実行する必要があるかもしれません。

```
/implement
```

## 参考

- [[Claude/Copilot でもスペック駆動開発] Spec Kit for Spec-Driven Development](https://note.com/honest_murre2984/n/n392a36f2f21c)

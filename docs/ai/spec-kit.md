# Spec Kit

https://github.com/github/spec-kit

## メモ

0. インストール

```
$ uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
$ specify init <PROJECT_NAME>
```

1. Establish project principles

spec-kit の README だと、以下のようなプロンプトで、.specify/memory/constitution.md を生成しています。

```
/constitution Create principles focused on code quality, testing standards, user experience consistency, and performance requirements
```

しかし、これだとかなり過剰な constitution.md となってしまい、AI Agent にとっても足かせになっていると思います。

コード品質や、テスト駆動開発、ユーザ体験、パフォーマンス、ドキュメンテーションの充実など大事なことが書かれるのですが、目的に合わせてもっとシンプルにすると良いと思います。

特にプロトタイプ開発をやりたいとかだったら、以下みたいなシンプルな constitution.md で良いのではないかと思います。

また、/constitution hoge.. 一回で生成を済まさずに、実際に constitution.md を読んでみて、必要に応じて AI と相談しながら修正して constitution.md をちゃんと練ったほうが良いと思います。

そして、いい感じの constitution.md が生成できたら /constitution コマンドは使わずに、直接 constitution.md を配置するのが良いと思います。

```
## 3 Core Principles

### 1. Working First (NON-NEGOTIABLE)
**Make it work, then make it better**
- Functionality over perfection
- Iteration speed is the priority

### 2. Small Modules (NON-NEGOTIABLE)
**Design for future testability**
- One module = One responsibility
- Separate business logic from external dependencies

### 3. Progressive Quality
**Prototype → Stabilization → Production**
- No tests required in prototype phase
- Add tests during stabilization
- Full quality gates for production

## Implementation Guidelines

### Error Handling
- Prototype: Basic error handling only
- Stabilization: Add comprehensive error handling

### Documentation
- Module boundaries explanation required only
- Comments for complex logic

### Architecture
- Domain Logic ← Application ← Infrastructure
- Dependencies point inward only

**Version**: 3.0.0 | **Ratified**: 2025-09-25 | **Last Amended**: 2025-09-25
```

2. Specify

```
/specify Build an application that can help me organize my photos in separate photo albums. Albums are grouped by date and can be re-organized by dragging and dropping on the main page. Albums are never in other nested albums. Within each album, photos are previewed in a tile-like interface.
```

```
/plan The application uses Vite with minimal number of libraries. Use vanilla HTML, CSS, and JavaScript as much as possible. Images are not uploaded anywhere and metadata is stored in a local SQLite database.
```

```
/tasks
```

```
/implement
```

---
title: Golang Technology Stack
created: 2026-07-10T08:28:13
lastmod: 2026-07-10T08:28:13
type: permanent
tags:
  - golang
---

# Technology Stack

## Overview

本ドキュメントは、本プロジェクトで推奨するライブラリおよびツールを定義します。

特別な理由がない限り、本ドキュメントで定義された技術を利用してください。

新しいライブラリやツールを導入する場合は、既存の技術で要件を満たせないことを確認した上で検討してください。

---

## Selection Principles

技術選定では、次の原則を優先します。

1. Go Standard Library を優先する
2. シンプルな実装を優先する
3. 実績があり継続的にメンテナンスされている技術を採用する
4. プロジェクト全体で技術を統一する
5. 同じ目的のライブラリを複数採用しない

---

## Alternative Selection Criteria

本ドキュメントで定義された技術以外を採用する場合は、以下を確認してください。

- 定義された技術では必要な要件を満たせない
- 定義された技術では実装が過度に複雑になる
- 性能、可用性、運用性などの非機能要件を満たせない
- プロジェクト固有の要件により別の技術が適している

代替技術を採用する場合は、採用理由を明確にしてください。

---

## CLI

### Library

- github.com/spf13/cobra

### Reason

- GoにおけるCLIライブラリとして広く利用されている
- サブコマンドやヘルプ生成などの機能が充実している
- ドキュメントやサンプルが豊富で保守しやすい

---

## Logging

### Library

- log/slog

### Reason

- Go標準ライブラリであり追加依存が不要
- 構造化ログを標準サポートしている
- 長期的な保守性が高い
- Goの標準APIとして継続的な利用が期待できる

---

## Configuration

### Library

- os
- github.com/goccy/go-yaml

### Reason

- Go標準ライブラリを基本としたシンプルな構成を維持できる
- YAMLの読み書きに必要十分な機能を提供する
- 活発にメンテナンスされている
- APIがシンプルで理解しやすい

---

## HTTP Server

### Library

- github.com/labstack/echo/v4

### Reason

- 高機能なHTTPフレームワークであり開発効率が高い
- MiddlewareやRoutingなどWeb API開発に必要な機能を提供する
- Goコミュニティで広く利用されている

---

## HTTP Client

### Library

- net/http

### Reason

- Go標準ライブラリである
- 多くの用途で十分な機能を提供する
- 外部ライブラリへの依存を減らせる

---

## OpenAPI

### Library

- github.com/oapi-codegen/oapi-codegen

### Reason

- OpenAPI SpecificationからGoコードを生成できる
- API仕様と実装の乖離を防止できる
- 型安全なAPI開発が可能になる
- Go標準のHTTPエコシステムと親和性が高い

---

## Model Context Protocol

### Library

- github.com/modelcontextprotocol/go-sdk

### Reason

- MCP ProtocolをGoで実装するためのSDKである
- Protocol仕様への追従コストを低減できる
- 独自実装を避けることで保守性を向上できる

---

## Database Access

### Library

- database/sql

### Reason

- Go標準ライブラリである
- SQLとの距離が近く理解しやすい
- ORMによる過度な抽象化を避けられる

---

## Database Migration

### Library

- github.com/golang-migrate/migrate/v4

### Reason

- データベースマイグレーションを管理できる
- 複数のデータベースをサポートしている
- Goコミュニティで広く利用されている

---

## Testing

### Library

- testing

### Reason

- Go標準ライブラリである
- Goのツールチェインと完全に統合されている
- シンプルで長期保守性が高い

---

## Assertions

### Library

- github.com/stretchr/testify

### Reason

- 可読性の高いアサーションを記述できる
- Goコミュニティで広く利用されている
- テストコードを簡潔に記述できる

---

## Mocking

### Library

- go.uber.org/mock

### Reason

- golang/mockの後継プロジェクトである
- 活発にメンテナンスされている
- 型安全なMockを生成できる
- Interfaceベースの設計と相性が良い

---

## Validation

### Library

- github.com/go-playground/validator/v10

### Reason

- Goで広く利用されているValidationライブラリである
- Struct tagによる宣言的なValidationを記述できる
- API入力値検証などで利用しやすい

---

## Observability

### Library

- github.com/prometheus/client_golang
- go.opentelemetry.io/otel

### Reason

- PrometheusおよびOpenTelemetryの標準的なGo実装である
- Metrics、TraceなどのObservability機能を統一的に扱える
- クラウドネイティブ環境との親和性が高い

---

## Formatting

### Library

- gofmt
- goimports

### Reason

- Go標準のコードスタイルを維持できる
- import文を自動的に整理できる
- 開発者間でコードスタイルを統一できる

---

## Lint

### Library

- github.com/golangci/golangci-lint

### Reason

- 複数のLintを一元管理できる
- Goコミュニティで広く採用されている
- CIとの統合が容易である
- プロジェクト全体で品質を統一できる

---

## Related

- [[golang_architecture]]
- [[golang_project_structure]]

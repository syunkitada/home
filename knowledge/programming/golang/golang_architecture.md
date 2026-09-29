---
title: Golang Architecture
created: 2026-07-10T08:28:13
lastmod: 2026-07-10T08:28:13
type: permanent
tags:
  - golang
---

# Architecture

## Overview

本知識ベースでは、Layered Architecture と Ports & Adapters の考え方を採用します。

目的は、ビジネスロジックを外部技術から分離し、責務と依存関係を明確にすることで、小規模から大規模まで保守しやすく、テストしやすい構造を維持することです。

設計に迷った場合は、本ドキュメントを最優先の判断基準としてください。

---

## Architecture Overview

本知識ベースでは、次のレイヤ構造を採用します。

```text
            Entrypoint
                 │
                 ▼
           Application
                 │
                 ▼
         Domain (Ports)
                 ▲
                 │
         Infrastructure
```

---

## Layers

### Entrypoint

Entrypoint はアプリケーションの起動と終了を担当します。

Responsibilities

- Process Startup
- Configuration
- Dependency Injection
- CLI
- HTTP Server
- Process Lifecycle

Business Logic は配置しません。

---

### Application

Application はユースケースを実装します。

Responsibilities

- Use Case
- Business Flow
- Validation
- Transaction Control

Application は Domain の Interface のみを利用します。

Infrastructure の実装には依存しません。

---

### Domain

Domain はアプリケーションの中心となるビジネスモデルを定義します。

Responsibilities

- Entity
- Value Object
- Enum
- Error
- Interface (Port)

Domain は他レイヤを知りません。

---

### Infrastructure

Infrastructure は外部システムとの接続を担当します。

Responsibilities

- Adapter
- Database
- External API
- Cache
- Filesystem
- Message Queue

Infrastructure は Domain の Interface を実装します。

---

## Dependency Rules

依存関係は必ず内側へ向かいます。

### Allowed Dependencies

| From           | To          |
| -------------- | ----------- |
| Entrypoint     | Application |
| Application    | Domain      |
| Infrastructure | Domain      |

### Forbidden Dependencies

- Domain → Application
- Domain → Infrastructure
- Application → Infrastructure
- Infrastructure → Application

---

## Domain Interfaces

Application は Domain の Interface を利用します。

Interface は Application が必要とする Capability を表します。

例えば

```go
type DatabaseClient interface {
    GetUser(...)
    SaveUser(...)

    GetOrder(...)
    SaveOrder(...)
}
```

これは

「データベースを操作する」

という一つの責務を表します。

Interface は Entity ではなく Capability を表現してください。

---

## Adapters

Infrastructure は Domain の Interface を実装します。

```text
DatabaseClient
      ▲
      │
MySQLClient
```

```text
KubernetesClient
        ▲
        │
KubernetesAdapter
```

1 Adapter は 1 Interface のみ実装します。

責務が独立した場合のみ、新しい Adapter を追加してください。

---

## Dependency Injection

Dependency Injection は Entrypoint で行います。

Entrypoint が Infrastructure を生成し、Application に渡します。

```text
main

    ↓

MySQLClient

    ↓

Application
```

Application は Interface のみを知ります。

Infrastructure の実装は知りません。

---

## Design Principles

### Single Responsibility

すべての構成要素は、一つの責務だけを持ちます。

例

- 1 Knowledge = 1 Topic
- 1 Skill = 1 Task
- 1 Package = 1 Responsibility
- 1 Interface = 1 Capability
- 1 Adapter = 1 Interface

---

### Start Simple

現在の責務を最もシンプルに表現できる設計を選択してください。

将来必要になるかもしれないという理由だけで、

- Interface
- Package
- Module
- Directory

を追加しません。

---

### Split by Responsibility

責務が十分に大きくなった時点で分割を検討します。

分割の基準は Entity や実装技術ではありません。

Application から見た責務を基準にしてください。

例えば

- DatabaseClient
- KubernetesClient

は、それぞれ一つの責務を表します。

最初から Entity ごとに分割する必要はありません。

---

### Introduce New Abstractions Only When Necessary

新しい抽象は必要になった時点で導入します。

対象

- Directory
- Package
- Module
- Interface
- Adapter

現在の責務を既存の構造で表現できる限り、新しい抽象は追加しません。

---

## Project Evolution

プロジェクトは段階的に成長させます。

### Step 1

既存の構造を利用します。

```
application/
domain/
infrastructure/
```

---

### Step 2

責務が増えたらファイルを分割します。

---

### Step 3

責務が独立したらパッケージを分割します。

---

### Step 4

独立したサブドメインになった場合のみモジュール化します。

```text
internal/

    application/
    domain/
    infrastructure/

    modules/

        monitoring/
            application/
            domain/
            infrastructure/

        inventory/
            application/
            domain/
            infrastructure/
```

モジュールも同じアーキテクチャを採用します。

モジュールはコード量ではなく、責務（Bounded Context）の独立性を基準に導入してください。

---

## Anti-patterns

### Entity ごとに Interface を作る

```text
UserRepository

OrderRepository
```

Entity は Interface の分割基準ではありません。

---

### 1 Adapter が複数 Interface を実装する

Adapter は一つの Interface のみ実装してください。

---

### 将来のためだけに抽象を追加する

必要になるまで、

- Interface
- Package
- Module
- Directory

は追加しません。

---

## Decision Guide

設計に迷った場合は、次の順番で判断してください。

1. この責務はどのレイヤに属するか
2. 既存の Interface で表現できるか
3. 既存の Package に追加できるか
4. 責務が独立したか
5. 必要であれば新しい抽象を導入する

---

## Related

- [[golang_project_structure]]
- [[golang_technology_stack]]

---
title: Golang Project Structure
created: 2026-07-10T08:28:13
lastmod: 2026-07-10T08:28:13
type: permanent
tags:
  - golang
---

# Project Structure

## Overview

本ドキュメントは、本知識ベースで推奨する標準的なプロジェクト構成を定義します。

新規プロジェクトでは、特別な理由がない限り本構成を採用してください。

設計原則については `architecture.md` を参照してください。

---

## Standard Layout

新規プロジェクトは次の最小構成から開始します。

```text
cmd/
    <application>/
        main.go

internal/
    entrypoint/
    application/
    domain/
    infrastructure/
```

この構成で現在の責務を表現できる限り、新しいトップレベルディレクトリは追加しません。

---

## Directory Responsibilities

### cmd

Entrypoint を配置します。

Responsibilities

- main
- CLI
- HTTP Server
- Configuration
- Dependency Injection
- Process Lifecycle

Business Logic は配置しません。

---

### internal/entrypoint

共通のエントリポイントを配置します。

Responsibilities

- Shared Dependency Injection
- Application Bootstrap
- Health Check Endpoints
- Metrics Server
- Module Wiring

Business Logic は配置しません。

例

```text
entrypoint/

    bootstrap.go
    health.go
    wire.go
```

各モジュールのエントリポイントはこのレイヤを介して接続します。

---

### internal/application

Application Layer を配置します。

Responsibilities

- Use Case
- Business Flow
- Validation
- Transaction Control

例

```text
application/

    alert.go
    dashboard.go
    deploy.go
```

---

### internal/domain

Domain Layer を配置します。

Responsibilities

- Entity
- Value Object
- Enum
- Error
- Port

例

```text
domain/

    database_client.go
    kubernetes_client.go
    metrics_client.go

    entity.go
    errors.go
```

Port は Capability 単位で定義します。

---

### internal/infrastructure

Infrastructure Layer を配置します。

Responsibilities

- Adapter
- Database
- External API
- Cache
- Filesystem
- Message Queue

例

```text
infrastructure/

    mysql/
        client.go

    kubernetes/
        client.go

    prometheus/
        client.go

    grafana/
        client.go
```

各 Adapter は 1 Port のみ実装します。

---

## Package Structure

パッケージは責務単位で構成します。

例

```text
infrastructure/

    mysql/
    kubernetes/
    prometheus/
```

責務が変わらない限り、新しいパッケージは作成しません。

---

## File Structure

1ファイル1責務を推奨します。

例

```text
domain/

    database_client.go
    kubernetes_client.go

    entity.go
    errors.go
```

```text
infrastructure/

    mysql/
        client.go
```

ファイルサイズではなく、責務を分割基準としてください。

---

## Project Evolution

プロジェクトは段階的に成長させます。

### Step 1

まずは既存のレイヤへ追加します。

```text
application/
domain/
infrastructure/
```

---

### Step 2

責務が増えたらファイルを分割します。

```text
domain/

    metrics_client.go
    dashboard_client.go
```

---

### Step 3

責務が独立したらパッケージを分割します。

```text
infrastructure/

    mysql/
    postgres/
```

---

### Step 4

独立したサブドメインになった場合のみモジュール化します。

モジュールは `internal/modules` 配下に配置します。

```text
internal/
    entrypoint/
    application/
    domain/
    infrastructure/

    modules/
        monitoring/
            entrypoint/
            application/
            domain/
            infrastructure/

        inventory/
            entrypoint/
            application/
            domain/
            infrastructure/
```

各モジュールも標準の Layered Architecture を採用します。

トップレベルの `application`・`domain`・`infrastructure` は、モジュールに属さない共通機能を配置します。

モジュールはコード量ではなく、責務（Bounded Context）の独立性を基準に導入してください。

---

## Additional Directories

新しいトップレベルディレクトリは、既存のレイヤでは責務を適切に表現できなくなった場合のみ追加します。

例えば、

```text
migration/
scripts/
docs/
```

などは、独立した責務として成立した場合のみ追加してください。

「将来必要になるかもしれない」という理由だけで追加しません。

---

## Shared Libraries

共通ライブラリ専用のディレクトリは最初から作成しません。

例えば、

```text
lib/
common/
shared/
utils/
helpers/
```

は標準構成には含めません。

まずは適切なレイヤへ配置してください。

既存のレイヤで責務を表現できなくなった場合のみ、新しいディレクトリを追加します。

---

## Anti-patterns

### Entity ごとにパッケージを作る

```text
user/
order/
product/
```

Entity ではなく責務で整理してください。

---

### utils を作る

```text
utils/
```

責務が曖昧になるため作成しません。

---

### common を作る

```text
common/
```

共通化を目的としたディレクトリは作成しません。

---

### helpers を作る

```text
helpers/
```

責務が曖昧になるため作成しません。

---

### 将来のためだけにトップレベルディレクトリを追加する

責務が明確になるまで追加しません。

---

## Decision Guide

新しいディレクトリやパッケージを追加する前に、次の順番で判断してください。

1. 既存のレイヤへ配置できるか
2. 既存のパッケージへ追加できるか
3. 責務が独立したか
4. パッケージを分割すべきか
5. モジュール化すべきか
6. 新しいトップレベルディレクトリが必要か

---

## Related

- [[golang_architecture]]
- [[golang_technology_stack]]

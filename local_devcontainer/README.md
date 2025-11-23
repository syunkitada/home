# Local Dev Container

## Background

Windows 環境で 開発用の Linux 環境を利用する手段として、以下の２つがあります。

- Rancher Desktop を利用してコンテナ環境を利用する方法（推奨）
  - 環境がステートレスで、必要なツールなどは Dockerfile にまとめることになるので、環境の再現性があります。
- Ubuntu を WSL2 上で利用する方法
  - 環境がステートフルで、一度インストールしたパッケージなどを流用できるが、ゴミも残ります。
  - 楽ではありますが、環境の再現性がありません。

## 1. devcontainer 事に volume を作成する

```
$ docker volume create local-dev01
$ docker volume create local-dev02
```

## 2. docker compose up

```
$ docker compose up -d
```

## 3. VSCode

File -> Save Workspace As ..

```
/root/workspace/dev01.code-workspace
```

Open Folder

```
/root/workspace
```

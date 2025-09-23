# Local Dev Container

## Background

Windows 環境で 開発用の Linux 環境を利用する手段として、以下の２つがあります。

- Ubuntu を WSL2 上で利用する
- Rancher Desktop を利用してコンテナ環境を利用する

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

# Local Dev Container

- ローカルで開発用のLinux環境を利用するためのコンテナ環境です。
- Windows 環境で 開発用の Linux 環境を利用する手段として、以下の２つがあります。
  - Rancher Desktop を利用してコンテナ環境を利用する方法
    - 環境がステートレスで、必要なツールなどは Dockerfile にまとめることがほぼ強制され、環境の再現性が高くなりやすい。
    - Rancher Desktopの仕組み
      - Rancer Desktopを起動すると、WSL2で専用の仮想マシンを実行され、その中ではMoby（Docker互換のOSS）が動作しています。
      - これによりコマンドプロンプトからソケット経由でdockerコマンド、docker composeコマンドが利用できます。
  - Ubuntu を WSL2 で利用する方法
    - 環境がステートフルで、一度インストールしたパッケージなどを流用できるメリットがありますが、ゴミも残ります。
    - パッケージ管理などをしなくても良いのは楽ではありますが、環境の再現性が低くなりやすいです。
- 環境の再現性つまり環境をコードとして残すことを目的とし、コンテナ環境を利用するようにしています。

## 前提

- Rancherを利用します。
  - https://rancherdesktop.io/
  - コンテナエンジンは、Dockerを選択します。
- VSCodeのDevContainersを利用します。
  - https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers

## 1. devcontainer 事に volume を作成する

このボリュームを/root(homeディレクトリ)にマウントし、データを永続化します。

```
$ docker volume create local-dev01
```

## 2. docker compose up

```
$ docker compose up -d
[+] Running 1/1
 ✔ Container local-dev01  Started
```

## 3. Initialize Home Directory in local-dev01

```
$ docker exec -it local-dev01 bash
[root@local-dev01 /]# cd

# Setup my home directory
[root@local-dev01 ~]# git clone https://github.com/syunkitada/home.git
[root@local-dev01 /]# cd home
[root@local-dev01 /]# make
...
----------------------------------------------------------------------------------------------------
Setup Complete!
----------------------------------------------------------------------------------------------------

# Create workspace directory for VSCode
[root@local-dev01 /]# mkdir workspace

# Complete
[root@local-dev01 /]# exit
```

## 4. VSCode

`REMOTE EXPLORER/Dev Containers/local-dev01` の　`Attach in New Windows` をクリックし、local-dev01上で新しいWindowを開く。

`File -> Save Workspace As ..` で/root/workspaceをワークスペースとして保存する。

```
/root/workspace/dev01.code-workspace
```

`Open Folder` で/root/workspaceを Workspaceとして開く。

```
/root/workspace
```

/root/workspace/dev01.code-workspace には、以下のように記述しタイトルバーの色だけ変えておきます。
```
{
	"folders": [
		{
			"path": "."
		}
	],
	"settings": {
		"workbench.colorCustomizations": {
			"titleBar.activeBackground": "#0055ff",
			"titleBar.activeForeground": "#FFFFFF"
		},
	}
}
```

## 5. Docker in Container

```
$ systemctl start docker
$ docker run hello-world
```
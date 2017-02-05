# Docker

## install docker

### ubuntu
``` bash
# ubuntu 16
# show https://docs.docker.com/engine/installation/linux/ubuntu/
$ docker -v
Docker version 1.13.0, build 49bf474
```

### centos
``` bash
$ sudo yum install docker-engine
$ sudo systemctl start docker
$ sudo systemctl enable docker
```

## hello world
以下のコマンドにより、イメージを起動することができる
また、ローカルにイメージがなければ、イメージをDockerHubよりダウンロードして利用する
``` bash
$ sudo docker run -i -t ubuntu:14.04
root@478de01cf936:/# uname -a
Linux 478de01cf936 3.16.0-49-generic #65~14.04.1-Ubuntu SMP Wed Sep 9 10:03:23 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux
```

## 基本コマンド
``` bash
# イメージの一覧
$ docker images

# イメージの削除
$ docker rmi -f [image]

# コンテナの削除
$ docker rm -f [container]

# コンテナの一覧（起動中のみ）
$ docker ps

# コンテナの一覧（全一覧）
$ docker ps -a

$ sudo docker exec -it web0002 /bin/bash
```

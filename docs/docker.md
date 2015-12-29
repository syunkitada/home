# Docker

## install docker

``` bash
# ubuntu 14
$ sudo apt-get install docker.io

$ docker -v
Docker version 1.6.2, build 7c8fca2
```

## hello world
以下のコマンドにより、イメージを起動することができる
また、ローカルにイメージがなければ、イメージをDockerHubよりダウンロードして利用する
``` bash
$ sudo docker run -i -t ubuntu:14.04
root@478de01cf936:/# uname -a
Linux 478de01cf936 3.16.0-49-generic #65~14.04.1-Ubuntu SMP Wed Sep 9 10:03:23 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux
```

``` bash
# イメージの削除
$ docker rmi -f [image]

# コンテナの削除
$ docker rm -f [container]
```

## docker build
Dockerfile(構成内容を記述したテキストファイル)を用意し、$ docker build というコマンドでイメージを作成することができる。

主な命令表
```
｛命令｝    メモ
FROM        元となるDockerイメージの指定
MAINTAINER  作成者の情報
RUN         コマンドの実行
ADD         ファイル／ディレクトリの追加
CMD         コンテナーの実行コマンド 1
ENTRYPOINT  コンテナーの実行コマンド 2
WORKDIR     作業ディレクトリの指定
ENV         環境変数の指定
USER        実行ユーザーの指定
EXPOSE      ポートのエクスポート（ポートの開放）
VOLUME      ボリュームのマウント
```

以下、centosにsshdをインストールして利用する例
``` bash
$ vim DockerFile

FROM centos

# Install
RUN yum update -y
RUN yum install -y sudo
RUN yum install -y passwd
RUN yum install -y openssh-server
RUN yum install -y openssh-clients

RUN /usr/bin/ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -C '' -N ''
RUN /usr/bin/ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N ''
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

RUN echo 'root:root' |chpasswd
RUN sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config

EXPOSE 22


# create image
$ sudo docker build -f Dockerfile -t test-sshd .

$ sudo docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
test-sshd           latest              3aef64b848ff        11 minutes ago      295.5 MB
centos              latest              60e65a8e4030        4 days ago          196.6 MB
ubuntu              14.04               d55e68e6cc9c        2 weeks ago         187.9 MB

# コンテナを起動する
# docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
# -d はバックグラウンドでcontainerを起動する
# -p 22 は22ポートにポートフォワーディングできるようにする
# [COMMAND] /usr/sbin/sshd -D で、sshdをデーモン起動する
$ sudo docker run -d -p 22 test-sshd /usr/sbin/sshd -D

# 確認
# docker ps は起動中のcontainer一覧を表示する
# docker pa -a とすると、全container一覧を表示する
$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND               CREATED             STATUS              PORTS                   NAMES
b40230dcb3f0        test-sshd:latest    "/usr/sbin/sshd -D"   9 minutes ago       Up 9 minutes        0.0.0.0:32768->22/tcp   admiring_poincare

$ ssh root@localhost -p 32768
#
```

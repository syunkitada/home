# image

## イメージの作成方法
* 既存イメージから起動したコンテナからイメージを作成する
* Dockerfileを定義してイメージを作成する

## 既存イメージから起動したコンテナからイメージを作成する
既存イメージから作成したコンテナを作成するアップデートして、commitする。
```
# Dockerのイメージのpull
$ sudo docker pull training/sinatra

# イメージからコンテナを起動
$ sudo docker run -t -i training/sinatra /bin/bash

# コンテナに変更を加えてexit
root@e8041e6701f3:/# echo 'Helloworld' > /tmp/helloworld
root@e8041e6701f3:/# cat /tmp/helloworld
Helloworld
root@e8041e6701f3:/# exit
exit

# コミット
$ sudo docker commit -m 'Add helloworld' -a syunkitada e8041e6701f3 syunkitada/sinatra:v2
sha256:364e549956cc900767f544666edf14e69a80010cce547b83ab98a4f85649c303

$ sudo docker images
REPOSITORY                    TAG                 IMAGE ID            CREATED             SIZE
syunkitada/sinatra            v2                  364e549956cc        50 seconds ago      447 MB

$ sudo docker run -t -i syunkitada/sinatra:v2 /bin/bash
root@47d320c43833:/# cat /tmp/helloworld
Helloworld
```

## Dockerfileからイメージを作成する
Dockerfile(構成内容を記述したテキストファイル)を用意し、
$ docker build というコマンドでイメージを作成する。

### 主な命令表
```
｛命令｝    メモ
FROM        元となるDockerイメージの指定
MAINTAINER  作成者の情報
RUN         コマンドの実行(イメージ作成時に実行するコマンド）
ADD         ファイル／ディレクトリの追加
CMD         コンテナーの実行コマンド 1(コンテナ作成時に実行するコマンド)
ENTRYPOINT  コンテナーの実行コマンド 2
WORKDIR     作業ディレクトリの指定
ENV         環境変数の指定
USER        実行ユーザーの指定
EXPOSE      ポートのエクスポート（ポートの開放）
VOLUME      ボリュームのマウント
```

```
# Dockerfileを作成する
$ vim Dockerfile
...

# イメージの作成
$ sudo docker build -f ./Dockerfile -t centos:test .

# イメージからコンテナを起動
$ sudo docker run -itd -p 8080:80 --name test centos:test

# イメージの削除
$ sudo docker rmi centos:test
```

### 例: httpdを起動するCentOSイメージ
* dockerではsystemdを使うことができないのでバイナリを直接指定でデーモンを起動する必要がある
* 無理やりsystemdを使うことはできる
```
FROM centos:centos7

ENV container docker

RUN yum install -y iproute httpd && yum clean all
RUN echo "Hello Apache." > /var/www/html/index.html

EXPOSE 80
ENTRYPOINT ["/usr/sbin/httpd","-DFOREGROUND"]
```

### 例: httpdとmysqlを起動するCentOSイメージ
* 一つのコンテナで複数のプロセスを起動したい場合、supervisorを使うことが推奨される
```
FROM centos:centos7

ENV container docker

RUN yum install epel-release -y
RUN yum install http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm -y
RUN yum install -y supervisor httpd mysql-server
RUN echo "Hello Apache." > /var/www/html/index.html

RUN /usr/bin/mysql-systemd-start pre

RUN touch /etc/supervisord.conf
RUN echo '[supervisord]'  >> /etc/supervisord.conf
RUN echo 'nodaemon=true'  >> /etc/supervisord.conf
RUN echo '[program:httpd]'              >> /etc/supervisord.conf
RUN echo 'command=/usr/sbin/httpd'      >> /etc/supervisord.conf
RUN echo '[program:mysql]'              >> /etc/supervisord.conf
RUN echo 'command=/usr/bin/mysqld_safe' >> /etc/supervisord.conf

EXPOSE 80
EXPOSE 3306

CMD /usr/bin/supervisord -c /etc/supervisord.conf
```

### 例: sshdを起動するCentOSイメージ
```
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

ENTRYPOINT ["/usr/sbin/sshd", "-D"]
```


## Dockerhubにイメージをpushする
Dockerhubでアカウント登録し、リポジトリを作成する
https://hub.docker.com/


```
# ログイン
$ sudo docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: syunkitada
Password:
Login Succeeded

# push
$ sudo docker push syunkitada/sinatra
The push refers to a repository [docker.io/syunkitada/sinatra]
3a51ea550bae: Pushed
d31b1b3688ec: Pushed
859d050b8423: Pushed
5f70bf18a086: Pushed
9164c306cc0a: Pushed
8396c878c66c: Pushed
3ee39e78fd25: Pushed
138331e9552c: Pushed
v2: digest: sha256:1b62710e32ef1b6ce5c695e451b2ad0e697b75c854595bf776dcd1a11bc55ffa size: 2199
```

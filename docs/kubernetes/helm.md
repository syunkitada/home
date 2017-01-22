# Helm
Helmとは、Kubernetesのサービスやポッドをデプロイするためのパッケージマネージャです。

## 用語集
| 用語 | 説明 |
| --- | --- | --- |
| helm(舵) | yum, aptに相当するパッケージマネージャ。 |
| tiller(舵柄) | デプロイを担うサーバコンポーネント。 |
| chart(海図) | dep, rpmに相当するパッケージ。Kubernetesのマニフェストのテンプレートをまとめたもの |


## helmのインストール
バイナリが、Githubに置いてあるので、ダウンロードして適当なところに置く(/usr/bin/ など)
https://github.com/kubernetes/helm/releases

## tillerの起動とホームの初期化
以下の$HOME/.helmの作成、およびtillerのデプロイ(kube-system)を行ってくれる。
```
# クライアントとサーバの初期化を行う
$ helm init

$ ls .helm
plugins  repository  starters

$ kubectl get deployment tiller-deploy -n kube-system
NAME            DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
tiller-deploy   1         1         1            1           2h
```

## chartの作成
以下の手順でサンプルchart(nginx)を作成できる。
```
$ helm create mychart
$ ls mychart
Chart.yaml    # パッケージのメターデータ
charts        # 他のchart(依存するものなど）をこの中に入れ子で配置することができる
templates     # manifestのテンプレート群、これを使ってデプロイされます。
values.yaml   # templateに埋め込む変数を定義できる(helmのインストール時に上書き可能）

# パッケージング化
$ helm package mychart
$ ls
mychart  mychart-0.1.0.tgz

# シンタックスチェック
$ helm lint mychart
```

## chartをインストールしてリリースを作成する
```
# charをインストール
$ helm install mychart

# リリースの一覧
$ helm list
NAME                    REVISION        UPDATED                         STATUS          CHART
oldfashioned-gibbon     1               Sun Jan 15 09:04:23 2017        DEPLOYED        mychart-0.1.0

$ kubectl get svc
NAME                       CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes                 10.3.0.1     <none>        443/TCP   3h
oldfashioned-gibbon-mych   10.3.0.90    <none>        80/TCP    41m

$ curl 10.3.0.90
...
```

## リポジトリからchartをインストール
```
# chartの検索
$ helm search
...
stable/mysql            0.2.3   Chart for MySQL
...

# chartのインストール（リポジトリから）
$ helm install stable/mysql

# リポジトリからchartのダウンロードして中身を見る
$ helm fetch stable/mysql
$ tar xf mysql-0.2.3.tgz
$ ls mysql
Chart.yaml  README.md  templates  values.yaml
```

## リリースのupgrade, history, rollback
```
# バージョンを上げてみる
$ vim mychart/Chart.yaml
apiVersion: v1
description: A Helm chart for Kubernetes
name: mychart
< version: 0.1.0
> version: 0.1.1

$ helm list
NAME                    REVISION        UPDATED                         STATUS          CHART
tufted-butterfly        1               Sun Jan 15 10:06:16 2017        DEPLOYED        mychart-0.1.0

$ helm upgrade tufted-butterfly mychart

$ helm list
NAME                    REVISION        UPDATED                         STATUS          CHART
tufted-butterfly        2               Sun Jan 15 10:20:46 2017        DEPLOYED        mychart-0.1.1


# 変数を更新してpodを増やしてみる
$ kubectl get pods
NAME                                        READY     STATUS    RESTARTS   AGE
tufted-butterfly-mychart-1502860468-nkslx   1/1       Running   0          15m

$ helm upgrade tufted-butterfly mychart --set replicaCount=2
$ kubectl get pods
NAME                                        READY     STATUS    RESTARTS   AGE
tufted-butterfly-mychart-1502860468-g1zdd   1/1       Running   0          15s
tufted-butterfly-mychart-1502860468-nkslx   1/1       Running   0          16m

$ helm list
NAME                    REVISION        UPDATED                         STATUS          CHART
tufted-butterfly        3               Sun Jan 15 10:22:44 2017        DEPLOYED        mychart-0.1.1


# リリースのhistoryを表示
$ helm history tufted-butterfly
REVISION        UPDATED                         STATUS          CHART
1               Sun Jan 15 10:06:16 2017        SUPERSEDED      mychart-0.1.0
2               Sun Jan 15 10:20:46 2017        SUPERSEDED      mychart-0.1.1
3               Sun Jan 15 10:22:44 2017        DEPLOYED        mychart-0.1.1


# podをREVISION 1 までロールバックする
$ helm rollback tufted-butterfly 1

$ helm history tufted-butterfly
REVISION        UPDATED                         STATUS          CHART
1               Sun Jan 15 10:06:16 2017        SUPERSEDED      mychart-0.1.0
2               Sun Jan 15 10:20:46 2017        SUPERSEDED      mychart-0.1.1
3               Sun Jan 15 10:22:44 2017        SUPERSEDED      mychart-0.1.1
4               Sun Jan 15 10:25:52 2017        DEPLOYED        mychart-0.1.0

$ helm list
NAME                    REVISION        UPDATED                         STATUS          CHART
tufted-butterfly        4               Sun Jan 15 10:25:52 2017        DEPLOYED        mychart-0.1.0

$ kubectl get pods
NAME                                        READY     STATUS    RESTARTS   AGE
tufted-butterfly-mychart-1502860468-nkslx   1/1       Running   0          20m
```

## 参考
* [quickstart](https://github.com/kubernetes/helm/blob/master/docs/quickstart.md)
* [charts](https://github.com/kubernetes/helm/blob/master/docs/charts.md)
* [Kubernetes Helmとは](http://qiita.com/tkusumi/items/12857780d8c8463f9b9c)
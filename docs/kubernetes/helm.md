# Helm
Helmとは、Kubernetesのサービスやポッドをデプロイするためのパッケージマネージャです。

## Index
* [Glossary](#glossary)
* [Install Helm](#install-helm)
* [Create Service Account for Tiller](#create-service-account-for-tiller)
* [Create Chart](#create-chart)
* [Install Chart from repository](#install-chart-from-repository)
* [upgrade, history, rollback for Resource](#upgrade-history-rollback-for-resource)
* [Operation](#operation)
* [Reference](#reference)

## Glossary
| 用語 | 説明 |
| --- | --- |
| helm(舵) | yum, aptに相当するパッケージマネージャ。 |
| tiller(舵柄) | デプロイを担うサーバコンポーネント。 |
| chart(海図) | dep, rpmに相当するパッケージ。Kubernetesのmanifestのテンプレートをまとめたもの |


## Install Helm
バイナリが、Githubに置いてあるので、ダウンロードして適当なところに置く(/usr/bin/ など)
https://github.com/kubernetes/helm/releases

## Initialize Helm and Install Tiller
以下の$HOME/.helmの作成、およびtillerのデプロイ(kube-system)を行ってくれる。
```
$ wget https://storage.googleapis.com/kubernetes-helm/helm-v2.4.2-linux-amd64.tar.gz
$ tar -xf helm-v2.4.2-linux-amd64.tar.gz
$ sudo mv linux-amd64/helm /usr/local/bin/

# クライアントとサーバの初期化を行う
$ helm init

$ ls .helm
plugins  repository  starters

$ kubectl get deployment tiller-deploy -n kube-system
NAME            DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
tiller-deploy   1         1         1            1           2h
```

## Create Service Account for Tiller
* Kubernetes v1.6 以上でRBACを使用している場合に必要
* kubeadmでKubernetesを設定した場合にRBACによりtillerがKubernetesのリソースにアクセスできない
* helm init後に、以下の手順でtiller-deployにサービスアカウントを設定する必要がある
``` bash
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl edit deploy --namespace kube-system tiller-deploy #and add the line 'serviceAccount: tiller' to spec/template/spec
```

## Create Chart
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

## Install Chart from repository
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

## upgrade, history, rollback for Resource
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

## Memo
* ConfigMapの肥大化に注意する
    * TillerはREVISION情報の一つ一つをすべてConfigMapで管理している
    * ConfigMapは、一つのNamespaceでの管理数が大量(500以上)になると、その取得自体が重くなってくる
    * 実際の運用では、ConfigMapが肥大化する前に古いREVISIONを定期的に削除する仕組みが必要
* TillerのNamespace管理
    * helm initでは、kube-system NamespaceでTillerのService, Deploymentが作成されるが、他のNamespaceで作成することも可能
    * --tiller-namespace オプションにより、どのNamespace上のTillerを利用するかを選択できる
        * 例: helm list --tiller-namespace [namespace]
* Go template
    * https://golang.org/pkg/text/template/
    * http://masterminds.github.io/sprig/

## Reference
* [quickstart](https://github.com/kubernetes/helm/blob/master/docs/quickstart.md)
* [charts](https://github.com/kubernetes/helm/blob/master/docs/charts.md)
* [Kubernetes Helmとは](http://qiita.com/tkusumi/items/12857780d8c8463f9b9c)

# CondigMap

* [リファレンス](https://kubernetes.io/docs/user-guide/configmap/)
* 設定情報を扱うためのリソース
    * 設定情報はkey-valueで管理される
* Podの環境変数、コンテナの引数、Volume(ファイル）として扱うことができる
* ConfigMapを更新すると、Podの環境変数、Volumeも自動で更新される
    * サービスを自動リロードするような仕組みはないので、Gracefull Reloadのような仕組みを実現したい場合は、Pod内でファイルを監視してreloadする仕組みが必要

## ConfigMapの作成
ConfigMapの作成方法
* kubectl create -f [yaml or json]
* kubectl create configmap [name] --from-file=[key]=[filepath] --from-file=[filepath] --from-file=[directory] .. --from-literal [key=value] ...
  * --from-fileオプション: 配置したいファイルやディレクトリを指定する
    * ファイル名もしくは指定されたkeyにファイルのテキストが設定される
  * --from-literalオプション: key=valueを直接指定する

以下、kubectl create -f [yaml] でConfigMapを作成する例
``` bash
$ cat << EOS > nginx-cm.yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: nginx
  namespace: default
data:
  example.property.1: hello
  example.property.2: world
  index.html: |-
    helloworld.

    hoge piyo.
EOS

$ kubectl create -f nginx-cm.yaml

$ kubectl get cm nginx -o yaml
apiVersion: v1
data:
  example.property.1: hello
  example.property.2: world
  index.html: |-
    helloworld.

    hoge piyo.
kind: ConfigMap
metadata:
  creationTimestamp: 2017-01-22T11:32:08Z
  name: nginx
  namespace: default
  resourceVersion: "39897"
  selfLink: /api/v1/namespaces/default/configmaps/nginx
  uid: 6861da05-e096-11e6-9a6d-00163e371dc9
```

## PodからConfigMapを利用する
ConfigMapは環境変数に設定するか、Volumeとしてマウントすることができる

``` bash
$ cat << EOS > nginx-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  volumes:
    - name: nginx-html
      configMap:
        name: nginx

  containers:
    - name: nginx
      image: nginx
      ports:
        - containerPort: 80
      volumeMounts:
        - name: nginx-html
          mountPath: /usr/share/nginx/html
      env:
        - name: NGINX
          valueFrom:
            configMapKeyRef:
              name: nginx
              key: example.property.1
EOS

$ kubectl create -f nginx-pod.yaml

$ kubectl exec nginx env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=nginx
NGINX=hello
...

$ kubectl exec nginx ls /usr/share/nginx/html
example.property.1
example.property.2
index.html

$ kubectl get pods -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP             NODE
nginx     1/1       Running   0          1m        192.168.0.74   192.168.122.132


$ curl 192.168.0.74
helloworld.

hoge piyo.

```

## ConfigMapの更新
edit, applyで更新可能
``` bash
$ kubectl edit cm nginx

$ kubectl apply -f nginx-cm.yaml
```

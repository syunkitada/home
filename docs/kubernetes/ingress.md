# Ingress

Ingressは、L7ロードバランサの機能を提供します。

## Index
* [Glossary](#glossary)
* [Install Helm](#install-helm)


## Glossary
| 用語 | 説明 |
| --- | --- |
| Ingress Resource | Ingressを設定するためのリソース |
| Incress Controller | Podとしてデプロイされるデーモンで、Ingress Resourceが更新されるのを監視し、Ingressの設定を行う |
| Ingress | IngressはL7ロードバランサ(Nnginx, Haproxyなどの実装がある) |


## Create Service Account for Ingress Controller
```
kubectl create serviceaccount --namespace kube-system ingress
kubectl create clusterrolebinding ingress-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:ingress
```


## Setup Ingress Default Backend
* Ingressにアクセスされた時、ルーティングすべきサービスがない場合に利用されるデフォルトサーバ
* 実態は404を返すだけのサーバです
``` bash
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: default-http-backend
  labels:
    k8s-app: default-http-backend
  namespace: kube-system
spec:
  replicas: 1
  template:
    metadata:
      labels:
        k8s-app: default-http-backend
    spec:
      terminationGracePeriodSeconds: 60
      containers:
      - name: default-http-backend
        # Any image is permissable as long as:
        # 1. It serves a 404 page at /
        # 2. It serves 200 on a /healthz endpoint
        image: gcr.io/google_containers/defaultbackend:1.0
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 30
          timeoutSeconds: 5
        ports:
        - containerPort: 8080
        resources:
          limits:
            cpu: 10m
            memory: 20Mi
          requests:
            cpu: 10m
            memory: 20Mi
---
apiVersion: v1
kind: Service
metadata:
  name: default-http-backend
  namespace: kube-system
  labels:
    k8s-app: default-http-backend
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    k8s-app: default-http-backend
```


## Setup Ingress Controller
* Ingress Controllerの起動バイナリ: ./nginx-ingress-controller
    * 起動オプションでデフォルトバックエンドを指定します: --default-backend-service=kube-system/default-http-backend
* Controllerは、このPod内でNginxプロセスを起動します
* Controllerは、Ingress Resourceを監視し、変更があった場合にそのルールに従ってNginxのConfigを書き換えリロードします
* ユーザはこのNginxにアクセスし、バックグラウンドのコンテンツにアクセスすることになります

``` bash
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-ingress-controller
  labels:
    k8s-app: nginx-ingress-controller
  namespace: kube-system
spec:
  replicas: 1
  template:
    metadata:
      labels:
        k8s-app: nginx-ingress-controller
      annotations:
        prometheus.io/port: '10254'
        prometheus.io/scrape: 'true'
    spec:
      serviceAccount: ingress
      terminationGracePeriodSeconds: 60
      containers:
      - image: gcr.io/google_containers/nginx-ingress-controller:0.9.0-beta.5
        name: nginx-ingress-controller
        readinessProbe:
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
        livenessProbe:
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
          initialDelaySeconds: 10
          timeoutSeconds: 1
        ports:
        - containerPort: 80
          hostPort: 80
        - containerPort: 443
          hostPort: 443
        env:
          - name: POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
        args:
        - /nginx-ingress-controller
        - --default-backend-service=$(POD_NAMESPACE)/default-http-backend
```


## Create sample server
* 実験用にサンプルのWebサーバを作成します
```
cat << EOS > nginx.yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: helloworld-rc
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: helloworld-nginx
    spec:
      containers:
      - name: helloworld
        image: nginx
        ports:
        - containerPort: 80

---

apiVersion: v1
kind: Service
metadata:
  name: helloworld-svc
spec:
  selector:
    app: helloworld-nginx
  ports:
  - name: http
    port: 80
    protocol: TCP
EOS

kubectl apply -f nginx.yaml
```


## Create Ingress
* サンプルサーバへアクセスするためのIngressを作成します
```
$ cat << EOS > ingress.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test
spec:
  rules:
  - host: foo.example.co.jp
    http:
      paths:
      - backend:
          serviceName: testsvc
          servicePort: 80
EOS

$ kubectl apply -f ingress.yaml

$ kubectl get ing
NAME      HOSTS               ADDRESS           PORTS     AGE
test      foo.example.co.jp   192.168.122.132   80, 443   6h

# ホストを/etc/hostsに登録すると、アクセスできます
$ echo '192.168.122.132 foo.example.co.jp' >> /etc/hosts

$ curl https://foo.example.co.jp
<h1>Welcome to nginx!</h1>
```

* また、IngessController Pod内では、nginx.confが以下のように書き換わります
* バックエンドとして設定したServiceのPodが直接バックエンドサーバとして登録されています
```
    server {
        server_name foo.bar.com;
        listen 80;
        listen [::]:80;

        location / {
            set $proxy_upstream_name "default-testsvc-80";

    upstream default-testsvc-80 {
        least_conn;
        server 192.168.248.69:80 max_fails=0 fail_timeout=0;
        server 192.168.248.70:80 max_fails=0 fail_timeout=0;
    }

    upstream upstream-default-backend {
        least_conn;
        server 192.168.248.68:8080 max_fails=0 fail_timeout=0;
    }
```


## Create TLS Ingress
```
# create TLS certificate
$ cat << EOS > openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.hoge.co.jp
DNS.2 = *.piyo.co.jp
EOS

$ openssl genrsa -out server.key 4096
$ openssl req -new -key server.key -out server.csr -subj "/CN=*.example.co.jp" -config openssl.cnf
$ openssl x509 -days 365 -req -signkey server.key -in server.csr -out server.crt

# create TLS Secret Resource
$ kubectl create secret tls tls-certificate --key server.key --cert server.crt


# create TLS Ingress
$ cat << EOS > ingress.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test
spec:
  tls:
    - secretName: tls-certificate
      hosts:
        - foo.example.co.jp
  rules:
  - host: foo.example.co.jp
    http:
      paths:
      - backend:
          serviceName: testsvc
          servicePort: 80
EOS

$ kubectl apply -f ingress.yaml

$ curl https://foo.example.co.jp --insecure
<h1>Welcome to nginx!</h1>
```

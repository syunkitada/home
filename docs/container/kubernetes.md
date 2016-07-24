# Kubernetes

## Config of kubectl
``` bash
$ kubectl config set-credentials myself --username=admin --password=admin \
kubectl config set-cluster local-server --server=http://localhost:8080 \
kubectl config set-context default-context --cluster=local-server --user=myself \
kubectl config use-context default-context \
kubectl config set contexts.default-context.namespace default \
```

## Helloworld
``` bash
$ vim httpd.yaml
apiVersion: v1
kind: Pod
metadata:
  name: httpd
    labels:
      app: httpd
      spec:
        containers:
        - name: httpd
          image: httpd
          ports:
          - containerPort: 80

$ kubectl create -f httpd.yaml

$ kubectl get pods
NAME                  READY     STATUS             RESTARTS   AGE
httpd                 1/1       Running            0          29m

$ kubectl get pod httpd -o yaml
...
  hostIP: 192.168.122.51
  phase: Running
  podIP: 10.20.47.3

$ curl 10.20.47.3
<html><body><h1>It works!</h1></body></html>

$ vim httpd-rc.yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: httpd-rc
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: httpd
        tier: frontend
    spec:
      containers:
      - name: httpd
        image: httpd
        ports:
        - containerPort: 80

$ kubectl create -f httpd-rc.yaml
$ kubectl get replicationcontroller
NAME       DESIRED   CURRENT   AGE
httpd-rc   2         2         5m

$ kubectl get pod
NAME             READY     STATUS    RESTARTS   AGE
httpd-rc-39ue0   1/1       Running   0          6m
httpd-rc-fj3nh   1/1       Running   0          6m


$ vim httpd-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: httpd-service
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 30080
  selector:
    app: httpd
    tier: frontend

$ kubectl get service
NAME            CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
httpd-service   10.254.121.16   nodes         80/TCP    1m

$ curl 192.168.122.51:30080
<html><body><h1>It works!</h1></body></html>
```

## Reference
* [Kubernetes を使ったマルチホスト環境でのクラスタを構築する【基礎編】](http://christina04.hatenablog.com/entry/2016/05/25/011129)
* [Kubernetes を使ったマルチホスト環境でのクラスタを構築する【flannel編】](http://christina04.hatenablog.com/entry/2016/05/26/193000)
* [kubernetesによるDockerコンテナ管理入門] (http://knowledge.sakura.ad.jp/tech/3681/)
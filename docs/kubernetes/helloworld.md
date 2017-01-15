# Helloworkd

## ReplicationController, Service リソースを作成するための定義ファイルを作成する
``` bash
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

```

## デプロイ
```
$ kubectl create -f nginx.yaml
replicationcontroller "helloworld-rc" created
service "helloworld-svc" created

$ kubectl get svc
NAME             CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
helloworld-svc   10.3.0.47    <none>        80/TCP    41s
kubernetes       10.3.0.1     <none>        443/TCP   5h

$ kubectl get rc
NAME            DESIRED   CURRENT   READY     AGE
helloworld-rc   2         2         2         53s

$ kubectl get pod
NAME                  READY     STATUS    RESTARTS   AGE
helloworld-rc-bf3zw   1/1       Running   0          1m
helloworld-rc-xhhjl   1/1       Running   0          1m

$ curl 10.3.0.47
<!DOCTYPE html>
<html>
...
</html>
```

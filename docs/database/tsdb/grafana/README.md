# Grafana

## Install and Start
```
$ wget https://grafanarel.s3.amazonaws.com/builds/grafana-4.1.1-1484211277.linux-x64.tar.gz
$ tar xf grafana-4.1.1-1484211277.linux-x64.tar.gz
$ cd grafana-4.1.1-1484211277
$ bin/grafana-server
```

## JavaScriptで動的なダッシュボード
* http://docs.grafana.org/reference/scripting/
* JavaScriptをgrafana-4.1.1-1484211277/public/dashboards に置くことで動的なダッシュボードを定義できる
* デフォルトでサンプルが配置してあるので試せる
  * http://grafana_url/dashboard/script/scripted.js?rows=3&name=myName


## ダッシュボードのテンプレート
* https://grafana.net/dashboards
* データソースごとにいろいろなテンプレートが公開されている

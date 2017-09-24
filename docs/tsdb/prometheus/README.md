# Prometheus

## 主要コンポーネント
Prometheusサーバ
* metricsの収集先をtargetsに登録
  * 収集先は静的に設定、もしくはサービスディスカバリによって自動登録できる
* metricsをtargetsから定期的にpullし、ローカルストレージに保存する
  * prometheus自体の性能はスケールしないが、バッチ処理なので高負荷になりずらい
  * 単体の性能がスケールしないので、Kubernetesクラスタ一つに対してPrometeusを一つ用意し、それらを集中管理するPrometeusがあるとよい
* ストレージ
  * ストレージはローカルなので外部ボリュームを使うなどしないとデータの冗長性がとれない
  * またダウンサイジングといった機能もないのでディスクの容量が不安
* 一定間隔ごとにmetricsを評価して、alartをAlertmanagerにpushして、メールなどの通知を行える
* 保存したメトリックスはクエリエンジンで検索可能
* PrometheusのUIやGrafanaから見ることができる
  * グラフ表示はGrafafaが推奨

Exporter
* メトリックスを提供するエージェントのこと
* 標準的なExporterはPrometheusが提供しているが、ライブラリがあるのでそれを使って独自に実装してもよい
* Prometheusサーバがpull(HTTPでGET)してくるので、その際に未収集分のメトリックスを返すような実装になっていればよい
* EtcdやkubernetesやPrometeusサーバ事態もメトリックス収集用のエンドポイントを提供している

Alertmanager
* 同じアラート群をまとめる
* 誰に送るかルーティングする
* 再送やクローズのコントロール

Visualization
* Prometheus
  * 標準のグラフUI
  * targetsなどの確認に使う
* Grafana
  * Prometheusが公式で推奨している
* PromDash
  * Grafanaライクなダッシュボード
  * Grafana推奨なので、開発中止


## シンプルな設定
prometheus自体もメトリックスを提供しているので、これを収集できる
```
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9090']
```
* scrapeするtargetのことをinstanceと呼ぶ
    * instanceは、localhost:9090 のように<host>:<port>で定義される
* 同タイプのinstanceのコレクションをjobと呼ぶ
* prometheusは、targetをscrapeするとき、いくつかのラベルを自動で付与する
    * job_name、instanceのラベルは自動で付与される
        * up{job="<job-name>", instance="<instance-id>"}: 1


## sd_config
https://github.com/prometheus/docs/blob/master/content/docs/operating/configuration.md#kubernetes_sd_config


## スケーリングとフェデレーション
* prometheus自体はクラスタなどの機能はなくスケールもしない
* 複数のprometheusをフェデレーションするprometheusを立てることでスケールさせていく

設定例
```
- scrape_config:
  - job_name: dc_prometheus
    honor_labels: true
    metrics_path: /federate
    params:
      match[]:
        - '{__name__=~"^job:.*"}'   # Request all job-level time series
    static_config:
      - targets:
        - dc1-prometheus:9090
        - dc2-prometheus:9090
```
* prometheusは/federate エンドピントを提供しており、ここからメトリクスを取得できる
* match[]: 取得するjobを正規表現で指定する
* honor_labels: をtrueにすると、ソースサーバから収集したメトリクスのラベルを上書きしないよようになる


## 冗長性について
* メトリクスの収集経路を多重化することで冗長性を確保できそう(だが、あやしい。。)
* 末端のprometheus slaveがダウンした場合、もう片方のprometheus slaveからメトリクスは収集可能
* prometheus masterがダウンした場合、もう片方のprometheus masterにuserはアクセスできる
    * masterが一度ダウンしてしまうと、ダウンした期間のデータは保存ができないため、LBに参加する前に抜けたデータを補填する必要がある
    * しかし、ローカルストレージの場合、これができない
    * master側は、remote storageのinfluxdbなどを利用すると、データの補填が可能になるかも?
```
|node-exporter|  ->
|node-exporter|  -> |prometheus slave|    |prometheus master| - |grafana|
|node-exporter|  ->                    ->                                  <- |LB| <- user
|node-exporter|  ->                    ->                                  <- |LB| <- user
|node-exporter|  -> |prometheus slave|    |prometheus master| - |grafana|
|node-exporter|  ->
```


## タイムスタンプについて
* メトリクスのタイムスタンプはメトリクスが保存されるときに決定される
* exporterや、push時にメトリクスにタイムスタンプを設定することはできない


## アグリゲートについて
* https://prometheus.io/docs/querying/rules/
* recording rulesを記述することでアグリゲートが可能
    * 通信トータルから、1分間のrateを計算したり、1分間の合計を計算したりといろいろできる
* メトリクス名ごとに一つづつ定義しないといけないため、すべてのメトリクスの5分平均だけを保存するとかができない


## Install and Start
``` bash
$ wget https://github.com/prometheus/prometheus/releases/download/v1.5.2/prometheus-1.5.2.linux-amd64.tar.gz
$ tar prometheus-1.5.2.linux-amd64.tar.gz
$ cd prometheus-1.5.2.linux-amd64/
$ ./prometheus -config.file prometheus.yml
INFO[0000] Listening on :9090
```


## Exporters
### node exporter
* ホストの情報に関してはこれで大体のメトリックスが収集できる
* カスタムメトリックス
    * collector.textfile.directoryオプションをつかうと、node_exporterからカスタムメトリックスを送信できるようになる
    * Borgmonでは各アプリが/varzというパスでアプリケーションのメトリックスを公開することになっている


### haproxy exporter
* haproxy用のメトリックスを収集する
* Grafana: https://grafana.net/dashboards/367


## blackbox exporter
* サービスのヘルスチェックができる

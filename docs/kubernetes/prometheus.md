# Prometheus

## 主要コンポーネント
Prometheusサーバ
* metricsの収集先を静的に設定、もしくはサービスディスカバリによって収集先を自動登録する
  * targetsに登録される
  * 他のprometeusサーバを収集先に木構造のように設定することで、メトリックスを集約しつつ全体的な処理性能もスケールしそう
  * Kubernetesクラスタ一つにつきPrometeus一つ、そしてそれを集中管理するPrometeusを用意するなど
* metricsを登録された収集先からpullし、ローカルストレージに保存する
  * バッチ処理なので高負荷になりずらい
  * 冗長性を持たせるには、KubernetesとPersistentVolumeを利用すると担保できそう
  * またダウンサイジングといった機能もないのでディスクの容量が心配
* 一定間隔ごとにmetricsを評価して、alartをAlertmanagerにpushして、メールなどの通知を行う
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


## Prometheus on Kubernetes

node exporter
* ホストの情報に関してはこれで大体のメトリックスが収集できる
* カスタムメトリックス
    * collector.textfile.directoryオプションをつかうと、node_exporterからカスタムメトリックスを送信できるようになる
    * Borgmonでは各アプリが/varzというパスでアプリケーションのメトリックスを公開することになっている

# Service

## 主要コンポーネント

kube-apiserver

- Kubernetes のリソースを管理する API サーバ

kubectl

- kube-apiserver を叩くための CLI クライアント

etcd

- Kubernetes のリソースデータを保管する分散 KVS

kube-scheduler

- Pod をノードへ割り当てるスケジューラ

kube-controller-manager

- ReplicationController などの各種コントローラを起動して管理するマネージャ

kube-proxy

- Kubernetes の Service が持つ ClusterIP、ExternalIP へのアクセスをルーティングする
- proxy-mode オプションで iptables か userspace のモードを選択できる
- iptables(デフォルトのプロキシモード)
  - iptables によって Service の IP へのアクセスが来たら dnat して Pod へルーティングする

kubelet

- 各ノード上で動いており、自ノードの Pod を管理(作成、削除、変更)する
- 以下の 4 つの方法で Pod の情報を取得し、管理します
  - kube-api を監視して、自ノードに割り当てられた Rod を管理する
  - ローカルファイル（/etc/kubernetes/manifests ディレクトリ以下のファイル)を監視して、manifest に書かれた Pod を起動・変更する
    - kube-api, kube-scheduler, kube-controller-manager, kube-proxy は kubelet のローカルファイルで定義して起動されることが多い
    - --config で監視ディレクトリを指定
    - --file-check-frequency で監視間隔(デフォルト 20s)を指定
  - HTTP エンドポイントを監視してそこに置かれた manifest に書かれた Pod を起動する
    - --manifest-url で監視エンドポイントを指定
    - --http-check-frequency で監視間隔(デフォルト 20s)を指定
  - Kubelete 自身が持つ HTTP サーバ に対して manifest を送信することで Pod が起動される

kube-dns(addon)

- クラスタ内 DNS の Pod
- Service Resouce が作成された際に、{Service 名}.{ネームスペース}.svc.cluster.local という形式の FQDN で A レコード、SRV レコードに登録される

kubernetes-dashboard(addon)

- ダッシュボード

## ネットワークコンポーネント

cni

- コンテナネットワークインターフェイス
- flannel や calico といったネットワークプロバイダを利用するためのインターフェイス
- cni によって Pod に IP が払い出され Pod 間での通信が可能になる

flannel

- 仮想ブリッジと、XXLAN で仮想ネットワークを提供

calico

- BGP を利用して kubernetes クラスタ上のノード間で Pod の IP アドレスを広報しあうことで、各ノード上から Pod へのアクセスを可能にする
- Pod の IP は、外へは広報されないので完全に閉じた L3 のプライベートネットワーク空間で Pod が利用できる

## 監視コンポーネント

監視について

- Kubernetes を使う上ではどこでアプリケーションが動いているかを正確に知ることができない
- タグとラベルで管理しトラッキングすることが重要
- イベントのハンドリングやアラートの仕組みも重要

cAdvisor

- cAdvisor は Google が開発してるオープンソースのコンテナの監視ツール。
- Kubernetes の各ホスト上で起動している
- デフォルトで１秒毎に同じホストにあるコンテナのメトリックスを収集している
- メモリ上に（デフォルトで）60 秒分のメトリックスを保持し、API として提供している
- CPU・メモリ・ネットワーク・ディスクのメトリクスを収集

Heapster

- [Github](https://github.com/kubernetes/heapster)
- クラスタ単位のメトリックスの監視ツール
- ホストを自動的に監視に追加し kubelet を通して cAdvisor からメトリックスを収集する
  - メトリックス情報は、ラベルで Pod をまとめてエクスポートされる
- メトリックスのフォワード先のストレージバックエンドが必要
  - InfluxDB が使われることが多い
  - メトリックス表示には Grafana が使われることが多い
- Heapster を利用していれば kubernetes-dashbord 上で Namespace ごと、Pod ごとの CPU、メモリの使用量のグラフを見ることができる

Prometheus

- SoundCloud によって開発されている OSS のメトリックスの収集・監視システム
- Google 出身者が Google 社内監視ツール Borgmon にインスパイアされて作成された
- [アーキテクチャ](https://prometheus.io/docs/introduction/overview/#architecture)
- サービスディスカバリの機能があるので Kubernetes と連携がしやすい
- データの保存はローカルストレージなので大規模なスケールは怪しいが、Kubernetes クラスタ一つ分は監視できそう?
- グラフの描画機能は Prometheus 事態にもあるが、Grafana を使うのが推奨

kube-state-metrics

- [Github](https://github.com/kubernetes/kube-state-metrics)
- Heapster は CPU・メモリ・ネットワーク・ディスクのメトリクスを管理しているが、kube-state-metrics は Pod, Deployment, DaemonSet といった Kubernetes で抽象化された単位でメトリックスを管理する
- Prometheus と一緒に利用される
  - [設定例](https://raw.githubusercontent.com/prometheus/prometheus/master/documentation/examples/prometheus-kubernetes.yml)
- メトリックスは、メモリに保持しておいて、Prometheus golang クライアントを介してエクスポートされる(http://[svc]/metrics)
- Prometheus の scraper によって消費されるように設計されている
  - /metrics を開くと未処理のメトリックスが表示される

Fluentd + ElasticSearch

- 各ノード上で Fluentd を Daemonset で動かしてログを ElasticSearch に集約
- ElasticSearch にログ検索・分析をする

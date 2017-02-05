# Service

## 主要コンポーネント
kube-api
* Kubernetesのリソースを管理するAPIサーバ

etcd
* Kubernetesのリソースデータを保管する分散KVS

kube-scheduler
* Podのノードへの割り当てを行うスケジューラ

kube-controller-manager
* ReplicationControllerなどの各種コントローラを起動して管理するマネージャ

kube-proxy
* KubernetesのServiceが持つClusterIP、ExternalIPへのアクセスをルーティングする
* proxy-modeオプションで iptablesかuserspaceのモードを選択できる
* iptables(デフォルトのプロキシモード)
    * iptablesによってServiceのIPへのアクセスが来たらdnatしてPodへルーティングする

kubelet
* 各ノード上で動いており、自ノードのPodを管理(作成、削除、変更)する
* 以下の4つの方法でPodの情報を取得し、管理します
  * kube-apiを監視して、自ノードに割り当てられたRodを管理する
  * ローカルファイル（/etc/kubernetes/manifestsディレクトリ以下のファイル)を監視して、manifestに書かれたPodを起動・変更する
    * kube-api, kube-scheduler, kube-controller-manager, kube-proxy はkubeletのローカルファイルで定義して起動されることが多い
    * --config で監視ディレクトリを指定
    * --file-check-frequency で監視間隔(デフォルト20s)を指定
  * HTTPエンドポイントを監視してそこに置かれたmanifestに書かれたPodを起動する
    * --manifest-url で監視エンドポイントを指定
    * --http-check-frequency で監視間隔(デフォルト20s)を指定
  * Kubelete自身が持つHTTPサーバ に対してmanifestを送信することでPodが起動される

kube-dns(addon)
* クラスタ内DNSのPod
* Service Resouceが作成された際に、{Service名}.{ネームスペース}.svc.cluster.localという形式のFQDNでAレコード、SRVレコードに登録される

kubernetes-dashboard(addon)
* ダッシュボード


## ネットワークコンポーネント
cni
* コンテナネットワークインターフェイス
* flannelやcalicoといったネットワークプロバイダを利用するためのインターフェイス
* cniによってPodにIPが払い出されPod間での通信が可能になる

flannel
* 仮想ブリッジと、XXLANで仮想ネットワークを提供

calico
* BGPを利用してkubernetesクラスタ上のノード間でPodのIPアドレスを広報しあうことで、各ノード上からPodへのアクセスを可能にする
* PodのIPは、外へは広報されないので完全に閉じたL3のプライベートネットワーク空間でPodが利用できる


## 監視コンポーネント
監視について
* Kubernetesを使う上ではどこでアプリケーションが動いているかを正確に知ることができない
* タグとラベルで管理しトラッキングすることが重要
* イベントのハンドリングやアラートの仕組みも重要

cAdvisor
* cAdvisorはGoogleが開発してるオープンソースのコンテナの監視ツール。
* Kubernetesの各ホスト上で起動している
* デフォルトで１秒毎に同じホストにあるコンテナのメトリックスを収集している
* メモリ上に（デフォルトで）60秒分のメトリックスを保持し、APIとして提供している
* CPU・メモリ・ネットワーク・ディスクのメトリクスを収集

Heapster
* [Github](https://github.com/kubernetes/heapster)
* クラスタ単位のメトリックスの監視ツール
* ホストを自動的に監視に追加しkubeletを通してcAdvisorからメトリックスを収集する
  * メトリックス情報は、ラベルでPodをまとめてエクスポートされる
* メトリックスのフォワード先のストレージバックエンドが必要
  * InfluxDBが使われることが多い
  * メトリックス表示にはGrafanaが使われることが多い


Prometheus
* 

kube-state-metrics
* [Github](https://github.com/kubernetes/kube-state-metrics)
* HeapsterはCPU・メモリ・ネットワーク・ディスクのメトリクスを管理しているが、kube-state-metricsはPod, Deployment, DaemonSetといったKubernetesで抽象化された単位でメトリックスを管理する
* Prometheusと一緒に利用される
   * [設定例](https://raw.githubusercontent.com/prometheus/prometheus/master/documentation/examples/prometheus-kubernetes.yml)
* メトリックスは、メモリに保持しておいて、Prometheus golangクライアントを介してエクスポートされる(http://[svc]/metrics)
* Prometheusのscraperによって消費されるように設計されている
  * /metricsを開くと未処理のメトリックスが表示される




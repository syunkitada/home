# Resource

ResourceとはKubernetesで扱われるオブジェクトの総称。
Resourceには、いろいろな種類があり、Resourceは様々な要素から構成される。

| 用語 | 説明 |
| --- | --- |
| Manifest | Resourceを定義したファイル（yaml, jsonで記述する) |
| Pod(Resource) | 同じノードで動作するコンテナの集合体、コンテナ間ではIPアドレス、ポート空間、IPC空間(セマフォ、共有メモリ）を共有する |
| PodTemplate | Podを生成するためのテンプレート、DeploymentやReplicationControllerによってPodを定義する際に用いられる |
| ReplicationController/ReplicaSet(Resource) | Podがreplicasプロパティで指定された数動いてることを保証する |
| Service(Resource) | Podのエンドポイント(IP, DNS)を作成する、Serviceへ来たアクセスはiptablesによってPodへルーティングされる |
| Node(Resource) | Kubernetesクラスタに参加するワーカ(kubelet) |
| LimitRange | Podに割り当てるCPU, memoryなどのリソースを制限する(デフォルトは無制限)、minを確保できないとPodは生成できない |
| ResourceQuota | Namespaceごとに使用するリソース上限を設定 |
| Namespace | リソースの属する名前空間 |
| [ConfigMap](configmap.md) | 設定情報を扱うためのリソース |
| Secret | 機密情報を扱うためのリソース |
| PersistentVolume | 確保済みのネットワークストレージを表現するリソース |
| PersistentVolumeClaim | Kubernetesから動的にストレージのリソースを確保するリクエストを表現するリソース |
| DeleteOptions | |
| ComponentStatus | |
| HorizontalPodAutoscaler | CPU等のメトリックスに応じてDeployment等のreplicasパラメータを調整することでPodをオートスケーリング |
| Job | 終わることが想定されている仕事をするPodの集合 |
| JobTemplate | Jobを生成するためのテンプレート、CronJobで利用される |
| CroneJob | Jobの実行時間をCronで管理する |
| Deployment | ReplicaSet より高レベルの API として、更新可能な Pod 集合を扱う |
| DeploymentRollback | Deployment のロールバック時に Deployment 名と Deployment のrevision を持つリソース |
| DaemonSet | すべてのNodeで動くべきPodを定義 |
| Ingress | ServiceへのL7LBを定義 |
| NetworkPolicy | Pod間の通信拒否を制御する、Namespace内での通信をデフォルトで禁止することが可能、Labelで指定された特定のPod集合ごとにホワイトリストが可能 |
| StatefulSet(PetSet) | ステートフルなPodのセット |

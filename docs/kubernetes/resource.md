# Resource

* ResourceとはKubernetesで扱われるオブジェクトの総称
* Resourceには、いろいろな種類があり、Resourceは様々な要素から構成される
* 各ResourceのSpecとStatusを持ち、Resouceはkubectlなどによって更新され、Statusはコントローラマネージャによって更新される
* KubernetesはSpecとStatusの差分を検知すると、StatusがSpecと等しくなるようにResouceを制御する

Manifest
* Resourceを定義したファイル（yaml, jsonで記述する)
* kubectl apply -f [manifest] でResouceがKubernetesに反映される
* Namespace
  * Resourceの属する名前空間

Node
* Kubernetesクラスタに参加するワーカ(kubelet)
* ラベリングするとPodの配置などを制御できる

Pod
* 同じノードで動作するコンテナの集合体、コンテナ間ではIPアドレス、ポート空間、IPC空間(セマフォ、共有メモリ）を共有する
* PodTemplate
    * Podを生成するためのテンプレート、DeploymentやReplicationControllerによってPodを定義する際に用いられる
* LimitRange
    * Podに割り当てるCPU, memoryなどのリソースを制限する(デフォルトは無制限)、minを確保できないとPodは生成できない |
* ResourceQuota
    Namespaceごとに使用するリソース上限を設定

ReplicationController/ReplicaSet
* Podがreplicasプロパティで指定された数動いてることを保証する


Service
* Podのエンドポイント(IP, DNS)を作成する
* Service(ClusterIP or ExternalIP)へ来たアクセスはiptablesによってPodへルーティングされる
* ClusterIP
  * Serviceが持つ、クラスタ内でServiceへアクセスするためのIP
* ExternalIP
  * Serviceが持つ、クラスタ外からServiceへアクセスするためのIP
  * BGPなどで外にノードへのルートを広報しておくと外からのアクセスが可能になる
  * iptablesによってノード内からはExternalIPへのアクセスはフィルタされる
* service.spec.sessionAffinity
  * None(default): iptablesのrandomモジュールによってバックエンドのポートがランダムでdnatされる
  * ClientIP: iptablesのrandomモジュールによって初回アクセスはランダムでdnatされ、以降はrecentモジュールによって直近アクセス先へdnatされる

[ConfigMap](configmap.md)
* 設定情報を扱うためのリソース

Secret
* 機密情報を扱うためのリソース

PersistentVolume
* 確保済みのネットワークストレージを表現するリソース |

PersistentVolumeClaim
* Kubernetesから動的にストレージのリソースを確保するリクエストを表現するリソース

HorizontalPodAutoscaler
* CPU等のメトリックスに応じてDeployment等のreplicasパラメータを調整することでPodをオートスケーリング |

Job
* 終わることが想定されている仕事をするPodの集合
* JobTemplate
  * Jobを生成するためのテンプレート、CronJobで利用される |

CroneJob
* Jobの実行時間をCronで管理する

Deployment
* ReplicaSet より高レベルの API として、更新可能な Pod 集合を扱う

DeploymentRollback
* Deployment のロールバック時に Deployment 名と Deployment のrevision を持つリソース

DaemonSet
* すべてのNodeで動くべきPodを定義 |

Ingress
* ServiceへのL7LBを定義

NetworkPolicy
* Pod間の通信拒否を制御する、Namespace内での通信をデフォルトで禁止することが可能、Labelで指定された特定のPod集合ごとにホワイトリストが可能

StatefulSet(PetSet)
* ステートフルなPodのセット

メモ
* DeleteOptions
* ComponentStatus

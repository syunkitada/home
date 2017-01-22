# Service

## 主要サービス
| サービス | 説明 |
| --- | --- |
| kube-api | |
| kubelet | Podを起動し管理するエージェント、起動時にローカルのmanifestsを読み込み自動でResourceを作成できる |
| kube-proxy | iptablesをいじってServiceからPodへのルーティングをコントロールする |
| kube-controller-manager | ReplicationControllerなどの各種コントローラを起動して管理するマネージャ |

## ネットワーク
calico

## 拡張


## ResouceのSpecとStatus
各ResourceのSpecとStatusの差分を検知し、
kubectl create, applyなどでResourceが更新されるとSpecをStatusに同期させるResouceを制御する

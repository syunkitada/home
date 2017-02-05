# debug

# ログ確認
journalctl -xe -u kubelet
docker -xe -u kubelet

kubectl logs [pod] -n [namespace]

## ネットワーク
$ calicoctl node status




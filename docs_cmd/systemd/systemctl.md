# systemctl

```
# サービス起動
$ systemctl start [unit]

# サービス停止
$ systemctl stop [unit]

# サービス再起動
$ systemctl restart [unit]

# サービスリロード
$ systemctl reload [unit]

# サービスステータス表示
$ systemctl status [unit]

# サービスの自動起動を有効
$ systemctl enable [unit]

# サービスの自動起動を無効
$ systemctl disable [unit]

# サービス自動起動設定確認
$ systemctl is-enabled [unit]

# サービス一覧
$ systemctl list-unit-files --type=service

# サービスファイルの再読込
$ systemctl daemon-reload
```

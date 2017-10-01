# TSDB

## Link
| Name | Description |
| --- | --- |
| Graphite   | パフォーマンス低、長期保存に向いている、スケールアウトやデータの冗長性がある(データ同期するようなクラスタ機能ではないので、工夫が必要) |
| InfluxDB   | パフォーマンス高、クラスタリングは有料、スケールアウトや冗長性を担保するためには工夫が必要 |
| Prometheus | パフォーマンス高、長期保存は不可、クラスタリングといった機能はないがフェデレーション機能である程度のスケールアウトや冗長性を担保できる、サービスディスカバリが便利 |


## システム構想
* メトリクスデータの収集経路を多重化する
* prometheus masterは各prometehsu slaveの/federateからデータを収集する
    * 末端のprometheus slaveがダウンした場合、もう片方のprometheus slaveからメトリクスは収集可能
* prometheus maste - influxdbがダウンした場合、もう片方のinfluxdbにuserはアクセスできる
    * influxdbが一度ダウンしてしまうと、ダウンした期間のデータは保存ができないため、その分のデータは抜ける
* 長期保存用のinfluxdbも立てて、バッチ処理により、rawデータ保存用のinfluxdbからデータを抜き出し、longに保存する
    * このバッチ処理では古いデータの削除も行う
* federate proxyはinfluxdb全台にqeryを投げて、結果をマージしてgrafanaへ返す
    * queryは一定時間キャッシュする
```
|node-exporter|  ->                            -> alert manager
|node-exporter|  -> |prometheus|              |prometheus master|  <- (polling) |relay| -> |influxdb| <- |grafana|  <- |LB| <- user
|node-exporter|  ->              /federate ->                                               |syncer|
|node-exporter|  ->              /federate ->
|node-exporter|  -> |prometheus|              |prometheus master|  <- (polling) |relay| -> |influxdb| <- |grafana|  <- |LB| <- user
|node-exporter|  ->                            -> alert manager
```

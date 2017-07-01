# Compute

## Instance起動フロー
* client: 起動リクエスト -> REST -> nova-api
* nova-api: リクエストのバリデーション
* nova-api: 起動リクエスト -> RPC -> nova-conductor
* nova-condoctor: スケジュールリクエスト -> RPC -> nova-scheduler
    * nova-scheduler: DBのCompute情報から指定されたAvailabilityZoneのActiveなComputeリストを取得する
    * nova-scheduler: scheduler_default_filtersによって、Computeリストをフィルタリングする
    * nova-scheduler: weightによってComputeリストを優先度順に並び替える
    * nova-scheduler: scheduler_host_subset_size の分だけ残してComputeリストから優先度の低いものを削る
    * nova-scheduler: Computeリストから1つのComputeをランダムで一つ決定する
    * nova-scheduler: スケジュール結果を返す -> RPC -> nova-conductor
* nova-conductor: Computeに起動リクエストを送る -> RPC -> nova-compute
* nova-compute: Port作成リクエスト -> REST -> neutron-server
    * neutron-server: Port作成
* nova-compute: イメージダウンロードリクエスト -> REST -> glance-api
    * glance-api: イメージを返す
* nova-compute: Domain.xml作成
* nova-compute: tapデバイスを作成し、インスタンスを起動する

* neutron-linuxbridge-agent: 無限ループ(インターバル2秒)でデバイス情報を監視
    * /sys/class/net/にtapで始まるデバイスを見つけたら適切に処理する
    * デバイス情報の取得リクエスト -> RPC -> neutron-server
        * neutron-server: デバイス情報を返す -> RPC -> neutron-linuxbridge-agent
    * デバイスを接続すべきブリッジにデバイスを接続する
        * ブリッジがなければ新規に作成する

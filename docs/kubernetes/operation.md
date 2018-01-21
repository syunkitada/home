# Operation
* 運用視点でのメモ


## Pod死活監視の挙動
* Podの監視はKubeletが行う
* Podの各コンテナのReadyについて
    * コンテナプロセスが立ち上がるとReadyとなる
        * コンテナにReadiness Proveが設定されている場合は、Proveが正常になるとReadyになる
    * PodのすべてのコンテナがReadyになると、ServiceのEndpointsにPodのIPが追加される
        * そうでない場合は、ServiceのEndpointsからPodのIPが外される
* PodのCrashについて
    * Crashの検知は、プロセス自体、Liveness Proveにより行われる
    * PodがCrashした場合、
        * 同じPodで再度コンテナプロセスがスタートする
        * Podが連続してCrashすると「Crash loop back off」となる


## Node(kubelet)死活監視の挙動
* NodeのReadyについて
    * kubeletは、kube-apiに自身のステータスを定期的に報告し、Readyとなる
        * 報告の間隔は以下のオプションで指定する
            * --node-status-update-frequency duration(default 10s)
    * kube-controller-managerでは、nodeのステータスを定期的に同期している
        * 同期間隔: --node-monitor-period duration(default 5s)
        * kubeletのステータス更新がない場合は、NodeをNotReadyにする
            * NodeをNotReadyとするまでの時間は以下のオプションで指定する
                * --node-monitor-grace-period duration(default 40s)
* evictionについて
    * NodeがNotReadyになった場合、一定時間まで、その状態のままNodeの復帰を待つ
        * この場合、PodのステータスはRunningのままだが、ServiceのEndpointsからは外される
        * 一定時間たつと、kube-controller-managerがeviction処理を実行する
            * 一定時間の設定: kubelet --eviction-pressure-transition-period duration(default 5m)
        * 一定時間たつ前に、Nodeが復帰すると、PodのStatusはRunningからError or Completedになり、再度起動しなおす
    * eviction処理は、Node上のPodを他のNodeに配置しなおす
        * Node上のPodのステータスはすべてUnknownとなり、他のNodeでPodが起動する
    * Nodeが再びReadyとなると、UnknownとなっていたPodはすべて削除される
    * evictionは、Nodeのリソースが枯渇した場合にも行われ、以下のオプションでその条件を指定できる
        * --eviction-hard string(default "memory.available<100Mi,nodefs.available<10%,nodefs.inodesFree<5%")
            * evictionするトリガーとなるリソース閾値のセット
        * --eviction-soft string(e.g. memory.available<1.5Gi)
            * soft evictionするトリガーとなるリソース閾値のセット
        * --eviction-soft-grace-period string(e.g. memory.available=1m30s)
            * soft evictionの閾値を超えたときに、evictionするまでの猶予期間のセット
        * --eviction-max-pod-grace-period int32
            * soft evictionの閾値を超えたときに、evictionするまでの最大猶予期間
        * --eviction-minimum-reclaim string(e.g. imagefs.available=2Gi)
            * リソースが圧迫されている場合に、pod evictionで回収する最小リソースのセット


## cordon, uncordon, drain
* cordon
    * NodeにPodがスケジューリングされるようにする
* uncordon
    * Nodeに新規のPodがスケジューリングされないようにする
    * Node Statusに SchedulingDisabledがセットされる
* drain
    * Nodeをuncordonし、そのNode上のPodをすべてevictionする
    * Nodeのメンテナンス時などに利用する
    * kubectl drain ... --ignore-daemonsets --delete-local-data
    pod がlocal-storage利用している場合は、--delete-local-data
    deamonsetsが乗っている場合は、--ignore-daemonsetsをつける



## Blue Green Deployment
* Deploymentを2個用意し、片方をステージング、もう片方を本番として扱う
    * DBなどのステートフルなものは共通のものを参照する
* 新しいリリースを行うときは、ステージング側に反映し、テストする
* その後、本番のServiceのselectorを本番側からステージング側に張り替える
    * 問題があった場合は、再度selectorを張り替えることでロールバックする
    * 問題がない場合は、このままで、ステージングと本番の役割は入れ替わる

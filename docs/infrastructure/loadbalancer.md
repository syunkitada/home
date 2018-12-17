# Loadbalancer


## Maglev
* Googleの開発したSoftware Loadbalancer(論文のみ)
* https://storage.googleapis.com/pub-tools-public-publication-data/pdf/44824.pdf


## katran
* Facebookの開発したSoftware Loadbalancer(OSS)
* https://code.fb.com/open-source/open-sourcing-katran-a-scalable-network-load-balancer/
* https://github.com/facebookincubator/katran


## GLB
* Githubの開発したSoftware Loadbalancer(OSS)
* https://github.com/github/glb-director
* https://githubengineering.com/glb-director-open-source-load-balancer/

### GLB メモ
* RouterからのECMPで L4 proxy hostsにリクエストを分散させる
* L4 proxy hostsでは、DPDKのPMDでパケット受け取り、glb-directorが後ろのL7 proxy hostsにリクエストを転送する
* glb-directorは、リクエストの5tupleからハッシングによって宛先を決めるが、この宛先proxyを2台で1セット(primary/secondory)を一つの宛先として扱う
    * 通常では、primaryにのみパケットが転送される
    * primaryのホストがヘルスチェックのダウンや、明示的にdrainで外そうとした場合、そのホストとペアになってるホストとで(primary/secondory)を入れ替える
    * 新規のパケットは新しいprimaryホストへ転送され、既存パケットはsecondoryへと転送され処理される
* proxyでは、パケットが到着したときに、そのパケットが新規パケットか、すでにEstablishかをチェックしそうであれば自身で処理する
    * そうでなければ、もう一つのペアあてのパケットとみなし、そちらにパケットを転送する
    * もう片方でも扱ってない場合は破棄される
        * ホップ数をカウントしているので、再度転送されることはない
    * この転送の仕組みはglb-redirect iptables moduleで実現している
        * GUEヘッダ、Foo-over-UDPという技術を使ってる
        * https://github.com/github/glb-director/blob/master/docs/development/gue-header.md

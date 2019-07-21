# Loadbalancer

## Maglev

- Google の開発した Software Loadbalancer(論文のみ)
- https://storage.googleapis.com/pub-tools-public-publication-data/pdf/44824.pdf

## katran

- Facebook の開発した Software Loadbalancer(OSS)
- https://code.fb.com/open-source/open-sourcing-katran-a-scalable-network-load-balancer/
- https://github.com/facebookincubator/katran

## GLB

- Github の開発した Software Loadbalancer(OSS)
- https://github.com/github/glb-director
- https://githubengineering.com/glb-director-open-source-load-balancer/

### GLB メモ

- Router からの ECMP で L4 proxy hosts にリクエストを分散させる
- L4 proxy hosts では、DPDK の PMD でパケット受け取り、glb-director が後ろの L7 proxy hosts にリクエストを転送する
- glb-director は、リクエストの 5tuple からハッシングによって宛先を決めるが、この宛先 proxy を 2 台で 1 セット(primary/secondory)を一つの宛先として扱う
  - 通常では、primary にのみパケットが転送される
  - primary のホストがヘルスチェックのダウンや、明示的に drain で外そうとした場合、そのホストとペアになってるホストとで(primary/secondory)を入れ替える
  - 新規のパケットは新しい primary ホストへ転送され、既存パケットは secondory へと転送され処理される
- proxy では、パケットが到着したときに、そのパケットが新規パケットか、すでに Establish かをチェックしそうであれば自身で処理する
  - そうでなければ、もう一つのペアあてのパケットとみなし、そちらにパケットを転送する
  - もう片方でも扱ってない場合は破棄される
    - ホップ数をカウントしているので、再度転送されることはない
  - この転送の仕組みは glb-redirect iptables module で実現している
    - GUE ヘッダ、Foo-over-UDP という技術を使ってる
    - https://github.com/github/glb-director/blob/master/docs/development/gue-header.md

## SRLB

- https://www.thomasclausen.net/wp-content/uploads/2017/05/camera-ready-ieeepdfexpress.pdf

## LINE の SWLB

- https://www.slideshare.net/linecorp/ss-116879618
- Stateless L3DSR
  - L3DSR は DSCP を利用した方式
- Verda の LBaaS として利用されてる?
  - データプレーンは C(XDP)で 800 行
  - コントロールプレーンは Python で 14000 行

## Sticky ECMP

- https://community.cisco.com/t5/service-providers-documents/xr-ncs5500-asr9000-persistent-loadbalancing-or-quot-sticky-ecmp/ta-p/3361883
- 従来の ECMP はパスが消えると、経路がリハッシュされ既存のセッションも含めて経路が変わる可能性がある
- Sticky ECMP はパスが消えた場合でも、その経路上のセッションのみ消えるだけで、既存のセッションには影響しない

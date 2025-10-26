# Loadbalancer

## Maglev

- Google の開発した Software Loadbalancer(論文のみ)
- https://storage.googleapis.com/pub-tools-public-publication-data/pdf/44824.pdf
- IP Fragmentation の対策
  - 問題提起
    - IP Fragmentation が発生すると IP パケットは MTU に収まるように分割され、先頭のパケットには TCP ヘッダが含まれたままだが、以降のパケットは IP ヘッダのみとなり TCP ヘッダが含まれない
    - Maglev は、5-tupple で転送先のバックエンドを決定するが、IP Fragmentation が発生すると、先頭以外のパケットは 3-tupple になるため対策が必要となる
  - この対策には二つの要件を満たす必要がある
    - あるフローのフラグメントパケットはすべて同じ Maglev ノードが受信する必要がある
    - フラグメントされてないパケット、first フラグメントパケット、non-first フラグメントパケットを一貫したバックエンドサーバに転送しなければならない
  - Maglev の手前のハードウェアに頼ることはできない
    - 手前のハードウェアでは、フラグメントされてないパケットは 5-tupple で、フラグメントパケットは 3-tupple でハッシングされてバランシングされるため、すべてのパケットが同一の Maglev が受信するとは限らない
  - 一つ目の要件を満たすための仕組み
    - 各 Maglev は、そのクラスタの全 Maglev で構成される特殊なバックエンドプールを持つ
    - フラグメントを受信すると Maglev は 3-tuple ハッシュでそのプールから Maglev を引き当てて転送する
      - これによりすべてのフラグメントパケットは同じ Maglev にリダイレクトされることが保証される
      - また、GRE の recursion control フィールドを使用して一度だけリダイレクトされることを保証する
  - 2 つ目の要件を満たすための仕組み
    - Maglev はフラグメントされてないパケットとセカンドホップのファーストフラグメントのバックエンド選択アルゴリズムに同じものを利用する
    - first フラグメントの転送先を記録する固定サイズのフラグメントテーブルを維持する
      - second-hop non-first フラグメントを同じマシンで受信したら、Maglev はフラグメントテーブルで検索し、一致するものがあればすぐに転送する
      - そうでない場合は、second-hop first フラグメントを受信するか、エントリが期限切れになるまでフラグメントテーブルにキャッシュされる
  - このアプローチには二つの制限がある
    - フラグメントパケットに余分なホップを導入し、パケットの順序を変更する可能性がある
      - パケットの順序変更はネットワークのどこでも起こる可能性があるため、順序が変わったパケットを処理するのはエンドポイントに依存する
    - second-hop non-first フラグメントをバッファリングするために余分なメモリが必要になる
      - 実際には少数の VIP だけがフラグメントを受信することができるようになってるため、我々は簡単にフラグメントを受信でき、それらを処理するには十分なフラグメントテーブルを提供することができる
  - メモ
    - IPv4 の場合は、IP ヘッダのフラグメント情報を見て、フラグメントされてるなら 3-tupple でバックエンドを決定するのではダメなのだろうか？
      - わざわざリダイレクトを挟む理由がいまいちわからなかった
    - 実際には少数の VIP だけがフラグメントを受信することができるのはなぜか？
      - 攻撃に使われる場合が多いから基本的に許可しないようにしてる？

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

## VPP

- https://github.com/FDio/vpp
- VPP 自体はユーザランドで動くパケットプロセッサ
- LB プラグインを利用することで Maglev ライクな LB を実現できる

## SRLB

- https://www.thomasclausen.net/wp-content/uploads/2017/05/camera-ready-ieeepdfexpress.pdf

## LINE の SWLB

- https://www.slideshare.net/linecorp/ss-116879618
- XDP を利用した Stateless L3DSR
  - L3DSR は DSCP を利用した方式
  - ICMP により L3DSR のヘルスチェックをしている
- Verda の LBaaS として利用されてる?
  - データプレーンは C(XDP)で 800 行
  - コントロールプレーンは Python で 14000 行

## Sticky ECMP

- https://community.cisco.com/t5/service-providers-documents/xr-ncs5500-asr9000-persistent-loadbalancing-or-quot-sticky-ecmp/ta-p/3361883
- 従来の ECMP はパスが消えると、経路がリハッシュされ既存のセッションも含めて経路が変わる可能性がある
- Sticky ECMP はパスが消えた場合でも、その経路上のセッションのみ消えるだけで、既存のセッションには影響しない

## MetalLB

- https://metallb.io/
- L4 Software LB の OSS(Apache License 2.0)
- iptables/ipvs をデータプレーンに使っています。
- ベアメタル環境で動作する Kubernetes クラスタ向けに特別に設計されており、IP アドレス管理のためのレイヤー 2（ARP/NDP）およびレイヤー 3（BGP）プロトコルを実装しています。

## Loxilb

- https://docs.loxilb.io/latest/
- L4/L7 Software LB の OSS(Apache License 2.0)
- eBPF をデータプレーンに使っています。
- L2DSR/L3DSR もサポートしています。
  - https://docs.loxilb.io/latest/nat/
- パフォーマンス
  - [L4-L7 Performance: Comparing LoxiLB, MetalLB, NGINX, HAProxy](https://dev.to/nikhilmalik/l4-l7-performance-comparing-loxilb-metallb-nginx-haproxy-1eh0)
  - L4 の性能として Metal LB と比較されており、Loxilb のが良い
  - L7 の性能として、NGINX/HAProxy と比較されており、Loxilb のが良い
    - ただ L7 に関しては機能面も重要なので性能だけで一概に良いとは言えない

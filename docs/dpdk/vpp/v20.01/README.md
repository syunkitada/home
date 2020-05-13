# vpp v20.01 コードリーディング

## Contents

| Link                                              | Description              |
| ------------------------------------------------- | ------------------------ |
| [main](main.md)                                   | main                     |
| [vpp_infra](vpp_infra.md)                         | vpp_infra                |
| [worker_thread](worker_thread.md)                 | worker thread            |
| [worker_thread_barrier](worker_thread_barrier.md) | worker thread の同期機構 |
| [lock](lock.md)                                   | ロック機構               |
| [dpdk](dpdk.md)                                   | dpdk plugin              |
| [ip4_lookup](ip4_lookup.md)                       | ip4_lookup               |
| [ip4_loadbalance](ip4_loadbalance.md)             | ip4_loadbalance          |
| [lb](lb.md)                                       | lb plugin                |
| [frame](frame.md)                                 | frame                    |
| [fib](fib.md)                                     | fib                      |

## 準備

```sh
$ https://github.com/FDio/vpp.git
$ cd vpp
$ git checkout v20.01

# タブとスペースが入り混ざってるので、タブを 8 文字スペースに置換しておくと読みやすい
$ find ./ -type f | xargs sed -i 's/\t/        /g'
```

## 基本概念

- グラフによる vector 単位でパケット処理する機構を持つ
- graph
  - 点を node、辺を edge（または、方向のある辺を弧、arc）と呼ぶ
  - directed-graph は、child から parent への一方向への横断（traverse）できる
  - indirected-graph は、edge はどちらの方向にも横断できる
  - child は、一つの parent を持ち、parent は複数の child を持つ
  - 同じ parent を持つ children を siblings と呼ぶ
  - child から、parent への traversal のことを forward traversal, walk と呼ぶ
    - 処理コストが低い
  - parent から children への traversal を back walk と呼ぶ
    - 処理コストが高い
- node の種類
  - input
    - 開始点で、パケットの取得を行う node
  - internal
    - 中間点で、パケットを処理を行う node
- Controle Plane(CP)、Data Plance(DP)でのデータの取り扱い
  - いくつかのデータは、CP ではメタ情報を多く含むが、DP で利用する場合は最低限のデータに落としこんで利用される
- dpo
  - data path object
  - edge にあたるもの
  - その instance のサイズは、cache line に収まるように調整されている
  - 以下の情報を含む
    - type
    - index
    - next_node
      - index of the VLIB node
- arp
  - 隣接する IP アドレスで識別される peer と、そのインターフェイスの MAC を管理する
  - arp-entry は、トラフィックをどう送信するかを表す egress function
  - 一方で、ingress function の VRF というものもある
  - データ構成は、Controle Plane
  - arp_entry_t は CP で管理される arp-entry
  - ip_adjacency_t は、パケットフォワードに必要なデータを含む(これは arp_entry_t によって提供される)
- fib(forwarding infrmatin base)
  - prefix により dpo の選択をする処理で使われる
    - lb プラグインでは、fib に vip の prefix および自 node へのパス(dpo)を登録するとこで、ip4-lookup node によりフォワーディングされる
    - また、lb プラグインでは vip のメンバへパケットを送り出すときも fib にメンバ IP への dpo を事前に登録しておき、そこへフォワーディングする
  - prefix
    - 1.1.1.1 This is an address since it has no associated mask
    - 1.1.1.0/24 This is a prefix.
    - 1.1.1.1/32 This is a host prefix (the mask length is the size of the address).
  - データ構造は CP と DP で異なる
    - contributing により、control-plane-graph から data-plane-graph を構成する
      - DP では、lookup のための prefix と next-node が管理される
        - next-node の管理には dpo が利用される
  - route
    - CP は、table に prefix のための、path-list を table に取り付ける
    - いくつかの function は、table から route の path を解決する
    - path 解決された route は、fib_entry_t から ip_adgacency_t へたどることができる
    - fib_entry_t
      - prefix を持つ
    - fib_path_list_t
      - fib_entry_t に一つ紐づき、複数の fib_path_t を管理する
      - path を複数持つ(multi path)の場合は、ECMP のように hash によって path を決定する
    - fib_path_t
      - next_hop が attach される
        - next_hop は、同一 subnet の interface が一つのみが attach される
        - ip_adjacency_t が紐づく

## メモ

- mtrie(multiway trie)
  - [The adj acency table Forwarding Information Base FIB](https://www.ccexpert.us/traffic-share/the-adj-acency-table-forwarding-information-base-fib.html)
  - [Forwarding Hardware](https://null.53bits.co.uk/index.php?page=forwarding-hardware)

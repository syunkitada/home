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

- 有効グラフによる Vector 単位でパケット処理する機構を持つ
  - 点を Node、辺を Edge、弧を Arc と呼ぶ
- Node の種類
  - input
    - 開始点で、パケットの取得を行う Node
  - internal
    - 中間点で、パケットを処理を行う Node
- Node 間の接続
  - DPO(Data Path Object)

# vpp v20.01 コードリーディング

## Contents

| Link                                              | Description                |
| ------------------------------------------------- | -------------------------- |
| [main](main.md)                                   | main                       |
| [vpp_infra](vpp_infra.md)                         | vpp_infra                  |
| [worker_thread_barrier](worker_thread_barrier.md) | worker thread のロック機構 |
| [dpdk](dpdk.md)                                   | dpdk plugin                |
| [frame](frame.md)                                 | frame                      |

## 準備

```sh
$ https://github.com/FDio/vpp.git
$ cd vpp
$ git checkout v20.01

# タブとスペースが入り混ざってるので、タブを 8 文字スペースに置換しておくと読みやすい
$ find ./ -type f | xargs sed -i 's/\t/        /g'
```

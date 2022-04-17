# cgroup

- cgroup(コントロールグループ)
  - プロセスをグループ化する機能のこと
  - このグループ単位でリソースの割り当て、優先度、管理、モニタリングなどが設定できる
- cgroup サブシステム（リソースコントローラ）
  - cgroup のリソースコントロールを行う機能のこと
  - systemd はデフォルトでいくつかのサブシステムをマウントしており、systemd 経由でも cgroup の設定ができる
  - 種類
    - cpu CPU へのアクセス
    - cpuacct CPU についての自動レポートを生成
    - cpuset マルチコア CPU のコア単位およびメモリノードを割り当て
    - memory メモリに対する制限設定とメモリリソースについての自動レポートの生成
    - blkio ブロックデバイスの入出力アクセス
    - devices デバイスへのアクセス
    - net_cls ネットワークパケットへのタグ付け
    - net_prio ネットワークトラフィックの優先度を動的に設定
    - freezer タスクを一時停止または再開

## systemd-cgls

- コントロールグループ階層の表示

```
$ systemd-cgls
Control group /:
-.slice
├─1424 bpfilter_umh
Control group /:
-.slice
├─1424 bpfilter_umh
├─user.slice
│ ├─user-1000.slice
│ │ ├─session-10.scope
...
│       └─1594 /usr/lib/ibus/ibus-portal
├─init.scope
│ └─1 /sbin/init splash
```

```
$ systemd-cgls memory
Controller memory; Control group /:
├─   1 /sbin/init splash
├─1424 bpfilter_umh
├─user.slice
│ ├─1064 gdm-session-worker [pam/gdm-launch-environment]
│ ├─1110 /lib/systemd/systemd --user
│ ├─1111 (sd-pam)
│ ├─1122 /usr/lib/gdm3/gdm-wayland-session gnome-session --autostart /usr/share/gdm/greeter/autostart
│ ├─1124 /usr/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
│ ...
│ ├─7768 systemd-cgls memory
│ └─7769 pager
└─system.slice
  ├─irqbalance.service
  │ └─795 /usr/sbin/irqbalance --foreground
  ├─bolt.service
  │ └─1626 /usr/lib/x86_64-linux-gnu/boltd
  ├─containerd.service
  │ └─873 /usr/bin/containerd
  ├─packagekit.service
  │ └─1630 /usr/lib/packagekit/packagekitd
  ├─systemd-udevd.service
  │ └─410 /lib/systemd/systemd-udevd
  ├─whoopsie.service
  │ └─1313 /usr/bin/whoopsie -f
```

```
# サービスのcgroupを確認
$ systemctl status sshd
● ssh.service - OpenBSD Secure Shell server
   Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2022-04-17 10:23:27 JST; 7h ago
  Process: 1868 ExecReload=/bin/kill -HUP $MAINPID (code=exited, status=0/SUCCESS)
  Process: 1862 ExecReload=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
  Process: 866 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
 Main PID: 884 (sshd)
    Tasks: 1 (limit: 4915)
   CGroup: /system.slice/ssh.service
           └─884 /usr/sbin/sshd -D
```

```
# 特定プロセスのcgroupを確認
$ cat /proc/884/cgroup
12:pids:/system.slice/ssh.service
11:devices:/system.slice/ssh.service
10:blkio:/system.slice/ssh.service
9:perf_event:/
8:freezer:/
7:rdma:/
6:memory:/system.slice/ssh.service
5:hugetlb:/
4:net_cls,net_prio:/
3:cpuset:/
2:cpu,cpuacct:/system.slice/ssh.service
1:name=systemd:/system.slice/ssh.service
0::/system.slice/ssh.service
```

```
#現在実行中の cgroups の動的アカウント（CPU、メモリー、および IO）を順番に表示する
$ systemd-cgtop
Control Group                                                                                                          Tasks   %CPU   Memory  Input/s Output/s
/                                                                                                                        542    2.0     2.5G        -        -
/user.slice                                                                                                              187    1.6   671.1M        -        -
/system.slice                                                                                                            148    0.2     2.5G        -        -
/system.slice/containerd.service                                                                                          25    0.2    62.7M        -        -
/system.slice/docker.service                                                                                              25    0.0   145.9M        -        -
...
```

## systemd 以外で cgroup を管理する

- cgroup は基本的に systemd によって管理することが推奨される
- libcgroup(cgconfig サービス)
  - systemd と競合するため非推奨
  - systemd でサポートされてないコントローラを管理する必要がある場合にのみ使用する
- mount による管理

## docker の cgroup

- cgroupdriver によって、cgroupfs か systemd を選べる
- --exec-opt native.cgroupdriver=systemd で設定できる

```
$ cat /proc/9286/cgroup
12:pids:/docker/d028dd1bd595cfa833a27bbf3fd6e4e8d079ea3bcefee240abaf6876c0353080
11:devices:/docker/d028dd1bd595cfa833a27bbf3fd6e4e8d079ea3bcefee240abaf6876c0353080
10:blkio:/docker/d028dd1bd595cfa833a27bbf3fd6e4e8d079ea3bcefee240abaf6876c0353080
9:perf_event:/docker/d028dd1bd595cfa833a27bbf3fd6e4e8d079ea3bcefee240abaf6876c0353080
8:freezer:/docker/d028dd1bd595cfa833a27bbf3fd6e4e8d079ea3bcefee240abaf6876c0353080
7:rdma:/
6:memory:/docker/d028dd1bd595cfa833a27bbf3fd6e4e8d079ea3bcefee240abaf6876c0353080
5:hugetlb:/docker/d028dd1bd595cfa833a27bbf3fd6e4e8d079ea3bcefee240abaf6876c0353080
4:net_cls,net_prio:/docker/d028dd1bd595cfa833a27bbf3fd6e4e8d079ea3bcefee240abaf6876c0353080
3:cpuset:/docker/d028dd1bd595cfa833a27bbf3fd6e4e8d079ea3bcefee240abaf6876c0353080
2:cpu,cpuacct:/docker/d028dd1bd595cfa833a27bbf3fd6e4e8d079ea3bcefee240abaf6876c0353080
1:name=systemd:/docker/d028dd1bd595cfa833a27bbf3fd6e4e8d079ea3bcefee240abaf6876c0353080
0::/system.slice/containerd.service
```

## 参考

- [Red Hat Enterprise Linux 7: リソース管理ガイド](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/resource_management_guide/chap-introduction_to_control_groups)

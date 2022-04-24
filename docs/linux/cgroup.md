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
- cgorup v1, cgroup v2 について
  - v1 と v2 は共存できるが、一つのコントローラを cgroup v1, cgropu v2 の両方にマウントすることはできない
  - v1 は複数階層構造をとるが、v2 では統合階層となり、すべてのコントローラを統合階層にマウントする
  - v2 では階層が簡素化された
  - v1 ではさまざまなコントローラを様々な階層にマウントでき、非常に柔軟性があるが、実際にこの機能が必要になることは少ない
  - cgroup v2 をファイルシステムにマウントすると、使用可能なすべてのコントローラが自動的にマウントされる
    - mount -tcgroup2 [mount point]

## mount の確認

- cgroup の初期化の流れ（デフォルトで各 cgroup コントローラをマウントする）
  - mount -t tmpfs cgroup_root /sys/fs/cgroup
  - tmpfs で/sys/fs/cgroup にマウント
  - サブディレクトリを作って cgroup コントローラをマウントする
    - mkdir /sys/fs/cgroup/cpuset
    - mount -t cgroup -ocpuset cpuset /sys/fs/cgroup/cpuset

```
$ mount | grep cgroup
tmpfs on /sys/fs/cgroup type tmpfs (ro,nosuid,nodev,noexec,mode=755)
cgroup on /sys/fs/cgroup/unified type cgroup2 (rw,nosuid,nodev,noexec,relatime,nsdelegate)
cgroup on /sys/fs/cgroup/systemd type cgroup (rw,nosuid,nodev,noexec,relatime,xattr,name=systemd)
cgroup on /sys/fs/cgroup/freezer type cgroup (rw,nosuid,nodev,noexec,relatime,freezer)
cgroup on /sys/fs/cgroup/net_cls,net_prio type cgroup (rw,nosuid,nodev,noexec,relatime,net_cls,net_prio)
cgroup on /sys/fs/cgroup/hugetlb type cgroup (rw,nosuid,nodev,noexec,relatime,hugetlb)
cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,cpu,cpuacct)
cgroup on /sys/fs/cgroup/devices type cgroup (rw,nosuid,nodev,noexec,relatime,devices)
cgroup on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,blkio)
cgroup on /sys/fs/cgroup/pids type cgroup (rw,nosuid,nodev,noexec,relatime,pids)
cgroup on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,memory)
cgroup on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,cpuset)
cgroup on /sys/fs/cgroup/rdma type cgroup (rw,nosuid,nodev,noexec,relatime,rdma)
cgroup on /sys/fs/cgroup/perf_event type cgroup (rw,nosuid,nodev,noexec,relatime,perf_event)
```

## 子 cgroup を作る

- 各 cgroup は、cgroup ファイルシステム内のディレクトリによって表される
- 最上位の cgroup ディレクトリから、子ディレクトリを作成していくことによって 子 cgroup を階層的に作ることができる
- cgroup ディレクトリには以下のファイルが含まれる
  - tasks: プロセス ID(PID)のリスト、このファイルに PID を書き込むとそのスレッドはこの cgroup に移動する
  - cgroup.procs: スレッドグループ ID(TGID)のリスト、このファイルに TGID を書き込むとその TGID に所属するすべてのスレッドはこの cgroup に移動する

```
# ディレクトリを作ると、配下に設定ファイルが自動で作られる
$ sudo mkdir /sys/fs/cgroup/cpuset/testgroup
$ ls /sys/fs/cgroup/cpuset/testgroup/
cgroup.clone_children  cpuset.cpus            cpuset.mem_exclusive   cpuset.memory_pressure     cpuset.mems                      notify_on_release
cgroup.procs           cpuset.effective_cpus  cpuset.mem_hardwall    cpuset.memory_spread_page  cpuset.sched_load_balance        tasks
cpuset.cpu_exclusive   cpuset.effective_mems  cpuset.memory_migrate  cpuset.memory_spread_slab  cpuset.sched_relax_domain_level

$ echo '2-3' | sudo tee /sys/fs/cgroup/cpuset/testgroup/cpuset.cpus
2-3

$ echo '0' | sudo tee /sys/fs/cgroup/cpuset/testgroup/cpuset.mems
0

$ echo $$ | sudo tee /sys/fs/cgroup/cpuset/testgroup/tasks
11837

$ cat /proc/self/cgroup
12:perf_event:/
11:rdma:/
10:cpuset:/testgroup
9:memory:/user.slice
8:pids:/user.slice/user-1000.slice/session-2.scope
7:blkio:/user.slice
6:devices:/user.slice
5:cpu,cpuacct:/user.slice
4:hugetlb:/
3:net_cls,net_prio:/
2:freezer:/
1:name=systemd:/user.slice/user-1000.slice/session-2.scope
0::/user.slice/user-1000.slice/session-2.scope
```

## blkio

- ブロックデバイスの IO 上限を設定できる
- 参考: https://www.kernel.org/doc/html/latest/admin-guide/cgroup-v1/blkio-controller.html

```
# テスト用のbashプロセスを開始して、testgroupのtasksに自身のPIDを書き込む
$ bash
$ sudo mkdir /sys/fs/cgroup/blkio/testgroup
$ ls /sys/fs/cgroup/blkio/testgroup
blkio.reset_stats                          blkio.throttle.io_serviced            blkio.throttle.read_iops_device   cgroup.clone_children  tasks
blkio.throttle.io_service_bytes            blkio.throttle.io_serviced_recursive  blkio.throttle.write_bps_device   cgroup.procs
blkio.throttle.io_service_bytes_recursive  blkio.throttle.read_bps_device        blkio.throttle.write_iops_device  notify_on_release
$ echo $$ | sudo tee /sys/fs/cgroup/blkio/testgroup/tasks
$ cat /proc/self/cgroup | grep blkio
11:blkio:/testgroup

# ルートデバイスのメージャー番号、マイナー番号(MAJ:MIN)を確認する
$ lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
...
nvme0n1     259:0    0 238.5G  0 disk
├─nvme0n1p1 259:1    0 206.6G  0 part /
├─nvme0n1p2 259:2    0     1K  0 part
└─nvme0n1p5 259:3    0    32G  0 part

# フォーマットは、[MAJ:MIN bytes_per_second]で、blkio.throttle.[read,write]_bps_deviceに書き込む
# 読み書きの速度を1MB/secにする
$ echo "259:0 1048576" | sudo tee /sys/fs/cgroup/blkio/testgroup/blkio.throttle.read_bps_device
$ echo "259:0 1048576" | sudo tee /sys/fs/cgroup/blkio/testgroup/blkio.throttle.write_bps_device
# 読み書きのiopsを1000にする
$ echo "259:0 1000" | sudo tee /sys/fs/cgroup/blkio/testgroup/blkio.throttle.read_iops_device
$ echo "259:0 1000" | sudo tee /sys/fs/cgroup/blkio/testgroup/blkio.throttle.write_iops_device

# 書き込みテスト
$ dd oflag=direct if=/dev/zero of=/tmp/ddtest bs=4k count=1024
# 読み込みテスト
$ dd iflag=direct if=/tmp/ddtest of=/dev/null bs=4K count=1024
```

## cpu,cpuacct

- cpu: こと cgroup の task に対して、CFS スケジューラのパラメータを調整できる
- cpuacct(accounting)は、CPU 利用率を計算する

```
$ sudo mkdir /sys/fs/cgroup/cpu,cpuacct/testgroup
$ ls /sys/fs/cgroup/cpu,cpuacct/testgroup
cgroup.clone_children  cpu.cfs_quota_us  cpu.uclamp.max  cpuacct.usage         cpuacct.usage_percpu_sys   cpuacct.usage_user
cgroup.procs           cpu.shares        cpu.uclamp.min  cpuacct.usage_all     cpuacct.usage_percpu_user  notify_on_release
cpu.cfs_period_us      cpu.stat          cpuacct.stat    cpuacct.usage_percpu  cpuacct.usage_sys          tasks

# 利用可能なcpuの確認
# 1024は1コアを意味し、ここに所属するスレッドは最大で1コア分を100%利用することができる
$ cat /sys/fs/cgroup/cpu,cpuacct/cpu.shares
1024

# デフォルトは1024
$ cat /sys/fs/cgroup/cpu,cpuacct/testgroup/cpu.shares
1024

# 別のcgroupを作成し、1024以上のcpu.sharesを割り当ててみる
# 今回の環境はCPUコアを12持っているので12288（12 * 1024）以上の利用はできないが、もし実利用量が12288を超えてしまう場合はsharesの値の比率でよしなに割り当てが行われる
$ sudo mkdir /sys/fs/cgroup/cpu,cpuacct/testgroup2
$ sudo mkdir /sys/fs/cgroup/cpu,cpuacct/testgroup3
$ echo 8192 | sudo tee /sys/fs/cgroup/cpu,cpuacct/testgroup2/cpu.shares
$ echo 12288 | sudo tee /sys/fs/cgroup/cpu,cpuacct/testgroup3/cpu.shares

# testgroupでstress -c 12をやった場合、CPUが余ってればちゃんと使い切る
$ stress -c 12
Average:      UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
Average:     1000     12403  100.00    0.00    0.00    0.00  100.00     -  stress
Average:     1000     12404  100.00    0.00    0.00    0.00  100.00     -  stress
Average:     1000     12405  100.00    0.00    0.00    0.00  100.00     -  stress
Average:     1000     12406  100.00    0.00    0.00    0.00  100.00     -  stress
Average:     1000     12407  100.00    0.00    0.00    0.00  100.00     -  stress
Average:     1000     12408  100.00    0.00    0.00    0.00  100.00     -  stress
Average:     1000     12409  100.00    0.00    0.00    0.00  100.00     -  stress
Average:     1000     12410   99.00    0.00    0.00    1.00   99.00     -  stress
Average:     1000     12411  100.00    0.00    0.00    0.00  100.00     -  stress
Average:     1000     12412  100.00    0.00    0.00    0.00  100.00     -  stress
Average:     1000     12413  100.00    0.00    0.00    0.00  100.00     -  stress
Average:     1000     12414  100.00    0.00    0.00    0.00  100.00     -  stress
```

## cpuset

- スレッドの利用可能な cpu、memory を限定できる
- 参考: https://www.kernel.org/doc/html/latest/admin-guide/cgroup-v1/cpusets.html

```
$ sudo mkdir /sys/fs/cgroup/cpuset/testgroup
$ ls /sys/fs/cgroup/cpuset/testgroup
cgroup.clone_children  cpuset.cpus            cpuset.mem_exclusive   cpuset.memory_pressure     cpuset.mems                      notify_on_release
cgroup.procs           cpuset.effective_cpus  cpuset.mem_hardwall    cpuset.memory_spread_page  cpuset.sched_load_balance        tasks
cpuset.cpu_exclusive   cpuset.effective_mems  cpuset.memory_migrate  cpuset.memory_spread_slab  cpuset.sched_relax_domain_level

# cpuを限定する
$ echo '2-3' | sudo tee /sys/fs/cgroup/cpuset/testgroup/cpuset.cpus
2-3
# memory nodeを限定する
$ echo '0' | sudo tee /sys/fs/cgroup/cpuset/testgroup/cpuset.mems
0
# 自身のPIDをcgroupに所属させる（cpus, memsを設定した後でないとこの操作は行えないので注意）
$ echo $$ | sudo tee /sys/fs/cgroup/cpuset/testgroup/tasks
11837
```

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

# 以下にdockerのサブディレクトリができてる
$ ls /sys/fs/cgroup/memory/docker
```

## 参考

- [Red Hat Enterprise Linux 7: リソース管理ガイド](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/resource_management_guide/chap-introduction_to_control_groups)

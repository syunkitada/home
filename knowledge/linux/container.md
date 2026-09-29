# Container

- コンテナの仕組みについて

## コンテナ上でプロセスを動かすということ

- プロセスにおける権限の制限
  - systemd(root) は、fork して、execve で sshd(root)を実行
  - sshd(root)は、ユーザから ssh で接続されると、fork して setuid でそのユーザへ変更し、execve で bash を実行する
  - 子プロセスは、親の権限やファイルディスクリプタを引き継ぐので、execve する前に権限を落としたり、見られたくないファイルを閉じる
  - 通常のプロセスではユーザの権限などである程度の制限をかけることは可能だが限界がある
- コンテナとはプロセスに制限を加えるためのユーザ空間のようなもので、以下のような技術からなる
  - chroot
    - プロセスがパス解決する際の root を変更する
  - capabilities
    - root が持つ特権を分割したものを capabilities と呼び、通常は子プロセスもこれをそのまま継承するが、この権限を制限することができる
  - namespace(名前空間)
    - プロセスの閲覧できるもの、利用できるものを制限する
    - namespace には以下のものがある(\$ ls -iL /proc/self/ns で確認できる)
      - mnt
      - uts
      - pid
      - pid_for_children namespace
      - ipc
      - user
      - net
  - cgroup
    - プロセスのリソースを制限する

## bind mount

- mount コマンドは、--bind オプションを付けるとディレクトリを別のディレクトリにマウントできる
- ファイルパスを解決するとき、マウントされたディレクトリ(flag のついてる dentry)ではその inode ではなく、マウントテーブルから対応する dentry を引いてパス解決する

```
$ sudo mount [ブロックデバイス] [マウントポイント]
$ sudo mount --bind [ディレクトリ] [マウントポイント]
```

## chroot

- プロセスを指定したディレクトリ以下に閉じ込める
- chroot する前にオープンしたファイルはそのパスにかかわらず読み書きできるので注意

```
# /usrをrootとしてbashを起動
$ sudo chroot /usr /bin/bash
bash-4.2# ls /
bin  etc  games  include  lib  lib64  libexec  local  sbin  share  src  tmp
```

```
# /tmp/xrootをrootとしてbashを起動
-bash-4.2$ sudo chroot /tmp/xroot /bin/bash
chroot: failed to run command ‘/bin/bash’: No such file or directory

-bash-4.2$ sudo mkdir /tmp/xroot/bin
-bash-4.2$ sudo mkdir /tmp/xroot/lib64
-bash-4.2$ sudo mount --bind /usr/bin/ /tmp/xroot/bin/
-bash-4.2$ sudo mount --bind /usr/lib64/ /tmp/xroot/lib64/
-bash-4.2$ sudo chroot /tmp/xroot /bin/bash
bash-4.2# ls /
bin  lib64

# 単体のコマンドを実行する場合は以下のように実行できる
-bash-4.2$ sudo chroot /tmp/xroot /bin/ls /
bin  lib64

# procをマウントする
bash-4.2# mkdir /proc
bash-4.2# mount -t proc none /proc
bash-4.2# ls /proc/
1     1369  14    2     2660  2865  30    3415  3585  52   737  843        consoles     filesystems  keys        modules       self           timer_stats
10    1370  1462  20    2681  2875  32    3416  37    53   740  849        cpuinfo      fs           kmsg        mounts        slabinfo       tty
11    1375  1504  21    2682  2876  3229  3463  38    66   751  9          crypto       interrupts   kpagecount  mtrr          softirqs       uptime
12    1379  16    2140  2697  2877  3231  3467  39    670  757  96         devices      iomem        kpageflags  net           stat           version
1229  1380  18    22    2698  29    3386  3526  40    7    765  acpi       diskstats    ioports      loadavg     pagetypeinfo  swaps          vmallocinfo
13    1381  182   23    27    2991  3389  3548  48    718  772  buddyinfo  dma          irq          locks       partitions    sys            vmstat
1359  1382  183   24    2798  2993  3391  3578  5     720  785  bus        driver       kallsyms     mdstat      sched_debug   sysrq-trigger  zoneinfo
1360  1383  19    25    28    2994  3395  3579  50    721  796  cgroups    execdomains  kcore        meminfo     schedstat     sysvipc
1361  1384  1916  26    2825  3     3396  3581  51    733  8    cmdline    fb           key-users    misc        scsi          timer_list
```

## 権限(capabilities)

- root が持つ特権を分割したものを capabilities と呼び、通常は子プロセスもこれをそのまま継承するが、この権限を制限することができる
- 詳細は、man capabilities を参照

```
$ sudo yum install libcap-ng-utils

# プロセスのCapabilitiesを確認する
$ pscap -a
ppid  pid   name        command           capabilities
0     1     root        systemd           full
1     1462  root        systemd-journal   chown, dac_override, dac_read_search, fowner, setgid, setuid, sys_ptrace, sys_admin, audit_control, mac_override, syslog
1     1504  root        systemd-udevd     full
1     1916  root        auditd            full
1     2682  root        gssproxy          full
1     2698  dbus        dbus-daemon       audit_write +
1     2798  chrony      chronyd           net_bind_service, sys_time +
1     2825  root        systemd-logind    chown, dac_override, dac_read_search, fowner, kill, sys_admin, sys_tty_config, audit_control, mac_admin
1     2875  root        crond             full
1     2876  root        agetty            full
1     2877  root        agetty            full
1     2991  root        sshd              full
1     2993  root        tuned             full
1     2994  root        rsyslogd          full
1     3229  root        master            full
2991  3389  root        sshd              full
2991  3391  root        sshd              full
```

## namespace

- /proc/N/ns からプロセス N がどの namespace に所属しているかわかる
  - /proc/N/ns 以下のファイルをネームスペース識別ファイル
- ネームスペースに所属する最後のプロセスが exit すると、そのネームスペースも消滅する
- ネームスペースを維持したい場合は、bind mount してファイルシステムツリーから参照した状態にしておく
- システムコール
  - clone
  - unshare
  - setns

```
# namespaceの確認
$ ls -iL /proc/self/ns
4026531839 ipc  4026531840 mnt  4026531956 net  4026531836 pid  4026531837 user  4026531838 uts

# プロセスのNSを表示する
$ lsns
NS TYPE  NPROCS   PID USER  COMMAND
4026531836 pid        3  3396 goapp -bash
4026531837 user       3  3396 goapp -bash
4026531838 uts        3  3396 goapp -bash
4026531839 ipc        3  3396 goapp -bash
4026531840 mnt        3  3396 goapp -bash
4026531956 net        3  3396 goapp -bash

# psコマンドでプロセスのNSを表示する
$ sudo ps -eo pid,pidns,netns,mntns,comm,args
...
```

## uts namespace

```
# 親NS
-bash-4.2$ ls -iL /proc/self/ns/uts
4026531838 /proc/self/ns/uts
-bash-4.2$ hostname
localhost

# 子NSを作成してhostnameを変更する
-bash-4.2$ sudo unshare --uts /bin/bash
[root@localhost /]# hostname
localhost
[root@localhost /]# hostname myhost
[root@localhost /]# hostname
myhost
[root@localhost /]# ls -iL /proc/self/ns/uts
4026532216 /proc/self/ns/uts
[root@localhost /]# exit
exit

# 親NSのhostnameはそのまま
-bash-4.2\$ hostname
localhost
```

```
# straceで観察する
$ sudo LC_ALL=C strace -o unshare.log unshare --uts /bin/true
execve("/bin/unshare", ["unshare", "--uts", "/bin/true"], 0x7ffdee418530 /* 27 vars _/) = 0
...
unshare(CLONE_NEWUTS) = 0
execve("/bin/true", ["/bin/true"], 0x7ffea1ea2c78 /_ 27 vars \_/) = 0
...

```

## pid, pid_for_children namespace

- pid とプロセスの対応関係を分離する
- namespace を削除するとその配下のプロセスも削除される
- pid namespace
  - 自身が所属する
- pid_for_children
  - 自身から派生する子プロセスが所属する

```
# kernel
$ ls -iL /proc/self/ns/pid*
4026531836 /proc/self/ns/pid

# kernel 4.12から
$ ls -iL /proc/self/ns/pid*
4026531836 /proc/self/ns/pid  4026531836 /proc/self/ns/pid_for_children
```

```
# 子NSを作成してsleepを実行する
$ sudo unshare --pid --fork --mount-proc /bin/bash
# sleep 3600 &
# pstree -anpl
bash,1
  ├─sleep,16 3600
    └─pstree,17 -anpl
```

```
# 親から子NSのpidを見る
$ sudo ls -iL /proc/3944/ns/pid
4026532217 /proc/3944/ns/pid

$ sleep 60 &
[1] 3993

-bash-4.2$ ls -iL /proc/4010/ns/pid
4026531836 /proc/4010/ns/pid

-bash-4.2$ sleep 600 &
[1] 4010
-bash-4.2$ sudo ps -eo pid,pidns,comm,args  | grep sleep
 3944 4026532217 sleep           sleep 3600
 4010 4026531836 sleep           sleep 600
 4012 4026531836 grep            grep --color=auto sleep
```

## mnt namespace

- プロセスから見えているマウントの集合、操作を分離する
- Namespace 内の mount, umount は他の Namespace には影響しない

```
-bash-4.2$ sudo mount --bind /tmp/mnttestsrc /tmp/mnttestdest

-bash-4.2$ sudo unshare --mount /bin/bash
[root@localhost /]# mount | grep mnttest
/dev/vda1 on /tmp/mnttestdest type xfs (rw,relatime,seclabel,attr2,inode64,noquota)
[root@localhost /]# umount /tmp/mnttestdest
[root@localhost /]# mount | grep mnttest
[root@localhost /]#
```

親からは mount されたまま

```
-bash-4.2$ mount | grep mnttest
/dev/vda1 on /tmp/mnttestdest type xfs (rw,relatime,seclabel,attr2,inode64,noquota)
```

```
# 親側で新たにmountする
-bash-4.2$ mount | grep mnttest
/dev/vda1 on /tmp/mnttestdest type xfs (rw,relatime,seclabel,attr2,inode64,noquota)
/dev/vda1 on /tmp/mnttestdest2 type xfs (rw,relatime,seclabel,attr2,inode64,noquota)

# 子側でには反映されない
[root@localhost /]# mount | grep mnttest
[root@localhost /]#

```

unsahre --mount --propaganation slave
親から子へ伝搬する

unsahre --mount --propaganation shared
双方へ伝搬する

## net namespace

- ネットワークデバイス、アドレス、ルーティングテーブル、ARP テーブル、ソケット、iptables の設定を分離
- 親からの継承はなしで、ほぼ新しい空間が用意される

```
# unshareコマンドでnet namespaceを作成
$ sudo unshare --net /bin/bash

[root@localhost /]# ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
```

```
# ipコマンドで名前付きでnet namespaceを作成
$ sudo ip netns add mynet

$ sudo nsenter --net=/var/run/netns/mynet ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
```

```
# netnsの一覧
$ sudo ip netns
mynet

# netns内でコマンドを実行する
$ sudo ip netns exec mynet bash
[root@localhost /]# ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
```

## user namespace

- user namespace は一般ユーザでも作れる
- namespace 内のユーザを特権ユーザとして作成することもできる
  - 権限は作ったユーザの権限となる
  - uid は 0 になる

```
$ unshare --user id
uid=65534(nobody) gid=65534(nogroup) groups=65534(nogroup)

$ unshare --user --map-root-user id
uid=0(root) gid=0(root) groups=0(root),65534(nogroup)
```

## References

- [Linux コンテナの内部を知ろう](https://speakerdeck.com/tenforward/osc-2018-kyoto)
- [Linux Namespaces](https://www.slideshare.net/masamiichikawa/linux-namespaces-53216942)
- [Kubernetes で cgroup がどう利用されているか](https://valinux.hatenablog.com/entry/20210114)

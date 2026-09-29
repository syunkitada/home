# Reboot Reason

まずは、lastでrebootの時刻を確認します。

```
$ last

# rebootに限定してlastを表示する
$ last reboot
```

次に、journalのログを確認します。

```
sudo journalctl -r
```

journalのログから特定できない場合、はシステム以外のログを探すと良い。

- VMを一度に大量に停止したときにカーネルパニックになることがあった
  - kdumpを使っていなかったので具体的な原因は不明である
  - リブート発生時間に行われたユーザの作業履歴などから間接な原因を知れる場合もある

## 事例1: rebootコマンド

一般的なrebootでは、ログが残るのでその原因が特定しやすい。

```
$ sudo reboot -h now
```

```
23:34 [0] owner@owner-desktop:~
$ last | head
owner    pts/0        192.168.10.5     Sun Sep 29 23:34   still logged in
reboot   system boot  5.15.0-122-gener Sun Sep 29 23:33   still running
owner    pts/0        192.168.10.5     Sun Sep 29 20:24 - 23:33  (03:09)
```

```
$ sudo journalctl -r
...
Sep 29 23:33:55 owner-desktop kernel: Command line: BOOT_IMAGE=/boot/vmlinuz-5.15.0-122-generic root=UUID=cf4b9c48-9b8d-43de-9441-1742c7822e41 ro default_hug>
Sep 29 23:33:55 owner-desktop kernel: Linux version 5.15.0-122-generic (buildd@lcy02-amd64-034) (gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, GNU ld (GNU Binut>
-- Boot cf09611ec30e4158913bb9827cee6c2b --
Sep 29 23:33:27 owner-desktop systemd-journald[433]: Journal stopped
Sep 29 23:33:27 owner-desktop systemd-shutdown[1]: Sending SIGTERM to remaining processes...
Sep 29 23:33:27 owner-desktop systemd-shutdown[1]: Syncing filesystems and block devices.
Sep 29 23:33:27 owner-desktop systemd[1]: Shutting down.
Sep 29 23:33:27 owner-desktop systemd[1]: Reached target System Reboot.
Sep 29 23:33:27 owner-desktop systemd[1]: Finished System Reboot.
...
Sep 29 23:33:14 owner-desktop systemd-journald[22]: Received SIGTERM.
Sep 29 23:33:14 owner-desktop systemd-journald[22]: Received SIGTERM.
Sep 29 23:33:14 owner-desktop systemd[1]: Stopping libcontainer container 0900ea45cf5ca39db85f57b4e0814801ae76d736be588f4c41f36b000e84bef8...
Sep 29 23:33:14 owner-desktop sudo[2181498]: pam_unix(sudo:session): session opened for user root(uid=0) by owner(uid=1000)
Sep 29 23:33:14 owner-desktop sudo[2181498]:    owner : TTY=pts/0 ; PWD=/home/owner ; USER=root ; COMMAND=/usr/sbin/reboot -h now
```

## 事例2: kernelパニック

sysrq-triggerでカーネルパニックを強制的に発生させてるので、ログとして原因がわかるが、kdumpを使ってないとその原因が分からないことが多い。

```
$ sudo sysctl -w kernel.panic=1
kernel.panic = 1
```

```
$ sudo sh -c 'echo c > /proc/sysrq-trigger'
```

```
$ last | head
owner    pts/0        192.168.10.5     Sun Sep 29 23:42   still logged in
reboot   system boot  5.15.0-122-gener Sun Sep 29 23:42   still running
owner    pts/0        192.168.10.5     Sun Sep 29 23:34 - crash  (00:08)
```

```
Sep 29 23:42:23 owner-desktop kernel: KERNEL supported cpus:
Sep 29 23:42:23 owner-desktop kernel: Command line: BOOT_IMAGE=/boot/vmlinuz-5.15.0-122-generic root=UUID=cf4b9c48-9b8d-43de-9441-1742c7822e41 ro default_hug>
Sep 29 23:42:23 owner-desktop kernel: Linux version 5.15.0-122-generic (buildd@lcy02-amd64-034) (gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, GNU ld (GNU Binut>
-- Boot fed64e96a7a846cf8a23e6fef7c77008 --
Sep 29 23:41:51 owner-desktop sshd[2021]: debug2: channel 0: rcvd adjust 34662
Sep 29 23:41:50 owner-desktop sshd[2021]: debug2: channel 0: rcvd adjust 34083
Sep 29 23:41:50 owner-desktop sshd[2021]: debug2: channel 0: rcvd adjust 34203
Sep 29 23:41:38 owner-desktop sshd[2021]: debug2: channel 0: rcvd adjust 33630
Sep 29 23:41:35 owner-desktop sshd[2021]: debug2: channel 0: rcvd adjust 32777
Sep 29 23:41:33 owner-desktop sshd[2021]: debug2: channel 0: rcvd adjust 34188
Sep 29 23:41:16 owner-desktop sshd[2021]: debug2: channel 0: rcvd adjust 32904
Sep 29 23:41:08 owner-desktop sudo[2597]: pam_unix(sudo:session): session closed for user root
Sep 29 23:41:08 owner-desktop sudo[2597]: pam_unix(sudo:session): session opened for user root(uid=0) by (uid=1000)
Sep 29 23:41:08 owner-desktop sudo[2597]:    owner : TTY=pts/1 ; PWD=/home/owner ; USER=root ; COMMAND=/usr/sbin/sysctl -w kernel.panic=1
```

## 事例3: 電源ボタン長押し

ログはのこらない。

```
$ last | head
owner    pts/1        192.168.10.5     Mon Sep 30 00:05   still logged in
reboot   system boot  5.15.0-122-gener Mon Sep 30 00:05   still running
owner    pts/0        192.168.10.5     Mon Sep 30 00:01 - 00:01  (00:00)
owner    pts/0        192.168.10.5     Mon Sep 30 00:01 - 00:01  (00:00)
```

```
$ sysctl -r
Sep 30 00:05:35 owner-desktop kernel: KERNEL supported cpus:
Sep 30 00:05:35 owner-desktop kernel: Command line: BOOT_IMAGE=/boot/vmlinuz-5.15.0-122-generic root=UUID=cf4b9c48-9b8d-43de-9441-1742c7822e41 ro default_hug>
Sep 30 00:05:35 owner-desktop kernel: Linux version 5.15.0-122-generic (buildd@lcy02-amd64-034) (gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, GNU ld (GNU Binut>
-- Boot 34218966b142499da02380c32084c62d --
Sep 30 00:05:01 owner-desktop CRON[2681]: (root) CMD (command -v debian-sa1 > /dev/null && debian-sa1 1 1)
Sep 30 00:05:01 owner-desktop CRON[2680]: pam_unix(cron:session): session opened for user root(uid=0) by (uid=0)
Sep 30 00:03:50 owner-desktop systemd[1]: systemd-timedated.service: Deactivated successfully.
Sep 30 00:03:48 owner-desktop snapd[862]: storehelpers.go:923: cannot refresh snap "firefox": snap has no updates available
Sep 30 00:03:47 owner-desktop systemd[1]: snap.firefox.hook.configure-e0174bbe-7bb5-4fbd-aa3e-d6b5b4743372.scope: Deactivated successfully.
```

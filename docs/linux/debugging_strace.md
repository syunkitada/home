# strace

- strace いろいろ

## Linux サーバでネットワーク I/O で刺さっている接続先を発見する

- 問題対応のため、怪しいプロセスを strace してみる
- read(2)や write(2)でブロックしていることを発見する
- read(2)や write(2)、connect(2)の引数にはファイルディスクリプタ番号がみえる
- プロセス ID とファイルディスクリプタ番号を使って、/proc//fd/ の中身をみると、ソケット I/O で刺さっている場合はソケット番号を発見できる
- netstat からソケット番号で grep して接続先を発見する
- /proc を直接見ずに、strace してから lsof -i -a -p <pid> などを使っているかもしれない

```
$ sudo strace -p 10471
Process 10471 attached - interrupt to quit
read(58,  <unfinished ...>
Process 10471 detached

$ sudo readlink /proc/10471/fd/58
socket:[1148032788]

# IPアドレス 10.0.0.11 に対する3306番ポート(MySQL)の接続で詰まっていることがわかる。
$ netstat -ane | grep 1148032788
tcp        0      0 10.0.0.10:44566            10.0.0.11:3306           ESTABLISHED 48         1148032788
```

## 子プロセスも一緒に、トレースする

```
strace -f [command]
```

## fd のファイルパスを表示する

```
strace -y [command]
```

```
$ strace -v -s 1024 -e trace=uname -C  uname -a
uname({sysname="Linux", nodename="owner-desktop", release="5.4.0-48-generic", version="#52~18.04.1-Ubuntu SMP Thu Sep 10 12:50:22 UTC 2020", machine="x86_64", domainname="(none)"}) = 0
uname({sysname="Linux", nodename="owner-desktop", release="5.4.0-48-generic", version="#52~18.04.1-Ubuntu SMP Thu Sep 10 12:50:22 UTC 2020", machine="x86_64", domainname="(none)"}) = 0
uname({sysname="Linux", nodename="owner-desktop", release="5.4.0-48-generic", version="#52~18.04.1-Ubuntu SMP Thu Sep 10 12:50:22 UTC 2020", machine="x86_64", domainname="(none)"}) = 0
Linux owner-desktop 5.4.0-48-generic #52~18.04.1-Ubuntu SMP Thu Sep 10 12:50:22 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
+++ exited with 0 +++
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
  0.00    0.000000           0         3           uname
  ------ ----------- ----------- --------- --------- ----------------
  100.00    0.000000                     3           total
```

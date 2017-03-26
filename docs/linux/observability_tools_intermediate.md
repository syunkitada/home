# Observability tools intermediate

## strace

## strace
```
$ sudo strace -tttT -p 12010
Process 12010 attached
1490533750.045816 accept4(4, {sa_family=AF_INET6, sin6_port=htons(37074), inet_pton(AF_INET6, "::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, [28], SOCK_CLOEXEC) = 9 <5.685130>
1490533755.731239 getsockname(9, {sa_family=AF_INET6, sin6_port=htons(80), inet_pton(AF_INET6, "::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, [28]) = 0 <0.000075>
1490533755.731445 fcntl(9, F_GETFL)     = 0x2 (flags O_RDWR) <0.000059>
1490533755.731619 fcntl(9, F_SETFL, O_RDWR|O_NONBLOCK) = 0 <0.000098>
1490533755.731898 read(9, "GET / HTTP/1.1\r\nUser-Agent: curl"..., 8000) = 73 <0.000061>
1490533755.732162 stat("/var/www/html/", {st_mode=S_IFDIR|0755, st_size=23, ...}) = 0 <0.000068>
1490533755.732467 stat("/var/www/html/index.html", {st_mode=S_IFREG|0644, st_size=12, ...}) = 0 <0.000059>
1490533755.732663 open("/var/www/html/index.html", O_RDONLY|O_CLOEXEC) = 10 <0.000084>
1490533755.732874 read(9, 0x7fa371536278, 8000) = -1 EAGAIN (Resource temporarily unavailable) <0.000053>
1490533755.733033 mmap(NULL, 12, PROT_READ, MAP_SHARED, 10, 0) = 0x7fa36f7a4000 <0.000052>
1490533755.733168 writev(9, [{"HTTP/1.1 200 OK\r\nDate: Sun, 26 M"..., 240}, {"hello world\n", 12}], 2) = 252 <0.001855>
1490533755.735228 munmap(0x7fa36f7a4000, 12) = 0 <0.000064>
1490533755.735395 write(7, "::1 - - [26/Mar/2017:13:09:15 +0"..., 79) = 79 <0.000075>
1490533755.735559 times({tms_utime=0, tms_stime=0, tms_cutime=0, tms_cstime=0}) = 431041330 <0.000058>
1490533755.735809 close(10)             = 0 <0.000056>
1490533755.735956 poll([{fd=9, events=POLLIN}], 1, 5000) = 1 ([{fd=9, revents=POLLIN}]) <0.000051>
1490533755.736094 read(9, "", 8000)     = 0 <0.000048>
1490533755.736223 shutdown(9, SHUT_WR)  = 0 <0.000118>
1490533755.736412 poll([{fd=9, events=POLLIN}], 1, 2000) = 1 ([{fd=9, revents=POLLIN|POLLHUP}]) <0.000049>
1490533755.736557 read(9, "", 512)      = 0 <0.000045>
1490533755.736664 close(9)              = 0 <0.000155>
1490533755.736885 read(5, 0x7ffc8fdf43ff, 1) = -1 EAGAIN (Resource temporarily unavailable) <0.000040>
1490533755.736998 accept4(4,


# ファイルに出力する
$ sudo strace -tttT -p 12010 -o test.log

# 統計情報を表示する
$ sudo strace -p 21479 -c
strace: Process 21479 attached
^Cstrace: Process 21479 detached
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
  0.00    0.000000           0         8           futex
  0.00    0.000000           0         1           epoll_wait
------ ----------- ----------- --------- --------- ----------------
100.00    0.000000                     9           total
```
プロセスが呼び出すシステムコールをトレースする。
このときシステムコールがエラーになる箇所を探すと、不具合の手掛かりになる。


# lsof
ファイルディスクリプタを使っているプロセスを調べる
```
$ sudo lsof -i:80
COMMAND   PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
httpd   12009   root    4u  IPv6  31227      0t0  TCP *:http (LISTEN)
httpd   12010 apache    4u  IPv6  31227      0t0  TCP *:http (LISTEN)
httpd   12011 apache    4u  IPv6  31227      0t0  TCP *:http (LISTEN)
httpd   12012 apache    4u  IPv6  31227      0t0  TCP *:http (LISTEN)
httpd   12013 apache    4u  IPv6  31227      0t0  TCP *:http (LISTEN)
httpd   12014 apache    4u  IPv6  31227      0t0  TCP *:http (LISTEN)

```


# sar
System Activity Reporter
``` bash
$ sar -n TCP,ETCP,DEV 1
```

collectl
atop
dstat

# strace
* strace いろいろ


## LinuxサーバでネットワークI/Oで刺さっている接続先を発見する
* 問題対応のため、怪しいプロセスをstraceしてみる
* read(2)やwrite(2)でブロックしていることを発見する
* read(2)やwrite(2)、connect(2)の引数にはファイルディスクリプタ番号がみえる
* プロセスIDとファイルディスクリプタ番号を使って、/proc//fd/ の中身をみると、ソケットI/Oで刺さっている場合はソケット番号を発見できる
* netstat からソケット番号でgrepして接続先を発見する
* /procを直接見ずに、straceしてからlsof -i -a -p <pid> などを使っているかもしれない
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

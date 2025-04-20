# tar

[DOC] ファイルの圧縮・解凍をします

## pixz(xz) で圧縮・解凍

- pixz を利用しなくても xz 圧縮はできるが、pixz を使うと並列で圧縮できる

```
$ sudo apt install pixz

# 圧縮
$ tar -I pixz -cf HOGE.tar.xz ./HOGE
# 解凍
$ tar -I pixz -xf HOGE.tar.xz
```

## zstd で圧縮・解凍

```
$ yum install zstd
$ apt install zstd

# 圧縮
$ tar -I zstd -cf foo.tar.zst /path/to/foo
# 解凍
$ tar -I zstd -xf foo.tar.zst /path/to/foo
```

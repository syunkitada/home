# tar

[DOC] ファイルの圧縮・解凍をします

## zstd で圧縮

```
yum install zstd
tar cf foo.tar.zst --use-compress-program=zstd /path/to/foo
```

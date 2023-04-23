# tar

## zstd で圧縮

```
yum install zstd
tar cf foo.tar.zst --use-compress-program=zstd /path/to/foo
```

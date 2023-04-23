# rsync

## How

```
$ rsync [options] [src] [dest]
```

- basic options
  - -n: dryrun
  - -r: recuresive
  - -v: verbose
  - --delete: delete file
  - --exclude [pattern]: exclude file pattern
- options for file attributes
  - -t: timestamp
  - -p: permission
  - -g: group
  - -o: owner

## Examples

```
# hogeディレクトリ内の node_modules 以外を同期する
$ rsync -r --delete --exclude *node_modules* hoge/ hoge.com:hoge/
```

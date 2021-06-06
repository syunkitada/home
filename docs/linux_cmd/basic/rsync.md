# rsync


## How

```
$ rsync [options] [src] [dest]
```

* basic options
  * -n: dryrun
  * -r: recuresive
  * -v: verbose
  * --delete: delete file
  * --exclude [pattern]: exclude file pattern

* options for file attributes
  * -t: timestamp
  * -p: permission
  * -g: group
  * -o: owner


## Examples

```
$ rsync -r --delete --exclude *node_modules* hoge/ hoge.com:hoge/
```

# find

[DOC] ファイルを検索します

## find して rename する

```
$ find ./ -iname '*hoge*' | xargs rename 's/hoge/piyo/g'
```

## 全ファイルの tab を space に置換する

```
$ find ./ -type f | xargs sed -i 's/\t/        /g'
```

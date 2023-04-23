# grep

[DOC] ファイル内の文字列を検索します

## grep して sed する

```
$ grep -l hoge * -r | xargs sed -i 's/hoge/piyo/g'
```

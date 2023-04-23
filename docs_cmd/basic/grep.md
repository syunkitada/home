# grep


## grepしてsedする
```
$ grep -l hoge * -r | xargs sed -i 's/hoge/piyo/g'
```

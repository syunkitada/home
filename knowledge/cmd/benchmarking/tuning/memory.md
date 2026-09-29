# memory


## enable THP
```
$ sudo sh -c 'echo always > /sys/kernel/mm/transparent_hugepage/enabled'
$ cat /sys/kernel/mm/transparent_hugepage/enabled
[always] madvise never

$ sudo sh -c 'echo always > /sys/kernel/mm/transparent_hugepage/defrag'
$ cat /sys/kernel/mm/transparent_hugepage/defrag
[always] madvise never

$ sudo sh -c 'echo 1 > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag'
$ cat /sys/kernel/mm/transparent_hugepage/khugepaged/defrag
1
```


## disable THP
```
$ sudo sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'
$ cat /sys/kernel/mm/transparent_hugepage/enabled
always madvise [never]

$ sudo sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/defrag'
$ cat /sys/kernel/mm/transparent_hugepage/defrag
always madvise [never]

$ sudo sh -c 'echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag'
$ cat /sys/kernel/mm/transparent_hugepage/khugepaged/defrag
0
```

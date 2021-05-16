# perf

- Linux（主にカーネル）の性能に関する情報を収集、分析するためのツール

## perf record (トレースデータの採取)

- オプション
  - -a: 全ての CPU のデータを採取します（デフォルトの動作）
  - -C/--cpu (cpu number): 採取するデータを、指定した CPU のデータに限定します
  - -g/--call-graph: バックトレース情報も採取します
  - -o [file name]: 出力ファイル名を指定します（デフォルト：perf.data）
  - -e [event regex]: イベント名の正規表現をしていして、採取するイベントを限定します
    - 採取するイベントが複数ある場合は、-e を複数指定する
    - perf -e sched:\* -e net:\* ...

```
# -o でrecordデータの出力先を指定できる
# デフォルトは、perf.data
$ sudo perf record -o perf.data ./main.o

# -i でrecordデータの入力元を指定できる
# デフォルトは、perf.data
$ sudo perf report -i perf.data

# トレースできるイベント一覧を表示
$ perf list
```

```
# プロファイルデータの採取
# -Fでサンプリング頻度を指定して採取する
$ perf record -F 99 -C 0 --call-graph dwarf
```

## perf report

- perf script コマンドを使って、他のスクリプトで解析するための情報として出力することも可能

## top

```
$ perf top
Samples: 544  of event 'cpu-clock', Event count (approx.): 39421099
Overhead  Shared Object                       Symbol
   9.44%  [kernel]                            [k] _raw_spin_unlock_irqrestore
   4.81%  perf                                [.] perf_evsel__parse_sample
   4.50%  libslang.so.2.2.4                   [.] SLsmg_write_chars
   3.30%  perf                                [.] symbols__insert
   3.24%  [kernel]                            [k] __do_softirq
   3.00%  [kernel]                            [k] finish_task_switch
```

## perf stat

```
# パフォーマンスカウンタを記録し、表示する
$ sudo perf stat -a
^C
 Performance counter stats for 'system wide':

       2277.468427      task-clock (msec)         #    1.000 CPUs utilized
               119      context-switches          #    0.052 K/sec
                 0      cpu-migrations            #    0.000 K/sec
                 4      page-faults               #    0.002 K/sec
   <not supported>      cycles
   <not supported>      instructions
   <not supported>      branches
   <not supported>      branch-misses

       2.277409566 seconds time elapsed
```

## References

- [Perf Wiki](https://perf.wiki.kernel.org/index.php/Main_Page)
- [perf Examples](http://www.brendangregg.com/perf.html)
- [perf を使った性能分析 I](https://valinux.hatenablog.com/entry/20201112)
- [perf を用いたシステムのボトルネック解析方法](https://ittechnicalmemos.blogspot.com/2019/09/perf.html)

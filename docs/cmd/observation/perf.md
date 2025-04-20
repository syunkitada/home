# perf

Linux（主にカーネル）の性能に関する情報を収集、分析するためのツールです。

基本的な使いかたは、データをperf recordで収集し、perf reportで分析するという使いかたです。

```
# -o でrecordデータの出力先を指定できる
# デフォルトは、perf.data
$ sudo perf record -o perf.data
^C
[ perf record: Woken up 4 times to write data ]
[ perf record: Captured and wrote 3.718 MB perf.data (49253 samples) ]

# -i でrecordデータの入力元を指定できる
# デフォルトは、perf.data
$ sudo perf report -i perf.data
```

## perf record

- 基本オプション
  - -a: 全ての CPU のデータを採取します（デフォルトの動作）
  - -C/--cpu (cpu number): 採取するデータを、指定した CPU のデータに限定します
  - -g/--call-graph: バックトレース情報も採取します
  - -o [file name]: 出力ファイル名を指定します（デフォルト：perf.data）

### トレースデータの採取

- -e [event regex]: イベント名の正規表現を指定して、採取するイベントを限定します
  - 採取するイベントが複数ある場合は、-e を複数指定する

トレースできるイベント一覧は、perf list で確認できます

```
$ perf list
...
```

以下は、スケジューラとネットワークのイベントを採取する例です。

```
$ sudo perf record -o perf.data -e sched:\* -e net:\*
```

### プロファイルデータの採取

- -F [frequency]: サンプリング頻度を指定して、プロファイルデータを採取します

以下の例は、99Hz でCPU 0のプロファイルデータを、dwarf情報に基づくバックトレース付きで採取する例です。

```
$ sudo perf record -o perf.data -F 99 -C 0 --call-graph dwarf
```

## perf report

- 基本オプション
  - -i [file name]: 入力ファイル名を指定します（デフォルト：perf.data）
  - -g/--call-graph: バックトレース情報を表示します
- perf script コマンドを使って、他のスクリプトで解析するための情報として出力することも可能です

## perf top

```
$ sudo perf top
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

パフォーマンスカウンタを記録し、表示します。

```
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

## スケジューラの挙動を見る

```
$ sudo pidstat -p 2986 1
11時45分09秒   UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
11時44分58秒  1000      2986   25.00   75.00    0.00    0.00  100.00     9  yes
11時44分59秒  1000      2986   22.00   78.00    0.00    0.00  100.00     9  yes
11時45分00秒  1000      2986   22.00   77.00    0.00    0.00   99.00     9  yes
11時45分01秒  1000      2986   24.00   77.00    0.00    0.00  100.00     8  yes
11時45分02秒  1000      2986   17.00   83.00    0.00    0.00  100.00     8  yes
11時45分03秒  1000      2986   22.00   77.00    0.00    0.00   99.00     8  yes
11時45分04秒  1000      2986   28.00   72.00    0.00    0.00  100.00     8  yes
11時45分05秒  1000      2986   22.00   78.00    0.00    0.00  100.00     8  yes
11時45分06秒  1000      2986   22.00   78.00    0.00    0.00  100.00     8  yes
11時45分07秒  1000      2986   24.00   76.00    0.00    0.00  100.00     9  yes
11時45分08秒  1000      2986   25.00   76.00    0.00    0.00  100.00     9  yes
11時45分09秒  1000      2986   23.00   77.00    0.00    0.00  100.00     9  yes

$ ps ax | grep yes
 2986 pts/1    R+    97:44 yes
 6765 pts/3    S+     0:00 grep --color yes

$ sudo perf stat -p 2986 -e "sched:*,task:*,cs,migrations"
^C
 Performance counter stats for process id '2986':

                 0      sched:sched_kthread_stop
                 0      sched:sched_kthread_stop_ret
             1,296      sched:sched_waking
             1,277      sched:sched_wakeup
                 0      sched:sched_wakeup_new
             1,274      sched:sched_switch
                 2      sched:sched_migrate_task
                 0      sched:sched_process_free
                 0      sched:sched_process_exit
                 0      sched:sched_wait_task
                 0      sched:sched_process_wait
                 0      sched:sched_process_fork
                 0      sched:sched_process_exec
                 0      sched:sched_stat_wait
                 0      sched:sched_stat_sleep
                 0      sched:sched_stat_iowait
                 0      sched:sched_stat_blocked
    13,832,546,943      sched:sched_stat_runtime
                 0      sched:sched_pi_setprio
                 0      sched:sched_process_hang
                 0      sched:sched_move_numa
                 0      sched:sched_stick_numa
                 0      sched:sched_swap_numa
                 0      sched:sched_wake_idle_without_ipi
                 0      task:task_newtask
                 0      task:task_rename
             1,274      cs
                 2      migrations

      13.835219614 seconds time elapsed


$ ps ax | grep migration
   12 ?        S      0:00 [migration/0]
   17 ?        S      0:00 [migration/1]
   23 ?        S      0:00 [migration/2]
   29 ?        S      0:00 [migration/3]
   35 ?        S      0:00 [migration/4]
   41 ?        S      0:00 [migration/5]
   47 ?        S      0:00 [migration/6]
   53 ?        S      0:00 [migration/7]
   59 ?        S      0:00 [migration/8]
   65 ?        S      0:00 [migration/9]
   71 ?        S      0:00 [migration/10]
   77 ?        S      0:00 [migration/11]
```

```
$ sudo perf sched record -- sleep 1
$ sudo perf script --header

# summarize scheduler latencies by task, including average and maximum delay:
$ sudo perf sched latency

# shows all CPUs and context-switch events, with columns representing what each CPU was doing and when.
$ sudo perf sched map

# shows the scheduler latency by event, including the time the task was waiting to be woken up (wait time) and the scheduler latency after wakeup to running (sch delay).
$ sudo perf sched timehist

# -M to add migration events
# -V to add a CPU visualization column
# -w to add wakeup events
$ sudo perf sched timehist -MVw
```

## References

- [Perf Wiki](https://perf.wiki.kernel.org/index.php/Main_Page)
- [perf Examples](http://www.brendangregg.com/perf.html)
- [perf を使った性能分析 I](https://valinux.hatenablog.com/entry/20201112)
- [perf を用いたシステムのボトルネック解析方法](https://ittechnicalmemos.blogspot.com/2019/09/perf.html)

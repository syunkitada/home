# sched

## schedule()

- schedule() の目的は、現在実行中のプロセスをほかのプロセスに置き換えること
- ローカル変数の next に、次に実行すべきプロセスのディスクリプタへのポインタを設定する

```c:kernel/sched/core.c
4138 asmlinkage __visible void __sched schedule(void)
4139 {
4140     struct task_struct *tsk = current;
4141
4142     sched_submit_work(tsk);
4143     do {
4144         preempt_disable();
4145         __schedule(false);
4146         sched_preempt_enable_no_resched();
4147     } while (need_resched());
4148     sched_update_worker(tsk);
4149 }
4150 EXPORT_SYMBOL(schedule);


3545 static void __sched __schedule(void)
3546 {
3547     struct task_struct *prev, *next;
3548     unsigned long *switch_count;
3549     struct rq *rq;
3550     int cpu;
...
3603     next = pick_next_task(rq, prev);
...
3638     balance_callback(rq);
3639
3640     sched_preempt_enable_no_resched();
3641     if (need_resched())
3642         goto need_resched;
3643 }
```

- pick_next_task で、次のプロセスを取得する
- カレントプロセスよりも優先度の高いプロセスがなければ、next はカレントプロセスを指し、プロセス切り替えは起こらない

```
3469 /*
3470  * Pick up the highest-prio task:
3471  */
3472 static inline struct task_struct *
3473 pick_next_task(struct rq *rq, struct task_struct *prev)
3474 {
3475     const struct sched_class *class = &fair_sched_class;
3476     struct task_struct *p;
3477
3478     /*
3479      * Optimization: we know that if all tasks are in
3480      * the fair class we can call that function directly:
3481      */
3482     if (likely(prev->sched_class == class &&
3483            rq->nr_running == rq->cfs.h_nr_running)) {
3484         p = fair_sched_class.pick_next_task(rq, prev);
3485         if (unlikely(p == RETRY_TASK))
3486             goto again;
3487
3488         /* assumes fair_sched_class->next == idle_sched_class */
3489         if (unlikely(!p))
3490             p = idle_sched_class.pick_next_task(rq, prev);
3491
3492         return p;
3493     }
3494
3495 again:
3496     for_each_class(class) {
3497         p = class->pick_next_task(rq, prev);
3498         if (p) {
3499             if (unlikely(p == RETRY_TASK))
3500                 goto again;
3501             return p;
3502         }
3503     }
3504
3505     BUG(); /* the idle class will always have a runnable task */
3506 }
```

- pick_next_task の実態は、 fair.c の pick_next_task_fair()
- 実行可能プロセスが存在しない場合、scheduler()関数は idle_balance()関数を呼び出して、他 CPU の実行キューの実行可能プロセスをローカル CPU の実行キューに移動する

```
4864 static struct task_struct *
4865 pick_next_task_fair(struct rq *rq, struct task_struct *prev)
4866 {
...
4874     if (!cfs_rq->nr_running)
4875         goto idle;
...
4913         se = pick_next_entity(cfs_rq, curr);
4914         cfs_rq = group_cfs_rq(se);
4915     } while (cfs_rq);
4916
4917     p = task_of(se);
...
4971 idle:
4972     new_tasks = idle_balance(rq);
4973     /*
4974      * Because idle_balance() releases (and re-acquires) rq->lock, it is
4975      * possible for any higher priority task to appear. In that case we
4976      * must re-start the pick_next_entity() loop.
4977      */
4978     if (new_tasks < 0)
4979         return RETRY_TASK;
4980
4981     if (new_tasks > 0)
4982         goto again;
4983
4984     return NULL;
4985 }

3045 /*
3046  * Pick the next process, keeping these things in mind, in this order:
3047  * 1) keep things fair between processes/task groups
3048  * 2) pick the "next" process, since someone really wants that to run
3049  * 3) pick the "last" process, for cache locality
3050  * 4) do not run the "skip" process, if something else is available
3051  */
3052 static struct sched_entity *
3053 pick_next_entity(struct cfs_rq *cfs_rq, struct sched_entity *curr)
3054 {
```

## try_to_wake_up()

- 休止または中断しているプロセスを起床する

```

```

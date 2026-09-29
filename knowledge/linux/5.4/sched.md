# sched

## schedule()

- schedule() の目的は、現在実行中のプロセスをほかのプロセスに置き換えること
- ローカル変数の next に、次に実行すべきプロセスのディスクリプタへのポインタを設定する

```c:kernel/sched/core.c
3658 asmlinkage void __sched schedule(void)
3659 {
3660     struct task_struct *tsk = current;
3661
3662     sched_submit_work(tsk);
3663     __schedule();
3664 }
3665 EXPORT_SYMBOL(schedule);

3959 /*
3960  * __schedule() is the main scheduler function.
3961  *
3962  * The main means of driving the scheduler and thus entering this function are:
3963  *
3964  *   1. Explicit blocking: mutex, semaphore, waitqueue, etc.
3965  *
3966  *   2. TIF_NEED_RESCHED flag is checked on interrupt and userspace return
3967  *      paths. For example, see arch/x86/entry_64.S.
3968  *
3969  *      To drive preemption between tasks, the scheduler sets the flag in timer
3970  *      interrupt handler scheduler_tick().
3971  *
3972  *   3. Wakeups don't really cause entry into schedule(). They add a
3973  *      task to the run-queue and that's it.
3974  *
3975  *      Now, if the new task added to the run-queue preempts the current
3976  *      task, then the wakeup sets TIF_NEED_RESCHED and schedule() gets
3977  *      called on the nearest possible occasion:
3978  *
3979  *       - If the kernel is preemptible (CONFIG_PREEMPTION=y):
3980  *
3981  *         - in syscall or exception context, at the next outmost
3982  *           preempt_enable(). (this might be as soon as the wake_up()'s
3983  *           spin_unlock()!)
3984  *
3985  *         - in IRQ context, return from interrupt-handler to
3986  *           preemptible context
3987  *
3988  *       - If the kernel is not preemptible (CONFIG_PREEMPTION is not set)
3989  *         then at the next:
3990  *
3991  *          - cond_resched() call
3992  *          - explicit schedule() call
3993  *          - return from syscall or exception to user-space
3994  *          - return from interrupt-handler to user-space
3995  *
3996  * WARNING: must be called with preemption disabled!
3997  */
3998 static void __sched notrace __schedule(bool preempt)
...
4048     next = pick_next_task(rq, prev, &rf);
...
4084     balance_callback(rq);
4085 }
```

- pick_next_task で、次のプロセスを取得する
- カレントプロセスよりも優先度の高いプロセスがなければ、next はカレントプロセスを指し、プロセス切り替えは起こらない

```
3901 /*
3902  * Pick up the highest-prio task:
3903  */
3904 static inline struct task_struct *
3905 pick_next_task(struct rq *rq, struct task_struct *prev, struct rq_flags *rf)
3906 {
3907     const struct sched_class *class;
3908     struct task_struct *p;
3909
3910     /*
3911      * Optimization: we know that if all tasks are in the fair class we can
3912      * call that function directly, but only if the @prev task wasn't of a
3913      * higher scheduling class, because otherwise those loose the
3914      * opportunity to pull in more work from other CPUs.
3915      */
3916     if (likely((prev->sched_class == &idle_sched_class ||
3917             prev->sched_class == &fair_sched_class) &&
3918            rq->nr_running == rq->cfs.h_nr_running)) {
3919
3920         p = fair_sched_class.pick_next_task(rq, prev, rf);
3921         if (unlikely(p == RETRY_TASK))
3922             goto restart;
3923
3924         /* Assumes fair_sched_class->next == idle_sched_class */
3925         if (unlikely(!p))
3926             p = idle_sched_class.pick_next_task(rq, prev, rf);
3927
3928         return p;
3929     }
3930
3931 restart:
3932 #ifdef CONFIG_SMP
3933     /*
3934      * We must do the balancing pass before put_next_task(), such
3935      * that when we release the rq->lock the task is in the same
3936      * state as before we took rq->lock.
3937      *
3938      * We can terminate the balance pass as soon as we know there is
3939      * a runnable task of @class priority or higher.
3940      */
3941     for_class_range(class, prev->sched_class, &idle_sched_class) {
3942         if (class->balance(rq, prev, rf))
3943             break;
3944     }
3945 #endif
3946
3947     put_prev_task(rq, prev);
3948
3949     for_each_class(class) {
3950         p = class->pick_next_task(rq, NULL, NULL);
3951         if (p)
3952             return p;
3953     }
3954
3955     /* The idle class should always have a runnable task: */
3956     BUG();
3957 }
```

- pick_next_task の実態は、 fair.c の pick_next_task_fair()

```
6749 static struct task_struct *
6750 pick_next_task_fair(struct rq *rq, struct task_struct *prev, struct rq_flags *rf)
6751 {

6890     return NULL;
6891 }


4188 /*
4189  * Pick the next process, keeping these things in mind, in this order:
4190  * 1) keep things fair between processes/task groups
4191  * 2) pick the "next" process, since someone really wants that to run
4192  * 3) pick the "last" process, for cache locality
4193  * 4) do not run the "skip" process, if something else is available
4194  */
4195 static struct sched_entity *
4196 pick_next_entity(struct cfs_rq *cfs_rq, struct sched_entity *curr)
4197 {
4198     struct sched_entity *left = __pick_first_entity(cfs_rq);
4199     struct sched_entity *se;
4200
4201     /*
4202      * If curr is set we have to see if its left of the leftmost entity
4203      * still in the tree, provided there was anything in the tree at all.
4204      */
4205     if (!left || (curr && entity_before(curr, left)))
4206         left = curr;
4207
4208     se = left; /* ideally we run the leftmost entity */
4209
4210     /*
4211      * Avoid running the skip buddy, if running something else can
4212      * be done without getting too unfair.
4213      */
4214     if (cfs_rq->skip == se) {
4215         struct sched_entity *second;
4216
4217         if (se == curr) {
4218             second = __pick_first_entity(cfs_rq);
4219         } else {
4220             second = __pick_next_entity(se);
4221             if (!second || (curr && entity_before(curr, second)))
4222                 second = curr;
4223         }
4224
4225         if (second && wakeup_preempt_entity(second, left) < 1)
4226             se = second;
4227     }
4228
4229     /*
4230      * Prefer last buddy, try to return the CPU to a preempted task.
4231      */
4232     if (cfs_rq->last && wakeup_preempt_entity(cfs_rq->last, left) < 1)
4233         se = cfs_rq->last;
4234
4235     /*
4236      * Someone really wants this to run. If it's not unfair, run it.
4237      */
4238     if (cfs_rq->next && wakeup_preempt_entity(cfs_rq->next, left) < 1)
4239         se = cfs_rq->next;
4240
4241     clear_buddies(cfs_rq, se);
4242
4243     return se;
4244 }
```

# try_to_wake_up

- blocked, sleeping のタスクを再度走らせるときに呼ばれる

```
1744 static int
1745 try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
1746 {
```

# worker_thread_barrier

- main thread は、worker thread との競合を避けるため、メモリ書き込み時に worker thread を lock することがある

## lock される側(worker thread)

```c:vlib/main.c
  1679 static_always_inline void
  1680 vlib_main_or_worker_loop (vlib_main_t * vm, int is_main)
  1681 {
  ...
  1739   while (1)
  1740     {
  ...
  1749       if (!is_main)
  1750         {
  1751           vlib_worker_thread_barrier_check ();
```

- vlib_worker_threads->wait_at_barrier が立ってたら、vlib_worker_threads->workers_at_barrier をインクリメントして、vlib_worker_threads->wait_at_barrier が 0 になるのを待つ

```c:vlib/thread.h
  394 static inline void
  395 vlib_worker_thread_barrier_check (void)
  396 {
  397   if (PREDICT_FALSE (*vlib_worker_threads->wait_at_barrier))
  398     {
  399       vlib_main_t *vm = vlib_get_main ();
  400       u32 thread_index = vm->thread_index;
  401       f64 t = vlib_time_now (vm);
...
  428       clib_atomic_fetch_add (vlib_worker_threads->workers_at_barrier, 1);
  429       while (*vlib_worker_threads->wait_at_barrier)
  430         ;
...
  448       clib_atomic_fetch_add (vlib_worker_threads->workers_at_barrier, -1);
...
  501     }
  502 }
```

## lock する側(main thread)

- sync で、全 worker thread をロックして、release で解放する

```c:vlib/thread.h
  204 #define vlib_worker_thread_barrier_sync(X) {vlib_worker_thread_barrier_sync_int(X, __FUNCTION__);}
  205
  206 void vlib_worker_thread_barrier_sync_int (vlib_main_t * vm,
  207                                           const char *func_name);
  208 void vlib_worker_thread_barrier_release (vlib_main_t * vm);
```

- vlib_worker_threads->wait_at_barrier を立てる
  - worker_threads は vlib_worker_thread_barrier_check で lock される
- 全 worker_threads が、lock されるまで待って終了する

```c:vlib/thread.c
  1393 void
  1394 vlib_worker_thread_barrier_sync_int (vlib_main_t * vm, const char *func_name)
  1395 {
  ...
  1465   deadline = now + BARRIER_SYNC_TIMEOUT;
  1466
  1467   *vlib_worker_threads->wait_at_barrier = 1;
  1468   while (*vlib_worker_threads->workers_at_barrier != count)
  1469     {
  1470       if ((now = vlib_time_now (vm)) > deadline)
  1471         {
  1472           fformat (stderr, "%s: worker thread deadlock\n", __FUNCTION__);
  1473           os_panic ();
  1474         }
  1475     }
  1476
  1477   t_closed = now - vm->barrier_epoch;
  1478
  1479   barrier_trace_sync (t_entry, t_open, t_closed);
  1480
  1481 }
```

- vlib_worker_threads->wait_at_barrier を折る
  - worker threads が vlib_worker_thread_barrier_check の無限ループから抜ける

```c:vlib/thread.c
  1483 void
  1484 vlib_worker_thread_barrier_release (vlib_main_t * vm)
  1485 {
  ...
  1541   *vlib_worker_threads->wait_at_barrier = 0;
  1542
  1543   while (*vlib_worker_threads->workers_at_barrier > 0)
  1544     {
  1545       if ((now = vlib_time_now (vm)) > deadline)
  1546         {
  1547           fformat (stderr, "%s: worker thread deadlock\n", __FUNCTION__);
  1548           os_panic ();
  1549         }
  1550     }
  ...
  1587 }
```

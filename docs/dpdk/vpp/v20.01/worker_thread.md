# worker thread

```c:vlib/thread.c
 627 static clib_error_t *
 628 start_workers (vlib_main_t * vm)
 629 {
 630   int i, j;
 631   vlib_worker_thread_t *w;
 632   vlib_main_t *vm_clone;
 633   void *oldheap;
 634   vlib_thread_main_t *tm = &vlib_thread_main;
 635   vlib_thread_registration_t *tr;
 636   vlib_node_runtime_t *rt;
 637   u32 n_vlib_mains = tm->n_vlib_mains;
 638   u32 worker_thread_index;
 639   u8 *main_heap = clib_mem_get_per_cpu_heap ();
 640
 641   vec_reset_length (vlib_worker_threads);
 642
 643   /* Set up the main thread */
 644   vec_add2_aligned (vlib_worker_threads, w, 1, CLIB_CACHE_LINE_BYTES);
 ...
 908   for (i = 0; i < vec_len (tm->registrations); i++)
 909     {
 910       clib_error_t *err;
 911       int j;
 912
 913       tr = tm->registrations[i];
 914
 915       if (tr->use_pthreads || tm->use_pthreads)
 916         {
 917           for (j = 0; j < tr->count; j++)
 918             {
 919               w = vlib_worker_threads + worker_thread_index++;
 920               err = vlib_launch_thread_int (vlib_worker_thread_bootstrap_fn,
 921                                             w, 0);
 922               if (err)
 923                 clib_error_report (err);
 924             }
 925         }
 ...
 940   vlib_worker_thread_barrier_sync (vm);
 941   vlib_worker_thread_barrier_release (vm);
 942   return 0;
 943 }

 945 VLIB_MAIN_LOOP_ENTER_FUNCTION (start_workers);
```

```c:vlib/thread.c
 600 clib_error_t *
 601 vlib_launch_thread_int (void *fp, vlib_worker_thread_t * w, unsigned cpu_id)
 602 {
 603   vlib_thread_main_t *tm = &vlib_thread_main;
 604   void *(*fp_arg) (void *) = fp;
 605
 606   w->cpu_id = cpu_id;
 607   vlib_get_thread_core_socket (w, cpu_id);
 608   if (tm->cb.vlib_launch_thread_cb && !w->registration->use_pthreads)
 609     return tm->cb.vlib_launch_thread_cb (fp, (void *) w, cpu_id);
 610   else
 611     {
 612       pthread_t worker;
 613       cpu_set_t cpuset;
 614       CPU_ZERO (&cpuset);
 615       CPU_SET (cpu_id, &cpuset);
 616
 617       if (pthread_create (&worker, NULL /* attr */ , fp_arg, (void *) w))
 618         return clib_error_return_unix (0, "pthread_create");
 619
 620       if (pthread_setaffinity_np (worker, sizeof (cpu_set_t), &cpuset))
 621         return clib_error_return_unix (0, "pthread_setaffinity_np");
 622
 623       return 0;
 624     }
 625 }
```

- ここから pthread

```c:vlib/thread.c
 562 void *
 563 vlib_worker_thread_bootstrap_fn (void *arg)
 564 {
 565   void *rv;
 566   vlib_worker_thread_t *w = arg;
 567
 568   w->lwp = syscall (SYS_gettid);
 569   w->thread_id = pthread_self ();
 570
 571   __os_thread_index = w - vlib_worker_threads;
 572
 573   rv = (void *) clib_calljmp
 574     ((uword (*)(uword)) w->thread_function,
 575      (uword) arg, w->thread_stack + VLIB_THREAD_STACK_SIZE);
 576   /* NOTREACHED, we hope */
 577   return rv;
 578 }
```

```c:vlib/thread.c
1728 void
1729 vlib_worker_thread_fn (void *arg)
1730 {
1731   vlib_worker_thread_t *w = (vlib_worker_thread_t *) arg;
1732   vlib_thread_main_t *tm = vlib_get_thread_main ();
1733   vlib_main_t *vm = vlib_get_main ();
1734   clib_error_t *e;
1735
1736   ASSERT (vm->thread_index == vlib_get_thread_index ());
1737
1738   vlib_worker_thread_init (w);
1739   clib_time_init (&vm->clib_time);
1740   clib_mem_set_heap (w->thread_mheap);
1741
1742   e = vlib_call_init_exit_functions_no_sort
1743     (vm, &vm->worker_init_function_registrations, 1 /* call_once */ );
1744   if (e)
1745     clib_error_report (e);
1746
1747   /* Wait until the dpdk init sequence is complete */
1748   while (tm->extern_thread_mgmt && tm->worker_thread_release == 0)
1749     vlib_worker_thread_barrier_check ();
1750
1751   vlib_worker_loop (vm);
1752 }
1753
1754 /* *INDENT-OFF* */
1755 VLIB_REGISTER_THREAD (worker_thread_reg, static) = {
1756   .name = "workers",
1757   .short_name = "wk",
1758   .function = vlib_worker_thread_fn,
1759 };
1760 /* *INDENT-ON* */
```

```c:vlib/main.c
1937 void
1938 vlib_worker_loop (vlib_main_t * vm)
1939 {
1940   vlib_main_or_worker_loop (vm, /* is_main */ 0);
1941 }
```

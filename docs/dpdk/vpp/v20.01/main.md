# main

## main

```c:vnet/vpp/main.c

99 int
100 main (int argc, char *argv[])
101 {
102   int i;
103   vlib_main_t *vm = &vlib_global_main;
104   void vl_msg_api_set_first_available_msg_id (u16);
105   uword main_heap_size = (1ULL << 30);
106   u8 *sizep;
107   u32 size;
108   int main_core = 1;
109   cpu_set_t cpuset;

266
267   /* set process affinity for main thread */
268   CPU_ZERO (&cpuset);
269   CPU_SET (main_core, &cpuset);
270   pthread_setaffinity_np (pthread_self (), sizeof (cpu_set_t), &cpuset);
271
272   /* Set up the plugin message ID allocator right now... */
273   vl_msg_api_set_first_available_msg_id (VL_MSG_FIRST_AVAILABLE);
274
275   /* Allocate main heap */
276   if (clib_mem_init_thread_safe (0, main_heap_size))
277     {
278       vm->init_functions_called = hash_create (0, /* value bytes */ 0);
279       vpe_main_init (vm);
280       return vlib_unix_main (argc, argv);
281     }
282   else
283     {
284       {
285         int rv __attribute__ ((unused)) =
286           write (2, "Main heap allocation failure!\r\n", 31);
287       }
288       return 1;
289     }
290 }
```

## vlib_unix_main

```c:vlib/unix/main.c
673 int
674 vlib_unix_main (int argc, char *argv[])
675 {
676   vlib_main_t *vm = &vlib_global_main;        /* one and only time for this! */
677   unformat_input_t input;
678   clib_error_t *e;
679   int i;
680
681   vm->argv = (u8 **) argv;
682   vm->name = argv[0];
683   vm->heap_base = clib_mem_get_heap ();
684   vm->heap_aligned_base = (void *)
685     (((uword) vm->heap_base) & ~(VLIB_FRAME_ALIGN - 1));
686   ASSERT (vm->heap_base);
687
688   unformat_init_command_line (&input, (char **) vm->argv);
689   if ((e = vlib_plugin_config (vm, &input)))
690     {
691       clib_error_report (e);
692       return 1;
693     }
694   unformat_free (&input);
695
696   i = vlib_plugin_early_init (vm);
697   if (i)
698     return i;
699
700   unformat_init_command_line (&input, (char **) vm->argv);
701   if (vm->init_functions_called == 0)
702     vm->init_functions_called = hash_create (0, /* value bytes */ 0);
703   e = vlib_call_all_config_functions (vm, &input, 1 /* early */ );
704   if (e != 0)
705     {
706       clib_error_report (e);
707       return 1;
708     }
709   unformat_free (&input);
710
711   /* always load symbols, for signal handler and mheap memory get/put backtrace */
712   clib_elf_main_init (vm->name);
713
714   vec_validate (vlib_thread_stacks, 0);
715   vlib_thread_stack_init (0);
716
717   __os_thread_index = 0;
718   vm->thread_index = 0;
719
720   i = clib_calljmp (thread0, (uword) vm,
721                     (void *) (vlib_thread_stacks[0] +
722                               VLIB_THREAD_STACK_SIZE));
723   return i;
724 }
```

```c:vlib/unix/main.c
static uword
thread0 (uword arg)
{
  vlib_main_t *vm = (vlib_main_t *) arg;
  unformat_input_t input;
  int i;

  unformat_init_command_line (&input, (char **) vm->argv);
  i = vlib_main (vm, &input);
  unformat_free (&input);

  return i;
}
```

## vlib_main_t

- vlib_unit_main で一回のみ global から参照され、以降 vm として引数渡しで伝搬され利用される

```c:vlib/main.c
1943 vlib_main_t vlib_global_main;
```

```c:vlib/main.h
 83 typedef struct vlib_main_t
 84 {

 271 } vlib_main_t;
 272
 273 /* Global main structure. */
 274 extern vlib_main_t vlib_global_main;
```

## vlib_main

```c:vlib/main.c
2015 /* Main function. */
2016 int
2017 vlib_main (vlib_main_t * volatile vm, unformat_input_t * input)
2018 {
2019   clib_error_t *volatile error;
2020   vlib_node_main_t *nm = &vm->node_main;
2021
2022   vm->queue_signal_callback = dummy_queue_signal_callback;
2023
2024   clib_time_init (&vm->clib_time);
...
2062   /* Register static nodes so that init functions may use them. */
2063   vlib_register_all_static_nodes (vm);
...
2071   /* Initialize node graph. */
2072   if ((error = vlib_node_main_init (vm)))
2073     {
2074       /* Arrange for graph hook up error to not be fatal when debugging. */
2075       if (CLIB_DEBUG > 0)
2076         clib_error_report (error);
2077       else
2078         goto done;
2079     }
2080
2081   /* Direct call / weak reference, for vlib standalone use-cases */
2082   if ((error = vpe_api_init (vm)))
2083     {
2084       clib_error_report (error);
2085       goto done;
2086     }
2087
2088   if ((error = vlibmemory_init (vm)))
2089     {
2090       clib_error_report (error);
2091       goto done;
2092     }
2093
2094   if ((error = map_api_segment_init (vm)))
2095     {
2096       clib_error_report (error);
2097       goto done;
2098     }
...

```

```c:vlib/main.c
  1960 static void
  1961 vlib_main_loop (vlib_main_t * vm)
  1962 {
  1963   vlib_main_or_worker_loop (vm, /* is_main */ 1);
  1964 }
  1965
  1966 void
  1967 vlib_worker_loop (vlib_main_t * vm)
  1968 {
  1969   vlib_main_or_worker_loop (vm, /* is_main */ 0);
  1970 }
```

## vlib_main loop

```c:vlib/main.c
  1679 static_always_inline void
  1680 vlib_main_or_worker_loop (vlib_main_t * vm, int is_main)
  1681 {
  1682   vlib_node_main_t *nm = &vm->node_main;
  1683   vlib_thread_main_t *tm = vlib_get_thread_main ();
  1684   uword i;
  1685   u64 cpu_time_now;
  1686   f64 now;
  1687   vlib_frame_queue_main_t *fqm;
  1688   u32 *last_node_runtime_indices = 0;
  1689   u32 frame_queue_check_counter = 0;
  ...
  1721   /* Start all processes. */
  1722   if (is_main)
  1723     {
  1724       uword i;
  1725
  1726       /*
  1727        * Perform an initial barrier sync. Pays no attention to
  1728        * the barrier sync hold-down timer scheme, which won't work
  1729        * at this point in time.
  1730        */
  1731       vlib_worker_thread_initial_barrier_sync_and_release (vm);
  1732
  1733       nm->current_process_index = ~0;
  1734       for (i = 0; i < vec_len (nm->processes); i++)
  1735         cpu_time_now = dispatch_process (vm, nm->processes[i], /* frame */ 0,
  1736                                          cpu_time_now);
  1737     }
  1738
  1739   while (1)
  1740     {
  1741       vlib_node_runtime_t *n;
  1742
  1743       if (PREDICT_FALSE (_vec_len (vm->pending_rpc_requests) > 0))
  1744         {
  1745           if (!is_main)
  1746             vl_api_send_pending_rpc_requests (vm);
  1747         }
  1748
  1749       if (!is_main)
  1750         {
  1751           vlib_worker_thread_barrier_check ();
  1752           if (PREDICT_FALSE (vm->check_frame_queues +
  1753                              frame_queue_check_counter))
  1754             {
  1755               u32 processed = 0;
  1756
  1757               if (vm->check_frame_queues)
  1758                 {
  1759                   frame_queue_check_counter = 100;
  1760                   vm->check_frame_queues = 0;
  1761                 }
  1762
  1763               vec_foreach (fqm, tm->frame_queue_mains)
  1764                 processed += vlib_frame_queue_dequeue (vm, fqm);
  ...
  1774         }
  1775
  1776       /* Process pre-input nodes. */
  1777       vec_foreach (n, nm->nodes_by_type[VLIB_NODE_TYPE_PRE_INPUT])
  1778         cpu_time_now = dispatch_node (vm, n,
  1779                                       VLIB_NODE_TYPE_PRE_INPUT,
  1780                                       VLIB_NODE_STATE_POLLING,
  1781                                       /* frame */ 0,
  1782                                       cpu_time_now);
  1783
  1784       /* Next process input nodes. */
  1785       vec_foreach (n, nm->nodes_by_type[VLIB_NODE_TYPE_INPUT])
  1786         cpu_time_now = dispatch_node (vm, n,
  1787                                       VLIB_NODE_TYPE_INPUT,
  1788                                       VLIB_NODE_STATE_POLLING,
  1789                                       /* frame */ 0,
  1790                                       cpu_time_now);
  1791
  1792       if (PREDICT_TRUE (is_main && vm->queue_signal_pending == 0))
  1793         vm->queue_signal_callback (vm);
  1794
  ...
  1829       /* Input nodes may have added work to the pending vector.
  1830          Process pending vector until there is nothing left.
  1831          All pending vectors will be processed from input -> output. */
  1832       for (i = 0; i < _vec_len (nm->pending_frames); i++)
  1833         cpu_time_now = dispatch_pending_node (vm, i, cpu_time_now);
  1834       /* Reset pending vector for next iteration. */
  1835       _vec_len (nm->pending_frames) = 0;
  1836
  1837       if (is_main)
  1838         {
  ...
  1923         }
  1924       vlib_increment_main_loop_counter (vm);
  1925       /* Record time stamp in case there are no enabled nodes and above
  1926          calls do not update time stamp. */
  1927       cpu_time_now = clib_cpu_time_now ();
  1928     }
  1929 }
```

```c:vlib/main.c
  1131 static_always_inline u64
  1132 dispatch_node (vlib_main_t * vm,
  1133                vlib_node_runtime_t * node,
  1134                vlib_node_type_t type,
  1135                vlib_node_state_t dispatch_state,
  1136                vlib_frame_t * frame, u64 last_time_stamp)
  1137 {
  1138   uword n, v;
  1139   u64 t;
  1140   vlib_node_main_t *nm = &vm->node_main;
  1141   vlib_next_frame_t *nf;
  1142   u64 pmc_before[2], pmc_after[2], pmc_delta[2];

  1204   else
  1205     {
  1206       if (PREDICT_FALSE (vm->dispatch_pcap_enable))
  1207         dispatch_pcap_trace (vm, node, frame);
  1208       n = node->function (vm, node, frame);
  1209     }
  1210
  1211   t = clib_cpu_time_now ();

  1321   return t;
  1322 }
```

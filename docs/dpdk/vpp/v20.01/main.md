# main

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

## main ループ

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

  1741   while (1)
  1742     {
  1743       vlib_node_runtime_t *n;

  1751       if (!is_main)
  1752         {
  1753           vlib_worker_thread_barrier_check ();
  ...
  1776         }
  1777
  1778       /* Process pre-input nodes. */
  1779       vec_foreach (n, nm->nodes_by_type[VLIB_NODE_TYPE_PRE_INPUT])
  1780         cpu_time_now = dispatch_node (vm, n,
  1781                                       VLIB_NODE_TYPE_PRE_INPUT,
  1782                                       VLIB_NODE_STATE_POLLING,
  1783                                       /* frame */ 0,
  1784                                       cpu_time_now);
  1785
  1786       /* Next process input nodes. */
  1787       vec_foreach (n, nm->nodes_by_type[VLIB_NODE_TYPE_INPUT])
  1788         cpu_time_now = dispatch_node (vm, n,
  1789                                       VLIB_NODE_TYPE_INPUT,
  1790                                       VLIB_NODE_STATE_POLLING,
  1791                                       /* frame */ 0,
  1792                                       cpu_time_now);
  1793
  1794       if (PREDICT_TRUE (is_main && vm->queue_signal_pending == 0))
  1795         vm->queue_signal_callback (vm);
  1796

  1831       /* Input nodes may have added work to the pending vector.
  1832          Process pending vector until there is nothing left.
  1833          All pending vectors will be processed from input -> output. */
  1834       for (i = 0; i < _vec_len (nm->pending_frames); i++)
  1835         cpu_time_now = dispatch_pending_node (vm, i, cpu_time_now);
  1836       /* Reset pending vector for next iteration. */
  1837       _vec_len (nm->pending_frames) = 0;

  1957     } // end while
  1958 }
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

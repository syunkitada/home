# ip4-lookup node

```c:vnet/ip/ip_forward.c
  61 /** @brief IPv4 lookup node.
  62     @node ip4-lookup
  63
  64     This is the main IPv4 lookup dispatch node.
  65
  66     @param vm vlib_main_t corresponding to the current thread
  67     @param node vlib_node_runtime_t
  68     @param frame vlib_frame_t whose contents should be dispatched
  69
  70     @par Graph mechanics: buffer metadata, next index usage
  71
  72     @em Uses:
  73     - <code>vnet_buffer(b)->sw_if_index[VLIB_RX]</code>
  74         - Indicates the @c sw_if_index value of the interface that the
  75           packet was received on.
  76     - <code>vnet_buffer(b)->sw_if_index[VLIB_TX]</code>
  77         - When the value is @c ~0 then the node performs a longest prefix
  78           match (LPM) for the packet destination address in the FIB attached
  79           to the receive interface.
  80         - Otherwise perform LPM for the packet destination address in the
  81           indicated FIB. In this case <code>[VLIB_TX]</code> is a FIB index
  82           value (0, 1, ...) and not a VRF id.
  83
  84     @em Sets:
  85     - <code>vnet_buffer(b)->ip.adj_index[VLIB_TX]</code>
  86         - The lookup result adjacency index.
  87
  88     <em>Next Index:</em>
  89     - Dispatches the packet to the node index found in
  90       ip_adjacency_t @c adj->lookup_next_index
  91       (where @c adj is the lookup result adjacency).
  92 */
  93 VLIB_NODE_FN (ip4_lookup_node) (vlib_main_t * vm, vlib_node_runtime_t * node,
  94                                 vlib_frame_t * frame)
  95 {
  96   return ip4_lookup_inline (vm, node, frame);
  97 }

 102 VLIB_REGISTER_NODE (ip4_lookup_node) =
 103 {
 104   .name = "ip4-lookup",
 105   .vector_size = sizeof (u32),
 106   .format_trace = format_ip4_lookup_trace,
 107   .n_next_nodes = IP_LOOKUP_N_NEXT,
 108   .next_nodes = IP4_LOOKUP_NEXT_NODES,
 109 };
```

```c:vnet/ip/ip_forward.h
 47 /**
 48  * @file
 49  * @brief IPv4 Forwarding.
 50  *
 51  * This file contains the source code for IPv4 forwarding.
 52  */
 53
 54 always_inline uword
 55 ip4_lookup_inline (vlib_main_t * vm,
 56                    vlib_node_runtime_t * node, vlib_frame_t * frame)
 57 {

346   while (n_left > 0)
347     {

358       ip0 = vlib_buffer_get_current (b[0]);
359       dst_addr0 = &ip0->dst_address;
360       ip_lookup_set_buffer_fib_index (im->fib_index_by_sw_if_index, b[0]);
361
362       mtrie0 = &ip4_fib_get (vnet_buffer (b[0])->ip.fib_index)->mtrie;
363       leaf0 = ip4_fib_mtrie_lookup_step_one (mtrie0, dst_addr0);
364       leaf0 = ip4_fib_mtrie_lookup_step (mtrie0, leaf0, dst_addr0, 2);
365       leaf0 = ip4_fib_mtrie_lookup_step (mtrie0, leaf0, dst_addr0, 3);
366       lbi0 = ip4_fib_mtrie_leaf_get_adj_index (leaf0);

369       lb0 = load_balance_get (lbi0);

374       /* Use flow hash to compute multipath adjacency. */
375       hash_c0 = vnet_buffer (b[0])->ip.flow_hash = 0;
376       if (PREDICT_FALSE (lb0->lb_n_buckets > 1))
377         {
378           flow_hash_config0 = lb0->lb_hash_config;
379
380           hash_c0 = vnet_buffer (b[0])->ip.flow_hash =
381             ip4_compute_flow_hash (ip0, flow_hash_config0);
382           dpo0 =
383             load_balance_get_fwd_bucket (lb0,
384                                          (hash_c0 &
385                                           (lb0->lb_n_buckets_minus_1)));
386         }
387       else
388         {
389           dpo0 = load_balance_get_bucket_i (lb0, 0);
390         }
391
392       next[0] = dpo0->dpoi_next_node;
393       vnet_buffer (b[0])->ip.adj_index[VLIB_TX] = dpo0->dpoi_index;
394
395       vlib_increment_combined_counter (cm, thread_index, lbi0, 1,
396                                        vlib_buffer_length_in_chain (vm,
397                                                                     b[0]));
398
399       b += 1;
400       next += 1;
401       n_left -= 1;
402     }
403
404   vlib_buffer_enqueue_to_next (vm, node, from, nexts, frame->n_vectors);
405
406   if (node->flags & VLIB_NODE_FLAG_TRACE)
407     ip4_forward_next_trace (vm, node, frame, VLIB_TX);
408
409   return frame->n_vectors;
410 }
```

# ip4-load-balance node

```c:vnet/ip/ip_forward.c
 112 VLIB_NODE_FN (ip4_load_balance_node) (vlib_main_t * vm,
 113                                       vlib_node_runtime_t * node,
 114                                       vlib_frame_t * frame)
 115 {
 116   vlib_combined_counter_main_t *cm = &load_balance_main.lbm_via_counters;
 117   u32 n_left, *from;
 118   u32 thread_index = vm->thread_index;
 119   vlib_buffer_t *bufs[VLIB_FRAME_SIZE], **b = bufs;
 120   u16 nexts[VLIB_FRAME_SIZE], *next;
 121
 122   from = vlib_frame_vector_args (frame);
 123   n_left = frame->n_vectors;
 124   next = nexts;
 125
 126   vlib_get_buffers (vm, from, bufs, n_left);
 127
 128   while (n_left >= 4)
 129     {
 ...
 213     }
 214
 215   while (n_left > 0)
 216     {
 217       const load_balance_t *lb0;
 218       const ip4_header_t *ip0;
 219       const dpo_id_t *dpo0;
 220       u32 lbi0, hc0;
 221
 222       ip0 = vlib_buffer_get_current (b[0]);
 223       lbi0 = vnet_buffer (b[0])->ip.adj_index[VLIB_TX];
 224
 225       lb0 = load_balance_get (lbi0);
 226
 227       hc0 = 0;
 228       if (PREDICT_FALSE (lb0->lb_n_buckets > 1))
 229         {
 230           if (PREDICT_TRUE (vnet_buffer (b[0])->ip.flow_hash))
 231             {
 232               hc0 = vnet_buffer (b[0])->ip.flow_hash =
 233                 vnet_buffer (b[0])->ip.flow_hash >> 1;
 234             }
 235           else
 236             {
 237               hc0 = vnet_buffer (b[0])->ip.flow_hash =
 238                 ip4_compute_flow_hash (ip0, lb0->lb_hash_config);
 239             }
 240           dpo0 = load_balance_get_fwd_bucket
 241             (lb0, (hc0 & (lb0->lb_n_buckets_minus_1)));
 242         }
 243       else
 244         {
 245           dpo0 = load_balance_get_bucket_i (lb0, 0);
 246         }
 247
 248       next[0] = dpo0->dpoi_next_node;
 249       vnet_buffer (b[0])->ip.adj_index[VLIB_TX] = dpo0->dpoi_index;
 250
 251       vlib_increment_combined_counter
 252         (cm, thread_index, lbi0, 1, vlib_buffer_length_in_chain (vm, b[0]));
 253
 254       b += 1;
 255       next += 1;
 256       n_left -= 1;
 257     }
 258
 259   vlib_buffer_enqueue_to_next (vm, node, from, nexts, frame->n_vectors);
 260   if (node->flags & VLIB_NODE_FLAG_TRACE)
 261     ip4_forward_next_trace (vm, node, frame, VLIB_TX);
 262
 263   return frame->n_vectors;
 264 }
 265
 266 /* *INDENT-OFF* */
 267 VLIB_REGISTER_NODE (ip4_load_balance_node) =
 268 {
 269   .name = "ip4-load-balance",
 270   .vector_size = sizeof (u32),
 271   .sibling_of = "ip4-lookup",
 272   .format_trace = format_ip4_lookup_trace,
 273 };
```

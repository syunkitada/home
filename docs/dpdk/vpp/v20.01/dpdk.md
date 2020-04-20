# dpdk

- この runtime が担当する device queue すべてで、dpdk_device_input を実行する
- dpdk_device_input は、dpdk によって指定された device queue からパケットを受信し、受信したパケット数を返す

```c:plugins/dpdk/device/node.c
  452 VLIB_NODE_FN (dpdk_input_node) (vlib_main_t * vm, vlib_node_runtime_t * node,
  453                                 vlib_frame_t * f)
  454 {
  455   dpdk_main_t *dm = &dpdk_main;
  456   dpdk_device_t *xd;
  457   uword n_rx_packets = 0;
  458   vnet_device_input_runtime_t *rt = (void *) node->runtime_data;
  459   vnet_device_and_queue_t *dq;
  460   u32 thread_index = node->thread_index;
  461
  462   /*
  463    * Poll all devices on this cpu for input/interrupts.
  464    */
  465   /* *INDENT-OFF* */
  466   foreach_device_and_queue (dq, rt->devices_and_queues)
  467     {
  468       xd = vec_elt_at_index(dm->devices, dq->dev_instance);
  469       n_rx_packets += dpdk_device_input (vm, dm, xd, node, thread_index,
  470                                          dq->queue_id);
  471     }
  472   /* *INDENT-ON* */
  473   return n_rx_packets;
  474 }
```

```c:plugins/dpdk/device/node.c
  286 dpdk_device_input (vlib_main_t * vm, dpdk_main_t * dm, dpdk_device_t * xd,
  287                    vlib_node_runtime_t * node, u32 thread_index, u16 queue_id)
  288 {
  289   uword n_rx_packets = 0, n_rx_bytes;
  290   u32 n_left, n_trace;
  291   u32 *buffers;
  292   u32 next_index = VNET_DEVICE_INPUT_NEXT_ETHERNET_INPUT;
  293   struct rte_mbuf **mb;
  294   vlib_buffer_t *b0;
  295   u16 *next;
  296   u16 or_flags;
  297   u32 n;
  298   int single_next = 0;
  299
  300   dpdk_per_thread_data_t *ptd = vec_elt_at_index (dm->per_thread_data,
  301                                                   thread_index);
  302   vlib_buffer_t *bt = &ptd->buffer_template;
  303
  304   if ((xd->flags & DPDK_DEVICE_FLAG_ADMIN_UP) == 0)
  305     return 0;
  306
  307   /* get up to DPDK_RX_BURST_SZ buffers from PMD */
  308   while (n_rx_packets < DPDK_RX_BURST_SZ)
  309     {
  # dpdkのrte_eth_rx_burstによりパケットを取得する(n には取得したパケット数が入る)
  # mbufsはパケットバッファのポインタ配列で、ここに受信したパケットのアドレスが格納される
  310       n = rte_eth_rx_burst (xd->port_id, queue_id,
  311                             ptd->mbufs + n_rx_packets,
  312                             DPDK_RX_BURST_SZ - n_rx_packets);
  313       n_rx_packets += n;
  314
  315       if (n < 32)
  316         break;
  317     }
  318
  319   if (n_rx_packets == 0)
  320     return 0;
  321
  322   /* Update buffer template */
  323   vnet_buffer (bt)->sw_if_index[VLIB_RX] = xd->sw_if_index;
  324   bt->error = node->errors[DPDK_ERROR_NONE];
  325   /* as DPDK is allocating empty buffers from mempool provided before interface
  326      start for each queue, it is safe to store this in the template */
  327   bt->buffer_pool_index = xd->buffer_pool_for_queue[queue_id];
  328   bt->ref_count = 1;
  329   vnet_buffer (bt)->feature_arc_index = 0;
  330   bt->current_config_index = 0;

  343   else
  # packetのbytes数を求める（n_rx_bytesはカウンタに使うだけ)
  344     n_rx_bytes = dpdk_process_rx_burst (vm, ptd, n_rx_packets, 0, &or_flags);

  366   else
  367     {
  368       u32 *to_next, n_left_to_next;
  369
  370       vlib_get_new_next_frame (vm, node, next_index, to_next, n_left_to_next);
  371       vlib_get_buffer_indices_with_offset (vm, (void **) ptd->mbufs, to_next,
  372                                            n_rx_packets,
  373                                            sizeof (struct rte_mbuf));
  374
  375       if (PREDICT_TRUE (next_index == VNET_DEVICE_INPUT_NEXT_ETHERNET_INPUT))
  376         {
  377           vlib_next_frame_t *nf;
  378           vlib_frame_t *f;
  379           ethernet_input_frame_t *ef;
  380           nf = vlib_node_runtime_get_next_frame (vm, node, next_index);
  381           f = vlib_get_frame (vm, nf->frame);
  382           f->flags = ETH_INPUT_FRAME_F_SINGLE_SW_IF_IDX;
  383
  384           ef = vlib_frame_scalar_args (f);
  385           ef->sw_if_index = xd->sw_if_index;
  386           ef->hw_if_index = xd->hw_if_index;
  387
  388           /* if PMD supports ip4 checksum check and there are no packets
  389              marked as ip4 checksum bad we can notify ethernet input so it
  390              can send pacets to ip4-input-no-checksum node */
  391           if (xd->flags & DPDK_DEVICE_FLAG_RX_IP4_CKSUM &&
  392               (or_flags & PKT_RX_IP_CKSUM_BAD) == 0)
  393             f->flags |= ETH_INPUT_FRAME_F_IP4_CKSUM_OK;
  394           vlib_frame_no_append (f);
  395         }
  396       n_left_to_next -= n_rx_packets;

	# vm->node_main->pending_framesにnext_frameを追加する
  397       vlib_put_next_frame (vm, node, next_index, n_left_to_next);
  398       single_next = 1;
  399     }

  # 最後にカウンタをインクリメントして終了
  442   vlib_increment_combined_counter
  443     (vnet_get_main ()->interface_main.combined_sw_if_counters
  444      + VNET_INTERFACE_COUNTER_RX, thread_index, xd->sw_if_index,
  445      n_rx_packets, n_rx_bytes);
  446
  447   vnet_device_increment_rx_packets (thread_index, n_rx_packets);
  448
  449   return n_rx_packets;
  450 }
```

# lb plugin

```c:plugins/lb/lb.c
1138 VLIB_REGISTER_NODE (lb4_l3dsr_port_node) =
1139   {
1140     .function = lb4_l3dsr_port_node_fn,
1141     .name = "lb4-l3dsr-port",
1142     .vector_size = sizeof(u32),
1143     .format_trace = format_lb_trace,
1144     .n_errors = LB_N_ERROR,
1145     .error_strings = lb_error_strings,
1146     .n_next_nodes = LB_N_NEXT,
1147     .next_nodes =
1148         { [LB_NEXT_DROP] = "error-drop" },
1149   };

 999 static uword
1000 lb4_l3dsr_port_node_fn (vlib_main_t * vm, vlib_node_runtime_t * node,
1001                         vlib_frame_t * frame)
1002 {
1003   return lb_node_fn (vm, node, frame, 1, LB_ENCAP_TYPE_L3DSR, 1);
1004 }

 254 static_always_inline uword
 255 lb_node_fn (vlib_main_t * vm,
 256             vlib_node_runtime_t * node,
 257             vlib_frame_t * frame,
 258             u8 is_input_v4, //Compile-time parameter stating that is input is v4 (or v6)
 259             lb_encap_type_t encap_type, //Compile-time parameter is GRE4/GRE6/L3DSR/NAT4/NAT6
 260             u8 per_port_vip) //Compile-time parameter stating that is per_port_vip or not
 261 {
 262   lb_main_t *lbm = &lb_main;
 263   u32 n_left_from, *from, next_index, *to_next, n_left_to_next;
 264   u32 thread_index = vm->thread_index;
 265   u32 lb_time = lb_hash_time_now (vm);
 266
 267   lb_hash_t *sticky_ht = lb_get_sticky_table (thread_index);
 268   from = vlib_frame_vector_args (frame);
 269   n_left_from = frame->n_vectors;
 270   next_index = node->cached_next_index;
 271
 272   u32 nexthash0 = 0;
 273   u32 next_vip_idx0 = ~0;
 274   if (PREDICT_TRUE(n_left_from > 0))
 275     {
 276       vlib_buffer_t *p0 = vlib_get_buffer (vm, from[0]);
 277       lb_node_get_hash (lbm, p0, is_input_v4, &nexthash0,
 278                         &next_vip_idx0, per_port_vip);
 279     }
 280
 281   while (n_left_from > 0)
 282     {
 283       vlib_get_next_frame(vm, node, next_index, to_next, n_left_to_next);
 284       while (n_left_from > 0 && n_left_to_next > 0)
 285         {
 286           u32 pi0;
 287           vlib_buffer_t *p0;
 288           lb_vip_t *vip0;
 289           u32 asindex0 = 0;
 290           u16 len0;
 291           u32 available_index0;
 292           u8 counter = 0;
 293           u32 hash0 = nexthash0;
 294           u32 vip_index0 = next_vip_idx0;
 295           u32 next0;
 ...
 342           lb_hash_get (sticky_ht, hash0,
 343                        vip_index0, lb_time,
 344                        &available_index0, &asindex0);
 ...
 // asのdpoにより次のnodeを決定する
 537           next0 = lbm->ass[asindex0].dpo.dpoi_next_node;
 538           //Note that this is going to error if asindex0 == 0
 539           vnet_buffer (p0)->ip.adj_index[VLIB_TX] =
 540               lbm->ass[asindex0].dpo.dpoi_index;
 541
 542           if (PREDICT_FALSE(p0->flags & VLIB_BUFFER_IS_TRACED))
 543             {
 544               lb_trace_t *tr = vlib_add_trace (vm, node, p0, sizeof(*tr));
 545               tr->as_index = asindex0;
 546               tr->vip_index = vip_index0;
 547             }
 548
 549           //Enqueue to next
 550           vlib_validate_buffer_enqueue_x1(
 551               vm, node, next_index, to_next, n_left_to_next, pi0, next0);
 552         }
 553       vlib_put_next_frame (vm, node, next_index, n_left_to_next);
 554     }
 555
 556   return frame->n_vectors;
 557 }
```

## ass の追加

```c:lb.c
 585 int lb_vip_add_ass(u32 vip_index, ip46_address_t *addresses, u32 n)
 586 {
 587   lb_main_t *lbm = &lb_main;
 588   lb_get_writer_lock();
 589   lb_vip_t *vip;
 590   if (!(vip = lb_vip_get_by_index(vip_index))) {
 591     lb_put_writer_lock();
 592     return VNET_API_ERROR_NO_SUCH_ENTRY;
 593   }
 ...
 643   //Create those who have to be created
 644   vec_foreach(ip, to_be_added) {
 645     lb_as_t *as;
 646     u32 *as_index;
 647     pool_get(lbm->ass, as);
 648     as->address = addresses[*ip];
 649     as->flags = LB_AS_FLAGS_USED;
 650     as->vip_index = vip_index;
 651     pool_get(vip->as_indexes, as_index);
 652     *as_index = as - lbm->ass;
 653
 654     /*
 655      * become a child of the FIB entry
 656      * so we are informed when its forwarding changes
 657      */
 658     fib_prefix_t nh = {};
 659     if (lb_encap_is_ip4(vip)) {
 660         nh.fp_addr.ip4 = as->address.ip4;
 661         nh.fp_len = 32;
 662         nh.fp_proto = FIB_PROTOCOL_IP4;
 663     } else {
 664         nh.fp_addr.ip6 = as->address.ip6;
 665         nh.fp_len = 128;
 666         nh.fp_proto = FIB_PROTOCOL_IP6;
 667     }
 668
 669     as->next_hop_fib_entry_index =
 670         fib_table_entry_special_add(0,
 671                                     &nh,
 672                                     FIB_SOURCE_RR,
 673                                     FIB_ENTRY_FLAG_NONE);
 674     as->next_hop_child_index =
 675         fib_entry_child_add(as->next_hop_fib_entry_index,
 676                             lbm->fib_node_type,
 677                             as - lbm->ass);
 678
 679     lb_as_stack(as);
 ...
 748   }
 749   vec_free(to_be_added);
 750
 751   //Recompute flows
 752   lb_vip_update_new_flow_table(vip);
 753
 754   //Garbage collection maybe
 755   lb_vip_garbage_collection(vip);
 756
 757   lb_put_writer_lock();
 758   return 0;
 759 }
```

```c:plugins/lb/lb.c
  1289 static void
  1290 lb_as_stack (lb_as_t *as)
  1291 {
  1292   lb_main_t *lbm = &lb_main;
  1293   lb_vip_t *vip = &lbm->vips[as->vip_index];
  1294   dpo_type_t dpo_type = 0;
  1295
  1296   if (lb_vip_is_gre4(vip))
  1297     dpo_type = lbm->dpo_gre4_type;
  1298   else if (lb_vip_is_gre6(vip))
  1299     dpo_type = lbm->dpo_gre6_type;
  1300   else if (lb_vip_is_gre4_port(vip))
  1301     dpo_type = lbm->dpo_gre4_port_type;
  1302   else if (lb_vip_is_gre6_port(vip))
  1303     dpo_type = lbm->dpo_gre6_port_type;
  1304   else if (lb_vip_is_l3dsr(vip))
  1305     dpo_type = lbm->dpo_l3dsr_type;
  1306   else if (lb_vip_is_l3dsr_port(vip))
  1307     dpo_type = lbm->dpo_l3dsr_port_type;
  1308   else if(lb_vip_is_nat4_port(vip))
  1309     dpo_type = lbm->dpo_nat4_port_type;
  1310   else if (lb_vip_is_nat6_port(vip))
  1311     dpo_type = lbm->dpo_nat6_port_type;
  1312
  1313   dpo_stack(dpo_type,
  1314             lb_vip_is_ip4(vip->type)?DPO_PROTO_IP4:DPO_PROTO_IP6,
  1315             &as->dpo,
  1316             fib_entry_contribute_ip_forwarding(
  1317                 as->next_hop_fib_entry_index));
  1318 }
```

```c:vnet/fib/fib_entry.c
 505 const dpo_id_t *
 506 fib_entry_contribute_ip_forwarding (fib_node_index_t fib_entry_index)
 507 {
 508     fib_forward_chain_type_t fct;
 509     fib_entry_t *fib_entry;
 510
 511     fib_entry = fib_entry_get(fib_entry_index);
 512     fct = fib_entry_get_default_chain_type(fib_entry);
 513
 514     ASSERT((fct == FIB_FORW_CHAIN_TYPE_UNICAST_IP4 ||
 515             fct == FIB_FORW_CHAIN_TYPE_UNICAST_IP6));
 516
 517     if (dpo_id_is_valid(&fib_entry->fe_lb))
 518     {
 519         return (&fib_entry->fe_lb);
 520     }
 521
 522     return (drop_dpo_get(fib_forw_chain_type_to_dpo_proto(fct)));
 523 }
```

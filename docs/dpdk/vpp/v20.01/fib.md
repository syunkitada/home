# FIB

- [fib](https://fd.io/docs/vpp/master/gettingstarted/developers/fib20/index.html)

## fib_table_entry

```
299 /**
300  * An entry in a FIB table.
301  *
302  * This entry represents a route added to the FIB that is stored
303  * in one of the FIB tables.
304  */
305 typedef struct fib_entry_t_ {
306     /**
307      * Base class. The entry's node representation in the graph.
308      */
309     fib_node_t fe_node;
310     /**
311      * The prefix of the route. this is const just to be sure.
312      * It is the entry's key/identity and so should never change.
313      */
314     const fib_prefix_t fe_prefix;
315     /**
316      * The index of the FIB table this entry is in
317      */
318     u32 fe_fib_index;
319     /**
320      * The load-balance used for forwarding.
321      *
322      * We don't share the EOS and non-EOS even in case when they could be
323      * because:
324      *   - complexity & reliability v. memory
325      *       determining the conditions where sharing is possible is non-trivial.
326      *   - separate LBs means we can get the EOS bit right in the MPLS label DPO
327      *     and so save a few clock cycles in the DP imposition node since we can
328      *     paint the header straight on without the need to check the packet
329      *     type to derive the EOS bit value.
330      */
331     dpo_id_t fe_lb;
332     /**
333      * Vector of source infos.
334      * Most entries will only have 1 source. So we optimise for memory usage,
335      * which is preferable since we have many entries.
336      */
337     fib_entry_src_t *fe_srcs;
338     /**
339      * the path-list for which this entry is a child. This is also the path-list
340      * that is contributing forwarding for this entry.
341      */
342     fib_node_index_t fe_parent;
343     /**
344      * index of this entry in the parent's child list.
345      * This is set when this entry is added as a child, but can also
346      * be changed by the parent as it manages its list.
347      */
348     u32 fe_sibling;
349
350     /**
351      * A vector of delegate indices.
352      */
353     index_t *fe_delegates;
354 } fib_entry_t;
```

## fib_table_entry の追加

```c:vnet/fib/fib_table.c
 404 fib_node_index_t
 405 fib_table_entry_special_add (u32 fib_index,
 406                              const fib_prefix_t *prefix,
 407                              fib_source_t source,
 408                              fib_entry_flag_t flags)
 409 {
 410     fib_node_index_t fib_entry_index;
 411     dpo_id_t tmp_dpo = DPO_INVALID;
 412
 413     dpo_copy(&tmp_dpo, drop_dpo_get(fib_proto_to_dpo(prefix->fp_proto)));
 414
 415     fib_entry_index = fib_table_entry_special_dpo_add(fib_index, prefix, source,
 416                                                       flags, &tmp_dpo);
 417
 418     dpo_unlock(&tmp_dpo);
 419
 420     return (fib_entry_index);
 421 }
```

```c:vnet/fib/fib_table.c
 323 fib_node_index_t
 324 fib_table_entry_special_dpo_add (u32 fib_index,
 325                                  const fib_prefix_t *prefix,
 326                                  fib_source_t source,
 327                                  fib_entry_flag_t flags,
 328                                  const dpo_id_t *dpo)
 329 {
 330     fib_node_index_t fib_entry_index;
 331     fib_table_t *fib_table;
 332
 333     fib_table = fib_table_get(fib_index, prefix->fp_proto);
 334     fib_entry_index = fib_table_lookup_exact_match_i(fib_table, prefix);
 335
 336     if (FIB_NODE_INDEX_INVALID == fib_entry_index)
 337     {
 338         fib_entry_index = fib_entry_create_special(fib_index, prefix,
 339                                                    source, flags,
 340                                                    dpo);
 341
 342         fib_table_entry_insert(fib_table, prefix, fib_entry_index);
 343         fib_table_source_count_inc(fib_table, source);
 344     }
 345     else
 346     {
 347         int was_sourced;
 348
 349         was_sourced = fib_entry_is_sourced(fib_entry_index, source);
 350         fib_entry_special_add(fib_entry_index, source, flags, dpo);
 351
 352         if (was_sourced != fib_entry_is_sourced(fib_entry_index, source))
 353         {
 354         fib_table_source_count_inc(fib_table, source);
 355         }
 356     }
 357
 358
 359     return (fib_entry_index);
 360 }
```

```c:vnet/fib/fib_entry.c
 756 fib_node_index_t
 757 fib_entry_create_special (u32 fib_index,
 758                           const fib_prefix_t *prefix,
 759                           fib_source_t source,
 760                           fib_entry_flag_t flags,
 761                           const dpo_id_t *dpo)
 762 {
 763     fib_node_index_t fib_entry_index;
 764     fib_entry_t *fib_entry;
 765
 766     /*
 767      * create and initialize the new enty
 768      */
 769     fib_entry = fib_entry_alloc(fib_index, prefix, &fib_entry_index);
 770
 771     /*
 772      * create the path-list
 773      */
 774     fib_entry = fib_entry_src_action_add(fib_entry, source, flags, dpo);
 775     fib_entry_src_action_activate(fib_entry, source);
 776
 777     fib_entry = fib_entry_post_install_actions(fib_entry, source,
 778                                                FIB_ENTRY_FLAG_NONE);
 779
 780     FIB_ENTRY_DBG(fib_entry, "create-special");
 781
 782     return (fib_entry_index);
 783 }
```

```
   595 static fib_entry_t *
   596 fib_entry_alloc (u32 fib_index,
   597                  const fib_prefix_t *prefix,
   598                  fib_node_index_t *fib_entry_index)
   599 {
   600     fib_entry_t *fib_entry;
   601     fib_prefix_t *fep;
   602
   603     pool_get(fib_entry_pool, fib_entry);
   604     clib_memset(fib_entry, 0, sizeof(*fib_entry));
   605
   606     fib_node_init(&fib_entry->fe_node,
   607                   FIB_NODE_TYPE_ENTRY);
   608
   609     fib_entry->fe_fib_index = fib_index;
   610
   611     /*
   612      * the one time we need to update the const prefix is when
   613      * the entry is first created
   614      */
   615     fep = (fib_prefix_t*)&(fib_entry->fe_prefix);
   616     *fep = *prefix;
   617
   618     if (FIB_PROTOCOL_MPLS == fib_entry->fe_prefix.fp_proto)
   619     {
   620         fep->fp_len = 21;
   621         if (MPLS_NON_EOS == fep->fp_eos)
   622         {
   623             fep->fp_payload_proto = DPO_PROTO_MPLS;
   624         }
   625             ASSERT(DPO_PROTO_NONE != fib_entry->fe_prefix.fp_payload_proto);
   626     }
   627
   628     dpo_reset(&fib_entry->fe_lb); // DPO_INVALID がセットされる
   629
   630     *fib_entry_index = fib_entry_get_index(fib_entry);
   631
   632     return (fib_entry);
   633 }
```

```c:vnet/dpo/dpo.c
510 /**
511  * @brief Stack one DPO object on another, and thus establish a child-parent
512  * relationship. The VLIB graph arc used is taken from the parent and child types
513  * passed.
514  */
515 void
516 dpo_stack (dpo_type_t child_type,
517            dpo_proto_t child_proto,
518            dpo_id_t *dpo,
519            const dpo_id_t *parent)
520 {
521     dpo_stack_i(dpo_get_next_node(child_type, child_proto, parent), dpo, parent);
522 }


524 /**
525  * @brief Stack one DPO object on another, and thus establish a child parent
526  * relationship. A new VLIB graph arc is created from the child node passed
527  * to the nodes registered by the parent. The VLIB infra will ensure this arc
528  * is added only once.
529  */
530 void
531 dpo_stack_from_node (u32 child_node_index,
532                      dpo_id_t *dpo,
533                      const dpo_id_t *parent)
534 {
...
548     /*
549      * This loop is purposefully written with the worker thread lock in the
550      * inner loop because;
551      *  1) the likelihood that the edge does not exist is smaller
552      *  2) the likelihood there is more than one node is even smaller
553      * so we are optimising for not need to take the lock
554      */
555     vec_foreach(pi, parent_indices)
556     {
557         edge = vlib_node_get_next(vm, child_node_index, *pi);
558
559         if (~0 == edge)
560         {
561             vlib_worker_thread_barrier_sync(vm);
562
563             edge = vlib_node_add_next(vm, child_node_index, *pi);
564
565             vlib_worker_thread_barrier_release(vm);
566         }
567     }
568     dpo_stack_i(edge, dpo, parent);
569
570     /* should free this local vector to avoid memory leak */
571     vec_free(parent_indices);
572 }

// parentのdpoi_next_nodeにedgeをセットする
480 /**
481  * @brief Stack one DPO object on another, and thus establish a child parent
482  * relationship. The VLIB graph arc used is taken from the parent and child types
483  * passed.
484  */
485 static void
486 dpo_stack_i (u32 edge,
487              dpo_id_t *dpo,
488              const dpo_id_t *parent)
489 {
490     /*
491      * in order to get an atomic update of the parent we create a temporary,
492      * from a copy of the child, and add the next_node. then we copy to the parent
493      */
494     dpo_id_t tmp = DPO_INVALID;
495     dpo_copy(&tmp, parent);
496
497     /*
498      * get the edge index for the parent to child VLIB graph transition
499      */
500     tmp.dpoi_next_node = edge;
501
502     /*
503      * this update is atomic.
504      */
505     dpo_copy(dpo, &tmp);
506
507     dpo_reset(&tmp);
508 }
```

## dpo_type の登録(lb plugin)

```c:plugins/lb/lb.c
  78 const static char * const lb_dpo_l3dsr_ip4_port[] = {"lb4-l3dsr-port" , NULL};
  79 const static char* const * const lb_dpo_l3dsr_port_nodes[DPO_PROTO_NUM] =
  80     {
  81         [DPO_PROTO_IP4]  = lb_dpo_l3dsr_ip4_port,
  82     };

1360 clib_error_t *
1361 lb_init (vlib_main_t * vm)
1362 {
...
1407   lbm->dpo_l3dsr_port_type = dpo_register_new_type(&lb_vft,
1408                                                    lb_dpo_l3dsr_port_nodes);
```

```c:vnet/dpo/dpo.c

341 dpo_type_t
342 dpo_register_new_type (const dpo_vft_t *vft,
343                        const char * const * const * nodes)
344 {
345     dpo_type_t type = dpo_dynamic++;
346
347     dpo_register(type, vft, nodes);
348
349     return (type);
350 }

321 void
322 dpo_register (dpo_type_t type,
323               const dpo_vft_t *vft,
324               const char * const * const * nodes)
325 {
326     vec_validate(dpo_vfts, type);
327     dpo_vfts[type] = *vft;
328     if (NULL == dpo_vfts[type].dv_get_next_node)
329     {
330         dpo_vfts[type].dv_get_next_node = dpo_default_get_next_node;
331     }
332     if (NULL == dpo_vfts[type].dv_mk_interpose)
333     {
334         dpo_vfts[type].dv_mk_interpose = dpo_default_mk_interpose;
335     }
336
337     vec_validate(dpo_nodes, type);
338     dpo_nodes[type] = nodes;
339 }

// dv_get_next_nodeがNULLの場合は、以下が利用される
// vlib_get_node_by_nameによりnode名(lb4-l3dsr-port)から、nodeを取得する
286 static u32 *
287 dpo_default_get_next_node (const dpo_id_t *dpo)
288 {
289     u32 *node_indices = NULL;
290     const char *node_name;
291     u32 ii = 0;
292
293     node_name = dpo_nodes[dpo->dpoi_type][dpo->dpoi_proto][ii];
294     while (NULL != node_name)
295     {
296         vlib_node_t *node;
297
298         node = vlib_get_node_by_name(vlib_get_main(), (u8*) node_name);
299         ASSERT(NULL != node);
300         vec_add1(node_indices, node->index);
301
302         ++ii;
303         node_name = dpo_nodes[dpo->dpoi_type][dpo->dpoi_proto][ii];
304     }
305
306     return (node_indices);
307 }
```

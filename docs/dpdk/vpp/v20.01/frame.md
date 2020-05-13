# frame

- vector データ（一回の処理単位）
  - L1 キャッシュに収まるサイズ
- dpdk などの input-node は、受信したパケットから vector(frame)の配列(pending_frames)を生成する
  - frame は、packet を複数束ねたもの
  - 一つの frame の所有権は一つの graph-node のみが持つ
  - pending_frames に追加された時点で次の graph-node は確定している
- 各 graph-node は、frame 単位で処理を行う
- graph-node は、vlib_get_next_frame によって frame を取り出して取得処理を行う
- graph-node は、処理後の frame を vlib_put_next_frame によって pending_frames に追加する

## frame struct

```c:vlib/node.h
  381 /* Calling frame (think stack frame) for a node. */
  382 typedef struct vlib_frame_t
  383 {
  384   /* Frame flags. */
  385   u16 frame_flags;
  386
  387   /* User flags. Used for sending hints to the next node. */
  388   u16 flags;
  389
  390   /* Number of scalar bytes in arguments. */
  391   u8 scalar_size;
  392
  393   /* Number of bytes per vector argument. */
  394   u8 vector_size;
  395
  396   /* Number of vector elements currently in frame. */
  397   u16 n_vectors;
  398
  399   /* Scalar and vector arguments to next node. */
  400   u8 arguments[0];
  401 } vlib_frame_t;
```

## pending_frame struct

```c:vlib/node.h
  448 /* A frame pending dispatch by main loop. */
  449 typedef struct
  450 {
  451   /* Node and runtime for this frame. */
  452   u32 node_runtime_index;
  453
  454   /* Frame index (in the heap). */
  455   vlib_frame_t *frame;
  456
  457   /* Start of next frames for this node. */
  458   u32 next_frame_index;
  459
  460   /* Special value for next_frame_index when there is no next frame. */
  461 #define VLIB_PENDING_FRAME_NO_NEXT_FRAME ((u32) ~0)
  462 } vlib_pending_frame_t;
```

## vlib_get_next_frame

- 各 graph-node は、vlib_get_next_frame により処理すべき frame(vlib_frame_t \*) の取得を行う
  - vlib_get_next_frame(vm, node, next_index, to_next, n_left_to_next);

```c:vlib/node_funcs.h
 326 /** \brief Get pointer to next frame vector data by
 327     (@c vlib_node_runtime_t, @c next_index).
 328  Standard single/dual loop boilerplate element.
 329  @attention This is a MACRO, with SIDE EFFECTS.
 330
 331  @param vm vlib_main_t pointer, varies by thread
 332  @param node current node vlib_node_runtime_t pointer
 333  @param next_index requested graph arc index
 334
 335  @return @c vectors -- pointer to next available vector slot
 336  @return @c n_vectors_left -- number of vector slots available
 337 */
 338 #define vlib_get_next_frame(vm,node,next_index,vectors,n_vectors_left)        \
 339   vlib_get_next_frame_macro (vm, node, next_index,                        \
 340                              vectors, n_vectors_left,                        \
 341                              /* alloc new frame */ 0)
 342
 343 #define vlib_get_new_next_frame(vm,node,next_index,vectors,n_vectors_left) \
 344   vlib_get_next_frame_macro (vm, node, next_index,                        \
 345                              vectors, n_vectors_left,                        \
 346                              /* alloc new frame */ 1)

 315 #define vlib_get_next_frame_macro(vm,node,next_index,vectors,n_vectors_left,alloc_new_frame) \
 316 do {                                                                        \
 317   vlib_frame_t * _f                                                        \
 318     = vlib_get_next_frame_internal ((vm), (node), (next_index),                \
 319                                     (alloc_new_frame));                        \
 320   u32 _n = _f->n_vectors;                                                \
 321   (vectors) = vlib_frame_vector_args (_f) + _n * sizeof ((vectors)[0]); \
 322   (n_vectors_left) = VLIB_FRAME_SIZE - _n;                                \
 323 } while (0)
```

```c:vlib/main.c
 354 vlib_frame_t *
 355 vlib_get_next_frame_internal (vlib_main_t * vm,
 356                               vlib_node_runtime_t * node,
 357                               u32 next_index, u32 allocate_new_next_frame)
 358 {
 359   vlib_frame_t *f;
 360   vlib_next_frame_t *nf;
 361   u32 n_used;
 362
 363   nf = vlib_node_runtime_get_next_frame (vm, node, next_index);
 ...
 376   f = nf->frame;
 ...
 388   /* Allocate new frame if current one is marked as no-append or
 389      it is already full. */
 390   n_used = f->n_vectors;
 391   if (n_used >= VLIB_FRAME_SIZE || (allocate_new_next_frame && n_used > 0) ||
 392       (f->frame_flags & VLIB_FRAME_NO_APPEND))
 393     {
 394       /* Old frame may need to be freed after dispatch, since we'll have
 395          two redundant frames from node -> next node. */
 396       if (!(nf->flags & VLIB_FRAME_NO_FREE_AFTER_DISPATCH))
 397         {
 398           vlib_frame_t *f_old = vlib_get_frame (vm, nf->frame);
 399           f_old->frame_flags |= VLIB_FRAME_FREE_AFTER_DISPATCH;
 400         }
 401
 402       /* Allocate new frame to replace full one. */
 403       f = nf->frame = vlib_frame_alloc (vm, node, next_index);
 404       n_used = f->n_vectors;
 405     }
 ...
 416   return f;
 417 }
```

```c:vlib/node_funcs.h
 263 always_inline vlib_next_frame_t *
 264 vlib_node_runtime_get_next_frame (vlib_main_t * vm,
 265                                   vlib_node_runtime_t * n, u32 next_index)
 266 {
 267   vlib_node_main_t *nm = &vm->node_main;
 268   vlib_next_frame_t *nf;
 269
 270   ASSERT (next_index < n->n_next_nodes);
 271   nf = vec_elt_at_index (nm->next_frames, n->next_frame_index + next_index);
 272
 273   if (CLIB_DEBUG > 0)
 274     {
 275       vlib_node_t *node, *next;
 276       node = vec_elt (nm->nodes, n->node_index);
 277       next = vec_elt (nm->nodes, node->next_nodes[next_index]);
 278       ASSERT (nf->node_runtime_index == next->runtime_index);
 279     }
 280
 281   return nf;
 282 }
```

## vlib_put_next_frame

- vlib_put_next_frame (vm, node, next_index, n_left_to_next)
- nm->pending_frames に next_frame を突っ込む

```c:vlib/main.c
 455 void
 456 vlib_put_next_frame (vlib_main_t * vm,
 457                      vlib_node_runtime_t * r,
 458                      u32 next_index, u32 n_vectors_left)
 459 {
 460   vlib_node_main_t *nm = &vm->node_main;
 461   vlib_next_frame_t *nf;
 462   vlib_frame_t *f;
 463   u32 n_vectors_in_frame;
 ...
 468   nf = vlib_node_runtime_get_next_frame (vm, r, next_index);
 469   f = vlib_get_frame (vm, nf->frame);
 ...
 481   n_vectors_in_frame = VLIB_FRAME_SIZE - n_vectors_left;
 482
 483   f->n_vectors = n_vectors_in_frame;
 484
 485   /* If vectors were added to frame, add to pending vector. */
 486   if (PREDICT_TRUE (n_vectors_in_frame > 0))
 487     {
 488       vlib_pending_frame_t *p;
 489       u32 v0, v1;
 490
 491       r->cached_next_index = next_index;
 492
 493       if (!(f->frame_flags & VLIB_FRAME_PENDING))
 494         {
 495           __attribute__ ((unused)) vlib_node_t *node;
 496           vlib_node_t *next_node;
 497           vlib_node_runtime_t *next_runtime;
 ...
 499           node = vlib_get_node (vm, r->node_index);
 500           next_node = vlib_get_next_node (vm, r->node_index, next_index);
 501           next_runtime = vlib_node_get_runtime (vm, next_node->index);
 502
 503           vec_add2 (nm->pending_frames, p, 1);
 504
 505           p->frame = nf->frame;
 506           p->node_runtime_index = nf->node_runtime_index;
 507           p->next_frame_index = nf - nm->next_frames;
 508           nf->flags |= VLIB_FRAME_PENDING;
 509           f->frame_flags |= VLIB_FRAME_PENDING;
 510
 511           /*
 512            * If we're going to dispatch this frame on another thread,
 513            * force allocation of a new frame. Otherwise, we create
 514            * a dangling frame reference. Each thread has its own copy of
 515            * the next_frames vector.
 516            */
 517           if (0 && r->thread_index != next_runtime->thread_index)
 518             {
 519               nf->frame = NULL;
 520               nf->flags &= ~(VLIB_FRAME_PENDING | VLIB_FRAME_IS_ALLOCATED);
 521             }
 522         }
 523
 524       /* Copy trace flag from next_frame and from runtime. */
 525       nf->flags |=
 526         (nf->flags & VLIB_NODE_FLAG_TRACE) | (r->
 527                                               flags & VLIB_NODE_FLAG_TRACE);
 528
 529       v0 = nf->vectors_since_last_overflow;
 530       v1 = v0 + n_vectors_in_frame;
 531       nf->vectors_since_last_overflow = v1;
 532       if (PREDICT_FALSE (v1 < v0))
 533         {
 534           vlib_node_t *node = vlib_get_node (vm, r->node_index);
 535           vec_elt (node->n_vectors_by_next_node, next_index) += v0;
 536         }
 537     }
 538 }
```

## pending_frames

- vlib_put_next_frame で add された pending_frames はひたすら dispatch_pending_node で処理される
- pending_frame の中に、node_runtime_index が含まれてるので、これにより次の graph-node を取り出す
- その後、dispatch_node で node_runtime の function で frame を処理する

```
1832       for (i = 0; i < _vec_len (nm->pending_frames); i++)
1833         cpu_time_now = dispatch_pending_node (vm, i, cpu_time_now);


1324 static u64
1325 dispatch_pending_node (vlib_main_t * vm, uword pending_frame_index,
1326                        u64 last_time_stamp)
1327 {
1328   vlib_node_main_t *nm = &vm->node_main;
1329   vlib_frame_t *f;
1330   vlib_next_frame_t *nf, nf_dummy;
1331   vlib_node_runtime_t *n;
1332   vlib_frame_t *restore_frame;
1333   vlib_pending_frame_t *p;
1334
1335   /* See comment below about dangling references to nm->pending_frames */
1336   p = nm->pending_frames + pending_frame_index;
1337
1338   n = vec_elt_at_index (nm->nodes_by_type[VLIB_NODE_TYPE_INTERNAL],
1339                         p->node_runtime_index);
1340
1341   f = vlib_get_frame (vm, p->frame);

1376   last_time_stamp = dispatch_node (vm, n,
1377                                    VLIB_NODE_TYPE_INTERNAL,
1378                                    VLIB_NODE_STATE_POLLING,
1379                                    f, last_time_stamp);


1131 static_always_inline u64
1132 dispatch_node (vlib_main_t * vm,
1133                vlib_node_runtime_t * node,
1134                vlib_node_type_t type,
1135                vlib_node_state_t dispatch_state,
1136                vlib_frame_t * frame, u64 last_time_stamp)
1137 {
...
1208       n = node->function (vm, node, frame);
```

- node の登録

```
  320 static void
  321 register_node (vlib_main_t * vm, vlib_node_registration_t * r)
  322 {

  428   /* Initialize node runtime. */
  429   {
  430     vlib_node_runtime_t *rt;
  431     u32 i;
  432
  433     if (n->type == VLIB_NODE_TYPE_PROCESS)
  434       {

  489     else
  490       {
  491         vec_add2_aligned (nm->nodes_by_type[n->type], rt, 1,
  492                           /* align */ CLIB_CACHE_LINE_BYTES);
  493         n->runtime_index = rt - nm->nodes_by_type[n->type];
  494       }
```

# frame

- vector データ（一回の処理単位）
  - L1 キャッシュに収まるサイズ
- dpdk などの input-node は、受信したパケットから vector(frame)の配列(pending_frames)を生成する
  - frame は、packet を複数束ねたもの
  - 一つの frame の所有権は一つの graph-node のみが持つ
  - pending_frames に追加された時点で次の graph-node は確定している
- 各 graph-node は、frame 単位で処理を行う
- graph-node は、vlib_get_next_frame によって pending_frames から pending_frame を取り出して取得処理を行う
- graph-node は、処理後の frame を vlib_put_next_frame によって pending_frames にを追加する
- そして次の graph-node も次の frame 位置から pending_frames の処理を行う

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

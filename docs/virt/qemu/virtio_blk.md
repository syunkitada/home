# virtio-blk


## Contents
| Link | Description |
| --- | --- |
| [TypeInfoの定義と登録](#init-kvm-start)               | virtio-blkのデバイス定義 |
| [realize](#realize)                                   | realize処理、ここでvirtioのキューに対してハンドラを設定する |
| [virtio_blk_handle_output](#virtio_blk_handle_output) | ハンドラ内の処理、IOリクエストの数だけcorutineでドライバ(qcow2など)を使ってIOし、完了したらゲストに通知する |


## TypeInfoの定義と登録
* いつもの
> hw/block/virtio-blk.c
```
  1020 static void virtio_blk_class_init(ObjectClass *klass, void *data)
  1021 {
  1022     DeviceClass *dc = DEVICE_CLASS(klass);
  1023     VirtioDeviceClass *vdc = VIRTIO_DEVICE_CLASS(klass);
  1024
  1025     dc->props = virtio_blk_properties;
  1026     dc->vmsd = &vmstate_virtio_blk;
  1027     set_bit(DEVICE_CATEGORY_STORAGE, dc->categories);
  1028     vdc->realize = virtio_blk_device_realize;
  1029     vdc->unrealize = virtio_blk_device_unrealize;
  1030     vdc->get_config = virtio_blk_update_config;
  1031     vdc->set_config = virtio_blk_set_config;
  1032     vdc->get_features = virtio_blk_get_features;
  1033     vdc->set_status = virtio_blk_set_status;
  1034     vdc->reset = virtio_blk_reset;
  1035     vdc->save = virtio_blk_save_device;
  1036     vdc->load = virtio_blk_load_device;
  1037     vdc->start_ioeventfd = virtio_blk_data_plane_start;
  1038     vdc->stop_ioeventfd = virtio_blk_data_plane_stop;
  1039 }
  1040
  1041 static const TypeInfo virtio_blk_info = {
  1042     .name = TYPE_VIRTIO_BLK,
  1043     .parent = TYPE_VIRTIO_DEVICE,
  1044     .instance_size = sizeof(VirtIOBlock),
  1045     .instance_init = virtio_blk_instance_init,
  1046     .class_init = virtio_blk_class_init,
  1047 };
  1048
  1049 static void virtio_register_types(void)
  1050 {
  1051     type_register_static(&virtio_blk_info);
  1052 }
  1053
  1054 type_init(virtio_register_types)
```


## realize
* サポートするqueueの数だけ、virtio_add_queueでqueueを作成する
    * queue作成時に、ハンドラvirtio_blk_handle_outputをセットしている
    * 実際の書き込みリクエストがあると、ハンドラvirtio_blk_handle_output呼び出され、書き込み処理を担当する
> hw/block/virtio-blk.c
```
911 static void virtio_blk_device_realize(DeviceState *dev, Error **errp)
912 {
913     VirtIODevice *vdev = VIRTIO_DEVICE(dev);
914     VirtIOBlock *s = VIRTIO_BLK(dev);
915     VirtIOBlkConf *conf = &s->conf;
916     Error *err = NULL;
917     unsigned i;
...
932     blkconf_serial(&conf->conf, &conf->serial);
933     blkconf_apply_backend_options(&conf->conf,
934                                   blk_is_read_only(conf->conf.blk), true,
935                                   &err);
...
940     s->original_wce = blk_enable_write_cache(conf->conf.blk);
941     blkconf_geometry(&conf->conf, NULL, 65535, 255, 255, &err);
...
946     blkconf_blocksizes(&conf->conf);
947
948     virtio_init(vdev, "virtio-blk", VIRTIO_ID_BLOCK,
949                 sizeof(struct virtio_blk_config));
950
951     s->blk = conf->conf.blk;
952     s->rq = NULL;
953     s->sector_mask = (s->conf.conf.logical_block_size / BDRV_SECTOR_SIZE) - 1;
954
955     for (i = 0; i < conf->num_queues; i++) {
956         virtio_add_queue(vdev, 128, virtio_blk_handle_output);
957     }
958     virtio_blk_data_plane_create(vdev, conf, &s->dataplane, &err);
...
965     s->change = qemu_add_vm_change_state_handler(virtio_blk_dma_restart_cb, s);
966     blk_set_dev_ops(s->blk, &virtio_block_ops, s);
967     blk_set_guest_block_size(s->blk, s->conf.conf.logical_block_size);
968
969     blk_iostatus_enable(s->blk);
970 }
```

>hw/virtio/virtio.c
```
1574 VirtQueue *virtio_add_queue(VirtIODevice *vdev, int queue_size,
1575                             VirtIOHandleOutput handle_output)
1576 {
1577     int i;
1578
1579     for (i = 0; i < VIRTIO_QUEUE_MAX; i++) {
1580         if (vdev->vq[i].vring.num == 0)
1581             break;
1582     }
1583
1584     if (i == VIRTIO_QUEUE_MAX || queue_size > VIRTQUEUE_MAX_SIZE)
1585         abort();
1586
1587     vdev->vq[i].vring.num = queue_size;
1588     vdev->vq[i].vring.num_default = queue_size;
1589     vdev->vq[i].vring.align = VIRTIO_PCI_VRING_ALIGN;
1590     vdev->vq[i].handle_output = handle_output;
1591     vdev->vq[i].handle_aio_output = NULL;
1592
1593     return &vdev->vq[i];
1594 }
```


## virtio_blk_handle_output
* virtio_blk_handle_outputがハンドラとして登録している関数で、リクエストを処理する実態はvirtio_blk_submit_multireq

```
   595 bool virtio_blk_handle_vq(VirtIOBlock *s, VirtQueue *vq)
   596 {
   597     VirtIOBlockReq *req;
   598     MultiReqBuffer mrb = {};
   599     bool progress = false;
   600
   601     aio_context_acquire(blk_get_aio_context(s->blk));
   602     blk_io_plug(s->blk);
   603
   604     do {
   605         virtio_queue_set_notification(vq, 0);
   606
   607         while ((req = virtio_blk_get_request(s, vq))) {
   608             progress = true;
   609             if (virtio_blk_handle_request(req, &mrb)) {
   610                 virtqueue_detach_element(req->vq, &req->elem, 0);
   611                 virtio_blk_free_request(req);
   612                 break;
   613             }
   614         }
   615
   616         virtio_queue_set_notification(vq, 1);
   617     } while (!virtio_queue_empty(vq));
   618
   619     if (mrb.num_reqs) {
   620         virtio_blk_submit_multireq(s->blk, &mrb);
   621     }
   622
   623     blk_io_unplug(s->blk);
   624     aio_context_release(blk_get_aio_context(s->blk));
   625     return progress;
   626 }
   627
   628 static void virtio_blk_handle_output_do(VirtIOBlock *s, VirtQueue *vq)
   629 {
   630     virtio_blk_handle_vq(s, vq);
   631 }
   632
   633 static void virtio_blk_handle_output(VirtIODevice *vdev, VirtQueue *vq)
   634 {
   635     VirtIOBlock *s = (VirtIOBlock *)vdev;
   636
   637     if (s->dataplane) {
   638         /* Some guests kick before setting VIRTIO_CONFIG_S_DRIVER_OK so start
   639          * dataplane here instead of waiting for .set_status().
   640          */
   641         virtio_device_start_ioeventfd(vdev);
   642         if (!s->dataplane_disabled) {
   643             return;
   644         }
   645     }
   646     virtio_blk_handle_output_do(s, vq);
   647 }
```


* virtio_blk_submit_multireq
* これが、submit_requestsを呼ぶ
* requestがmultiであれば、その分だけsubmit_requestsを呼ぶ
```
   395 static void virtio_blk_submit_multireq(BlockBackend *blk, MultiReqBuffer *mrb)
   396 {
   397     int i = 0, start = 0, num_reqs = 0, niov = 0, nb_sectors = 0;
   398     uint32_t max_transfer;
   399     int64_t sector_num = 0;
   400
   401     if (mrb->num_reqs == 1) {
   402         submit_requests(blk, mrb, 0, 1, -1);
   403         mrb->num_reqs = 0;
   404         return;
   405     }
   406
   407     max_transfer = blk_get_max_transfer(mrb->reqs[0]->dev->blk);
   408
   409     qsort(mrb->reqs, mrb->num_reqs, sizeof(*mrb->reqs),
   410           &multireq_compare);
   411
   412     for (i = 0; i < mrb->num_reqs; i++) {
   413         VirtIOBlockReq *req = mrb->reqs[i];
   414         if (num_reqs > 0) {
   415             /*
   416              * NOTE: We cannot merge the requests in below situations:
   417              * 1. requests are not sequential
   418              * 2. merge would exceed maximum number of IOVs
   419              * 3. merge would exceed maximum transfer length of backend device
   420              */
   421             if (sector_num + nb_sectors != req->sector_num ||
   422                 niov > blk_get_max_iov(blk) - req->qiov.niov ||
   423                 req->qiov.size > max_transfer ||
   424                 nb_sectors > (max_transfer -
   425                               req->qiov.size) / BDRV_SECTOR_SIZE) {
   426                 submit_requests(blk, mrb, start, num_reqs, niov);
   427                 num_reqs = 0;
   428             }
   429         }
   430
   431         if (num_reqs == 0) {
   432             sector_num = req->sector_num;
   433             nb_sectors = niov = 0;
   434             start = i;
   435         }
   436
   437         nb_sectors += req->qiov.size / BDRV_SECTOR_SIZE;
   438         niov += req->qiov.niov;
   439         num_reqs++;
   440     }
```

* submet_requestsは、aioのcomplete時に呼ばれるハンドラ(virtio_blk_rw_complete)を登録してaioリクエストする
```
   332 static inline void submit_requests(BlockBackend *blk, MultiReqBuffer *mrb,
   333                                    int start, int num_reqs, int niov)
   334 {
   335     QEMUIOVector *qiov = &mrb->reqs[start]->qiov;
   336     int64_t sector_num = mrb->reqs[start]->sector_num;
   337     bool is_write = mrb->is_write;
   338
   339     if (num_reqs > 1) {
   340         int i;
   341         struct iovec *tmp_iov = qiov->iov;
   342         int tmp_niov = qiov->niov;
   343
   344         /* mrb->reqs[start]->qiov was initialized from external so we can't
   345          * modify it here. We need to initialize it locally and then add the
   346          * external iovecs. */
   347         qemu_iovec_init(qiov, niov);
   348
   349         for (i = 0; i < tmp_niov; i++) {
   350             qemu_iovec_add(qiov, tmp_iov[i].iov_base, tmp_iov[i].iov_len);
   351         }
   352
   353         for (i = start + 1; i < start + num_reqs; i++) {
   354             qemu_iovec_concat(qiov, &mrb->reqs[i]->qiov, 0,
   355                               mrb->reqs[i]->qiov.size);
   356             mrb->reqs[i - 1]->mr_next = mrb->reqs[i];
   357         }
   ...
   363         block_acct_merge_done(blk_get_stats(blk),
   364                               is_write ? BLOCK_ACCT_WRITE : BLOCK_ACCT_READ,
   365                               num_reqs - 1);
   366     }
   367
   368     if (is_write) {
   369         blk_aio_pwritev(blk, sector_num << BDRV_SECTOR_BITS, qiov, 0,
   370                         virtio_blk_rw_complete, mrb->reqs[start]);
   371     } else {
   372         blk_aio_preadv(blk, sector_num << BDRV_SECTOR_BITS, qiov, 0,
   373                        virtio_blk_rw_complete, mrb->reqs[start]);
   374     }
   375 }
```

* virtio_blk_rw_complete、virtio_blk_req_completeでcomplete処理を行う
* 最終的にはvirtio_blk_req_completeが、eventfd経由でゲストのvirtio driverにcomplete通知を行う
> hw/block/virtio-blk.c
```
  48 static void virtio_blk_req_complete(VirtIOBlockReq *req, unsigned char status)
  49 {
  50     VirtIOBlock *s = req->dev;
  51     VirtIODevice *vdev = VIRTIO_DEVICE(s);
  52
  53     trace_virtio_blk_req_complete(vdev, req, status);
  54
  55     stb_p(&req->in->status, status);
  56     virtqueue_push(req->vq, &req->elem, req->in_len);
  57     if (s->dataplane_started && !s->dataplane_disabled) {
  58         virtio_blk_data_plane_notify(s->dataplane, req->vq);
  59     } else {
  60         virtio_notify(vdev, req->vq);
  61     }
  62 }
...
  87 static void virtio_blk_rw_complete(void *opaque, int ret)
  88 {
  89     VirtIOBlockReq *next = opaque;
  90     VirtIOBlock *s = next->dev;
  91     VirtIODevice *vdev = VIRTIO_DEVICE(s);
  92
  93     aio_context_acquire(blk_get_aio_context(s->conf.conf.blk));
  94     while (next) {
  95         VirtIOBlockReq *req = next;
  96         next = req->mr_next;
  97         trace_virtio_blk_rw_complete(vdev, req, ret);
  98
  99         if (req->qiov.nalloc != -1) {
 100             /* If nalloc is != 1 req->qiov is a local copy of the original
 101              * external iovec. It was allocated in submit_merged_requests
 102              * to be able to merge requests. */
 103             qemu_iovec_destroy(&req->qiov);
 104         }
 105
 106         if (ret) {
 107             int p = virtio_ldl_p(VIRTIO_DEVICE(req->dev), &req->out.type);
 108             bool is_read = !(p & VIRTIO_BLK_T_OUT);
 109             /* Note that memory may be dirtied on read failure.  If the
 110              * virtio request is not completed here, as is the case for
 111              * BLOCK_ERROR_ACTION_STOP, the memory may not be copied
 112              * correctly during live migration.  While this is ugly,
 113              * it is acceptable because the device is free to write to
 114              * the memory until the request is completed (which will
 115              * happen on the other side of the migration).
 116              */
 117             if (virtio_blk_handle_rw_error(req, -ret, is_read)) {
 118                 continue;
 119             }
 120         }
 121
 122         virtio_blk_req_complete(req, VIRTIO_BLK_S_OK);
 123         block_acct_done(blk_get_stats(req->dev->blk), &req->acct);
 124         virtio_blk_free_request(req);
 125     }
 126     aio_context_release(blk_get_aio_context(s->conf.conf.blk));
 127 }
```

* io requestを処理するcorutine(スレッド)を作成し、BlockCompletionFunc *cbをセットする
    * io処理はこのcorutineが行い、complete時に*cbが呼ばれる
        * qcow2であればqcow2_co_pwritevが実態
> block/block_backend.c
```
1277 static BlockAIOCB *blk_aio_prwv(BlockBackend *blk, int64_t offset, int bytes,
1278                                 QEMUIOVector *qiov, CoroutineEntry co_entry,
1279                                 BdrvRequestFlags flags,
1280                                 BlockCompletionFunc *cb, void *opaque)
1281 {
1282     BlkAioEmAIOCB *acb;
1283     Coroutine *co;
1284
1285     bdrv_inc_in_flight(blk_bs(blk));
1286     acb = blk_aio_get(&blk_aio_em_aiocb_info, blk, cb, opaque);
1287     acb->rwco = (BlkRwCo) {
1288         .blk    = blk,
1289         .offset = offset,
1290         .qiov   = qiov,
1291         .flags  = flags,
1292         .ret    = NOT_DONE,
1293     };
1294     acb->bytes = bytes;
1295     acb->has_returned = false;
1296
1297     co = qemu_coroutine_create(co_entry, acb);
1298     bdrv_coroutine_enter(blk_bs(blk), co);
1299
1300     acb->has_returned = true;
1301     if (acb->rwco.ret != NOT_DONE) {
1302         aio_bh_schedule_oneshot(blk_get_aio_context(blk),
1303                                 blk_aio_complete_bh, acb);
1304     }
1305
1306     return &acb->common;
1307 }

1394 BlockAIOCB *blk_aio_pwritev(BlockBackend *blk, int64_t offset,
1395                             QEMUIOVector *qiov, BdrvRequestFlags flags,
1396                             BlockCompletionFunc *cb, void *opaque)
1397 {
1398     return blk_aio_prwv(blk, offset, qiov->size, qiov,
1399                         blk_aio_write_entry, flags, cb, opaque);
1400 }
```


* BlockAIOCBの取得
> block/block_backend.c
```
1869 void *blk_aio_get(const AIOCBInfo *aiocb_info, BlockBackend *blk,
1870                   BlockCompletionFunc *cb, void *opaque)
1871 {
1872     return qemu_aio_get(aiocb_info, blk_bs(blk), cb, opaque);
1873 }
```

> util/aiocb.c
``` c
 28 void *qemu_aio_get(const AIOCBInfo *aiocb_info, BlockDriverState *bs,
 29                    BlockCompletionFunc *cb, void *opaque)
 30 {
 31     BlockAIOCB *acb;
 32
 33     acb = g_malloc(aiocb_info->aiocb_size);
 34     acb->aiocb_info = aiocb_info;
 35     acb->bs = bs;
 36     acb->cb = cb;
 37     acb->opaque = opaque;
 38     acb->refcnt = 1;
 39     return acb;
 40 }
```


* BlockDriverのcoroutineに入る
> block.c
```
4670 void bdrv_coroutine_enter(BlockDriverState *bs, Coroutine *co)
4671 {
4672     aio_co_enter(bdrv_get_aio_context(bs), co);
4673 }
```

> util/async.c
```
472 void aio_co_enter(AioContext *ctx, struct Coroutine *co)
473 {
474     if (ctx != qemu_get_current_aio_context()) {
475         aio_co_schedule(ctx, co);
476         return;
477     }
478
479     if (qemu_in_coroutine()) {
480         Coroutine *self = qemu_coroutine_self();
481         assert(self != co);
482         QSIMPLEQ_INSERT_TAIL(&self->co_queue_wakeup, co, co_queue_next);
483     } else {
484         aio_context_acquire(ctx);
485         qemu_aio_coroutine_enter(ctx, co);
486         aio_context_release(ctx);
487     }
488 }
```


* blk_aio_write_entry
    * corutineの実行本体
> block/block_backend.c
```
1320 static void blk_aio_write_entry(void *opaque)
1321 {
1322     BlkAioEmAIOCB *acb = opaque;
1323     BlkRwCo *rwco = &acb->rwco;
1324
1325     assert(!rwco->qiov || rwco->qiov->size == acb->bytes);
1326     rwco->ret = blk_co_pwritev(rwco->blk, rwco->offset, acb->bytes,
1327                                rwco->qiov, rwco->flags);
1328     blk_aio_complete(acb);
1329 }
...
1110 int coroutine_fn blk_co_pwritev(BlockBackend *blk, int64_t offset,
1111                                 unsigned int bytes, QEMUIOVector *qiov,
1112                                 BdrvRequestFlags flags)
1113 {
1114     int ret;
1115     BlockDriverState *bs = blk_bs(blk);
1116
1117     trace_blk_co_pwritev(blk, bs, offset, bytes, flags);
1118
1119     ret = blk_check_byte_request(blk, offset, bytes);
1120     if (ret < 0) {
1121         return ret;
1122     }
1123
1124     bdrv_inc_in_flight(bs);
1125     /* throttling disk I/O */
1126     if (blk->public.throttle_group_member.throttle_state) {
1127         throttle_group_co_io_limits_intercept(&blk->public.throttle_group_member,
1128                 bytes, true);
1129     }
1130
1131     if (!blk->enable_write_cache) {
1132         flags |= BDRV_REQ_FUA;
1133     }
1134
1135     ret = bdrv_co_pwritev(blk->root, offset, bytes, qiov, flags);
1136     bdrv_dec_in_flight(bs);
1137     return ret;
1138 }
```

> block/io.c
```
1602 /*
1603  * Handle a write request in coroutine context
1604  */
1605 int coroutine_fn bdrv_co_pwritev(BdrvChild *child,
1606     int64_t offset, unsigned int bytes, QEMUIOVector *qiov,
1607     BdrvRequestFlags flags)
1608 {
...
1722     ret = bdrv_aligned_pwritev(child, &req, offset, bytes, align,
1723                                use_local_qiov ? &local_qiov : qiov,
1724                                flags);
...
1735     bdrv_dec_in_flight(bs);
1736     return ret;
1737 }
```

> block/io.c
``` c
1414 static int coroutine_fn bdrv_aligned_pwritev(BdrvChild *child,
1415     BdrvTrackedRequest *req, int64_t offset, unsigned int bytes,
1416     int64_t align, QEMUIOVector *qiov, int flags)
1417 {
...
1450
1451     ret = notifier_with_return_list_notify(&bs->before_write_notifiers, req);
...
1462     if (ret < 0) {
...
1469     } else if (bytes <= max_transfer) {
1470         bdrv_debug_event(bs, BLKDBG_PWRITEV);
1471         ret = bdrv_driver_pwritev(bs, offset, bytes, qiov, flags);
1472     } else {
...
1497     }
...
1510     return ret;
1511 }
```

> block/io.c
``` c
 897 static int coroutine_fn bdrv_driver_pwritev(BlockDriverState *bs,
 898                                             uint64_t offset, uint64_t bytes,
 899                                             QEMUIOVector *qiov, int flags)
 900 {
 901     BlockDriver *drv = bs->drv;
 902     int64_t sector_num;
 903     unsigned int nb_sectors;
 904     int ret;
 905
 906     assert(!(flags & ~BDRV_REQ_MASK));
 907
 908     if (!drv) {
 909         return -ENOMEDIUM;
 910     }
 911
 912     if (drv->bdrv_co_pwritev) {
 913         ret = drv->bdrv_co_pwritev(bs, offset, bytes, qiov,
 914                                    flags & bs->supported_write_flags);
 915         flags &= ~bs->supported_write_flags;
 916         goto emulate_flags;
 917     }
 918
 919     sector_num = offset >> BDRV_SECTOR_BITS;
 920     nb_sectors = bytes >> BDRV_SECTOR_BITS;
 921
 922     assert((offset & (BDRV_SECTOR_SIZE - 1)) == 0);
 923     assert((bytes & (BDRV_SECTOR_SIZE - 1)) == 0);
 924     assert((bytes >> BDRV_SECTOR_BITS) <= BDRV_REQUEST_MAX_SECTORS);
 925
 926     if (drv->bdrv_co_writev_flags) {
 927         ret = drv->bdrv_co_writev_flags(bs, sector_num, nb_sectors, qiov,
 928                                         flags & bs->supported_write_flags);
 929         flags &= ~bs->supported_write_flags;
 930     } else if (drv->bdrv_co_writev) {
 931         assert(!bs->supported_write_flags);
 932         ret = drv->bdrv_co_writev(bs, sector_num, nb_sectors, qiov);
 933     } else {
 934         BlockAIOCB *acb;
 935         CoroutineIOCompletion co = {
 936             .coroutine = qemu_coroutine_self(),
 937         };
 938
 939         acb = bs->drv->bdrv_aio_writev(bs, sector_num, qiov, nb_sectors,
 940                                        bdrv_co_io_em_complete, &co);
 941         if (acb == NULL) {
 942             ret = -EIO;
 943         } else {
 944             qemu_coroutine_yield();
 945             ret = co.ret;
 946         }
 947     }
 ...
 950     if (ret == 0 && (flags & BDRV_REQ_FUA)) {
 951         ret = bdrv_co_flush(bs);  // flushするcolutinを返す
 952     }
 953
 954     return ret;
 955 }
```

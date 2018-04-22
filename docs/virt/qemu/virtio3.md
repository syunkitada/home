
> blockdev.c
```
 777 DriveInfo *drive_new(QemuOpts *all_opts, BlockInterfaceType block_default_type)
 778 {
 ...
 1090     /* Actual block device init: Functionality shared with blockdev-add */
 1091     blk = blockdev_init(filename, bs_opts, &local_err);
 ...
 1133     return dinfo;
 1134 }
```


```
 452 static BlockBackend *blockdev_init(const char *file, QDict *bs_opts,
 453                                    Error **errp)
 454 {
 455     const char *buf;
 456     int bdrv_flags = 0;
 457     int on_read_error, on_write_error;
 458     bool account_invalid, account_failed;
 459     bool writethrough, read_only;
 460     BlockBackend *blk;
 461     BlockDriverState *bs;
 462     ThrottleConfig cfg;
 463     int snapshot = 0;
 464     Error *error = NULL;
 465     QemuOpts *opts;
 466     QDict *interval_dict = NULL;
 467     QList *interval_list = NULL;
 468     const char *id;
 469     BlockdevDetectZeroesOptions detect_zeroes =
 470         BLOCKDEV_DETECT_ZEROES_OPTIONS_OFF;
 471     const char *throttling_group = NULL;
...
 611
 612     blk_set_enable_write_cache(blk, !writethrough);
 613     blk_set_on_error(blk, on_read_error, on_write_error);
 614
 615     if (!monitor_add_blk(blk, id, errp)) {
 616         blk_unref(blk);
 617         blk = NULL;
 618         goto err_no_bs_opts;
 619     }
 620
 621 err_no_bs_opts:
 622     qemu_opts_del(opts);
 623     QDECREF(interval_dict);
 624     QDECREF(interval_list);
 625     return blk;
 626
 627 early_err:
 628     qemu_opts_del(opts);
 629     QDECREF(interval_dict);
 630     QDECREF(interval_list);
 631 err_no_opts:
 632     QDECREF(bs_opts);
 633     return NULL;
 634 }
```



> block.c
```
 778 /**
 779  * Set open flags for a given cache mode
 780  *
 781  * Return 0 on success, -1 if the cache mode was invalid.
 782  */
 783 int bdrv_parse_cache_mode(const char *mode, int *flags, bool *writethrough)
 784 {
 785     *flags &= ~BDRV_O_CACHE_MASK;
 786
 787     if (!strcmp(mode, "off") || !strcmp(mode, "none")) {
 788         *writethrough = false;
 789         *flags |= BDRV_O_NOCACHE;
 790     } else if (!strcmp(mode, "directsync")) {
 791         *writethrough = true;
 792         *flags |= BDRV_O_NOCACHE;
 793     } else if (!strcmp(mode, "writeback")) {
 794         *writethrough = false;
 795     } else if (!strcmp(mode, "unsafe")) {
 796         *writethrough = false;
 797         *flags |= BDRV_O_NO_FLUSH;
 798     } else if (!strcmp(mode, "writethrough")) {
 799         *writethrough = true;
 800     } else {
 801         return -1;
 802     }
 803
 804     return 0;
 805 }
 ```



```
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


block/io.c
```
 618 static void coroutine_fn bdrv_rw_co_entry(void *opaque)
 619 {
 620     RwCo *rwco = opaque;
 621
 622     if (!rwco->is_write) {
 623         rwco->ret = bdrv_co_preadv(rwco->child, rwco->offset,
 624                                    rwco->qiov->size, rwco->qiov,
 625                                    rwco->flags);
 626     } else {
 627         rwco->ret = bdrv_co_pwritev(rwco->child, rwco->offset,
 628                                     rwco->qiov->size, rwco->qiov,
 629                                     rwco->flags);
 630     }
 631 }


1751 int coroutine_fn bdrv_co_writev(BdrvChild *child, int64_t sector_num,
1752     int nb_sectors, QEMUIOVector *qiov)
1753 {
1754     return bdrv_co_do_writev(child, sector_num, nb_sectors, qiov, 0);
1755 }

1739 static int coroutine_fn bdrv_co_do_writev(BdrvChild *child,
1740     int64_t sector_num, int nb_sectors, QEMUIOVector *qiov,
1741     BdrvRequestFlags flags)
1742 {
1743     if (nb_sectors < 0 || nb_sectors > BDRV_REQUEST_MAX_SECTORS) {
1744         return -EINVAL;
1745     }
1746
1747     return bdrv_co_pwritev(child, sector_num << BDRV_SECTOR_BITS,
1748                            nb_sectors << BDRV_SECTOR_BITS, qiov, flags);
1749 }


1602 /*
1603  * Handle a write request in coroutine context
1604  */
1605 int coroutine_fn bdrv_co_pwritev(BdrvChild *child,
1606     int64_t offset, unsigned int bytes, QEMUIOVector *qiov,
1607     BdrvRequestFlags flags)
1608 {
1722     ret = bdrv_aligned_pwritev(child, &req, offset, bytes, align,
1723                                use_local_qiov ? &local_qiov : qiov,
1724                                flags);
...
1735     bdrv_dec_in_flight(bs);
1736     return ret;
1737 }


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

# BlockDriver:QCOW2


## Contents
| Link | Description |
| --- | --- |
| [QCOW2について](#qcow2)                          | QCOW2について     |
| [BlockDriverの定義と登録](#blockdriver-register) | BlockDriverの定義 |
| [bdrv_co_writev](#bdrv_co_writev)                | write処理         |
| [bdrv_co_flush](#bdrv_co_flush)                  | flush処理         |


<a name="qcow2"></a>
## QCOW2について
* 公式を参照
    * https://github.com/qemu/qemu/blob/master/docs/interop/qcow2.txt
    * https://github.com/qemu/qemu/blob/master/docs/qcow2-cache.txt
        * L2-tablesについての課題と設定値について


<a name="blockdriver-register"></a>
## BlockDriverの定義
> block/qcow2.c
```
4346 BlockDriver bdrv_qcow2 = {
4347     .format_name        = "qcow2",
4348     .instance_size      = sizeof(BDRVQcow2State),
4349     .bdrv_probe         = qcow2_probe,
4350     .bdrv_open          = qcow2_open,
4351     .bdrv_close         = qcow2_close,
4352     .bdrv_reopen_prepare  = qcow2_reopen_prepare,
4353     .bdrv_reopen_commit   = qcow2_reopen_commit,
4354     .bdrv_reopen_abort    = qcow2_reopen_abort,
4355     .bdrv_join_options    = qcow2_join_options,
4356     .bdrv_child_perm      = bdrv_format_default_perms,
4357     .bdrv_create        = qcow2_create,
4358     .bdrv_has_zero_init = bdrv_has_zero_init_1,
4359     .bdrv_co_get_block_status = qcow2_co_get_block_status,
4360
4361     .bdrv_co_preadv         = qcow2_co_preadv,
4362     .bdrv_co_pwritev        = qcow2_co_pwritev,
4363     .bdrv_co_flush_to_os    = qcow2_co_flush_to_os,
4364
4365     .bdrv_co_pwrite_zeroes  = qcow2_co_pwrite_zeroes,
4366     .bdrv_co_pdiscard       = qcow2_co_pdiscard,
4367     .bdrv_truncate          = qcow2_truncate,
4368     .bdrv_co_pwritev_compressed = qcow2_co_pwritev_compressed,
4369     .bdrv_make_empty        = qcow2_make_empty,
4370
4371     .bdrv_snapshot_create   = qcow2_snapshot_create,
4372     .bdrv_snapshot_goto     = qcow2_snapshot_goto,
4373     .bdrv_snapshot_delete   = qcow2_snapshot_delete,
4374     .bdrv_snapshot_list     = qcow2_snapshot_list,
4375     .bdrv_snapshot_load_tmp = qcow2_snapshot_load_tmp,
4376     .bdrv_measure           = qcow2_measure,
4377     .bdrv_get_info          = qcow2_get_info,
4378     .bdrv_get_specific_info = qcow2_get_specific_info,
4379
4380     .bdrv_save_vmstate    = qcow2_save_vmstate,
4381     .bdrv_load_vmstate    = qcow2_load_vmstate,
4382
4383     .supports_backing           = true,
4384     .bdrv_change_backing_file   = qcow2_change_backing_file,
4385
4386     .bdrv_refresh_limits        = qcow2_refresh_limits,
4387     .bdrv_invalidate_cache      = qcow2_invalidate_cache,
4388     .bdrv_inactivate            = qcow2_inactivate,
4389
4390     .create_opts         = &qcow2_create_opts,
4391     .bdrv_check          = qcow2_check,
4392     .bdrv_amend_options  = qcow2_amend_options,
4393
4394     .bdrv_detach_aio_context  = qcow2_detach_aio_context,
4395     .bdrv_attach_aio_context  = qcow2_attach_aio_context,
4396
4397     .bdrv_reopen_bitmaps_rw = qcow2_reopen_bitmaps_rw,
4398     .bdrv_can_store_new_dirty_bitmap = qcow2_can_store_new_dirty_bitmap,
4399     .bdrv_remove_persistent_dirty_bitmap = qcow2_remove_persistent_dirty_bitmap,
4400 };
4401
4402 static void bdrv_qcow2_init(void)
4403 {
4404     bdrv_register(&bdrv_qcow2);
4405 }
4406
4407 block_init(bdrv_qcow2_init);
```


## bdrv_co_writev
> block/qcow2.c
```
1897 static coroutine_fn int qcow2_co_pwritev(BlockDriverState *bs, uint64_t offset,
1898                                          uint64_t bytes, QEMUIOVector *qiov,
1899                                          int flags)
1900 {
1901     BDRVQcow2State *s = bs->opaque;
1902     int offset_in_cluster;
1903     int ret;
1904     unsigned int cur_bytes; /* number of sectors in current iteration */
1905     uint64_t cluster_offset;
1906     QEMUIOVector hd_qiov;
1907     uint64_t bytes_done = 0;
1908     uint8_t *cluster_data = NULL;
1909     QCowL2Meta *l2meta = NULL;
1910
1911     trace_qcow2_writev_start_req(qemu_coroutine_self(), offset, bytes);
1912
1913     qemu_iovec_init(&hd_qiov, qiov->niov);
1914
1915     s->cluster_cache_offset = -1; /* disable compressed cache */
1916
1917     qemu_co_mutex_lock(&s->lock);
1918
1919     while (bytes != 0) {
...

2038     qemu_co_mutex_unlock(&s->lock);
2039
2040     qemu_iovec_destroy(&hd_qiov);
2041     qemu_vfree(cluster_data);
2042     trace_qcow2_writev_done_req(qemu_coroutine_self(), ret);
2043
2044     return ret;
2045 }
```


## bdrv_co_flush
> block/qcow2.c
```
3645 static coroutine_fn int qcow2_co_flush_to_os(BlockDriverState *bs)
3646 {
3647     BDRVQcow2State *s = bs->opaque;
3648     int ret;
3649
3650     qemu_co_mutex_lock(&s->lock);
3651     ret = qcow2_cache_write(bs, s->l2_table_cache);
3652     if (ret < 0) {
3653         qemu_co_mutex_unlock(&s->lock);
3654         return ret;
3655     }
3656
3657     if (qcow2_need_accurate_refcounts(s)) {
3658         ret = qcow2_cache_write(bs, s->refcount_block_cache);
3659         if (ret < 0) {
3660             qemu_co_mutex_unlock(&s->lock);
3661             return ret;
3662         }
3663     }
3664     qemu_co_mutex_unlock(&s->lock);
3665
3666     return 0;
3667 }
```

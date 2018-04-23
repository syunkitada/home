# virtio-blkのrealize


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


## realize処理
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

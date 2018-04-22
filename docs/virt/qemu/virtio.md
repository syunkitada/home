
```
 79 void virtio_blk_data_plane_create(VirtIODevice *vdev, VirtIOBlkConf *conf,
 80                                   VirtIOBlockDataPlane **dataplane,
 81                                   Error **errp)
 82 {
 83     VirtIOBlockDataPlane *s;
 84     BusState *qbus = BUS(qdev_get_parent_bus(DEVICE(vdev)));
 85     VirtioBusClass *k = VIRTIO_BUS_GET_CLASS(qbus);
 86
 87     *dataplane = NULL;
 ...
114     s = g_new0(VirtIOBlockDataPlane, 1);
115     s->vdev = vdev;
116     s->conf = conf;
117
118     if (conf->iothread) {
119         s->iothread = conf->iothread;
120         object_ref(OBJECT(s->iothread));
121         s->ctx = iothread_get_aio_context(s->iothread);
122     } else {
123         s->ctx = qemu_get_aio_context();
124     }
125     s->bh = aio_bh_new(s->ctx, notify_guest_bh, s);
126     s->batch_notify_vqs = bitmap_new(conf->num_queues);
127
128     *dataplane = s;
129 }
```




```
2664 static void virtio_device_class_init(ObjectClass *klass, void *data)
2665 {
2666     /* Set the default value here. */
2667     VirtioDeviceClass *vdc = VIRTIO_DEVICE_CLASS(klass);
2668     DeviceClass *dc = DEVICE_CLASS(klass);
2669
2670     dc->realize = virtio_device_realize;
2671     dc->unrealize = virtio_device_unrealize;
2672     dc->bus_type = TYPE_VIRTIO_BUS;
2673     dc->props = virtio_properties;
2674     vdc->start_ioeventfd = virtio_device_start_ioeventfd_impl;
2675     vdc->stop_ioeventfd = virtio_device_stop_ioeventfd_impl;
2676
2677     vdc->legacy_features |= VIRTIO_LEGACY_FEATURES;
2678 }
2679
2680 bool virtio_device_ioeventfd_enabled(VirtIODevice *vdev)
2681 {
2682     BusState *qbus = qdev_get_parent_bus(DEVICE(vdev));
2683     VirtioBusState *vbus = VIRTIO_BUS(qbus);
2684
2685     return virtio_bus_ioeventfd_enabled(vbus);
2686 }
2687
2688 static const TypeInfo virtio_device_info = {
2689     .name = TYPE_VIRTIO_DEVICE,
2690     .parent = TYPE_DEVICE,
2691     .instance_size = sizeof(VirtIODevice),
2692     .class_init = virtio_device_class_init,
2693     .instance_finalize = virtio_device_instance_finalize,
2694     .abstract = true,
2695     .class_size = sizeof(VirtioDeviceClass),
2696 };
2697
2698 static void virtio_register_types(void)
2699 {
2700     type_register_static(&virtio_device_info);
2701 }
2702
2703 type_init(virtio_register_types)
```


```
2492 static void virtio_device_realize(DeviceState *dev, Error **errp)
2493 {
2494     VirtIODevice *vdev = VIRTIO_DEVICE(dev);
2495     VirtioDeviceClass *vdc = VIRTIO_DEVICE_GET_CLASS(dev);
2496     Error *err = NULL;
2497
2498     /* Devices should either use vmsd or the load/save methods */
2499     assert(!vdc->vmsd || !vdc->load);
2500
2501     if (vdc->realize != NULL) {
2502         vdc->realize(dev, &err);
2503         if (err != NULL) {
2504             error_propagate(errp, err);
2505             return;
2506         }
2507     }
2508
2509     virtio_bus_device_plugged(vdev, &err);
2510     if (err != NULL) {
2511         error_propagate(errp, err);
2512         vdc->unrealize(dev, NULL);
2513         return;
2514     }
2515
2516     vdev->listener.commit = virtio_memory_listener_commit;
2517     memory_listener_register(&vdev->listener, vdev->dma_as);
2518 }
```


```
2572 static int virtio_device_start_ioeventfd_impl(VirtIODevice *vdev)
2573 {
2574     VirtioBusState *qbus = VIRTIO_BUS(qdev_get_parent_bus(DEVICE(vdev)));
2575     int n, r, err;
2576
2577     for (n = 0; n < VIRTIO_QUEUE_MAX; n++) {
2578         VirtQueue *vq = &vdev->vq[n];
2579         if (!virtio_queue_get_num(vdev, n)) {
2580             continue;
2581         }
2582         r = virtio_bus_set_host_notifier(qbus, n, true);
2583         if (r < 0) {
2584             err = r;
2585             goto assign_error;
2586         }
2587         event_notifier_set_handler(&vq->host_notifier,
2588                                    virtio_queue_host_notifier_read);
2589     }
2590
2591     for (n = 0; n < VIRTIO_QUEUE_MAX; n++) {
2592         /* Kick right away to begin processing requests already in vring */
2593         VirtQueue *vq = &vdev->vq[n];
2594         if (!vq->vring.num) {
2595             continue;
2596         }
2597         event_notifier_set(&vq->host_notifier);
2598     }
2599     return 0;
...
2613 }
```

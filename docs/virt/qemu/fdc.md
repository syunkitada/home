# fdc


## TypeInfoの登録
* いつものように、type_initでfdcのTypeInfoを登録する
* 初期化処理は、sysbus_fsc_common_initfnで行う
> hw/block/fdc.c
```
2740 static void sysbus_fdc_common_initfn(Object *obj)
2741 {
2742     DeviceState *dev = DEVICE(obj);
2743     SysBusDevice *sbd = SYS_BUS_DEVICE(dev);
2744     FDCtrlSysBus *sys = SYSBUS_FDC(obj);
2745     FDCtrl *fdctrl = &sys->state;
2746
2747     qdev_set_legacy_instance_id(dev, 0 /* io */, 2); /* FIXME */
2748
2749     sysbus_init_irq(sbd, &fdctrl->irq);
2750     qdev_init_gpio_in(dev, fdctrl_handle_tc, 1);
2751 }

2928 static const TypeInfo sysbus_fdc_type_info = {
2929     .name          = TYPE_SYSBUS_FDC,
2930     .parent        = TYPE_SYS_BUS_DEVICE,
2931     .instance_size = sizeof(FDCtrlSysBus),
2932     .instance_init = sysbus_fdc_common_initfn,
2933     .abstract      = true,
2934     .class_init    = sysbus_fdc_common_class_init,
2935 };
2936
2937 static void fdc_register_types(void)
2938 {
...
2940     type_register_static(&sysbus_fdc_type_info);
...
2945 }
2946
2947 type_init(fdc_register_types)
```


```
 987 static const MemoryRegionOps fdctrl_mem_ops = {
 988     .read = fdctrl_read_mem,
 989     .write = fdctrl_write_mem,
 990     .endianness = DEVICE_NATIVE_ENDIAN,
 991 };
 992
 993 static const MemoryRegionOps fdctrl_mem_strict_ops = {
 994     .read = fdctrl_read_mem,
 995     .write = fdctrl_write_mem,
 996     .endianness = DEVICE_NATIVE_ENDIAN,
 997     .valid = {
 998         .min_access_size = 1,
 999         .max_access_size = 1,
1000     },
1001 };
```

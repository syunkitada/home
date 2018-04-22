# IOエミュレーション


## kvm-all
* MMIOなどが発生するとそれをハンドルするためにVM_EXITされる
* QEMUでは、VM_EXITの理由から、適切なエミュレーションを行う

> kvm-all.c
``` c
1923         switch (run->exit_reason) {
1924         case KVM_EXIT_IO:
1925             DPRINTF("handle_io\n");
1926             /* Called outside BQL */
1927             kvm_handle_io(run->io.port, attrs,
1928                           (uint8_t *)run + run->io.data_offset,
1929                           run->io.direction,
1930                           run->io.size,
1931                           run->io.count);
1932             ret = 0;
1933             break;
1934         case KVM_EXIT_MMIO:
1935             DPRINTF("handle_mmio\n");
1936             /* Called outside BQL */
1937             address_space_rw(&address_space_memory,
1938                              run->mmio.phys_addr, attrs,
1939                              run->mmio.data,
1940                              run->mmio.len,
1941                              run->mmio.is_write);
1942             ret = 0;
1943             break;
```

* portio、mmioともに、address_space_rwで、QEMUのaddress_spaceに読み書きを行う
    * 指定されたアドレスに登録されているデバイスを使って読み書きが行われる
> kvm-all.c
``` c
1680 static void kvm_handle_io(uint16_t port, MemTxAttrs attrs, void *data, int direction,
1681                           int size, uint32_t count)
1682 {
1683     int i;
1684     uint8_t *ptr = data;
1685
1686     for (i = 0; i < count; i++) {
1687         address_space_rw(&address_space_io, port, attrs,
1688                          ptr, size,
1689                          direction == KVM_EXIT_IO_OUT);
1690         ptr += size;
1691     }
1692 }
```

* address_space_rwは、address_spaceをFlatViewに変換し、flatview_rwを行う
> exec.c
``` c
3125 static MemTxResult flatview_rw(FlatView *fv, hwaddr addr, MemTxAttrs attrs,
3126                                uint8_t *buf, int len, bool is_write)
3127 {
3128     if (is_write) {
3129         return flatview_write(fv, addr, attrs, (uint8_t *)buf, len);
3130     } else {
3131         return flatview_read(fv, addr, attrs, (uint8_t *)buf, len);
3132     }
3133 }
3134
3135 MemTxResult address_space_rw(AddressSpace *as, hwaddr addr,
3136                              MemTxAttrs attrs, uint8_t *buf,
3137                              int len, bool is_write)
3138 {
3139     return flatview_rw(address_space_to_flatview(as),
3140                        addr, attrs, buf, len, is_write);
3141 }
```

* flatview_writeは、flatview_trancelateでFlatViewからMemoryRegionを取得
* flatview_write_continueで、write処理に入る
```
3008 static MemTxResult flatview_write(FlatView *fv, hwaddr addr, MemTxAttrs attrs,
3009                                   const uint8_t *buf, int len)
3010 {
3011     hwaddr l;
3012     hwaddr addr1;
3013     MemoryRegion *mr;
3014     MemTxResult result = MEMTX_OK;
3015
3016     if (len > 0) {
3017         rcu_read_lock();
3018         l = len;
3019         mr = flatview_translate(fv, addr, &addr1, &l, true);
3020         result = flatview_write_continue(fv, addr, attrs, buf, len,
3021                                          addr1, l, mr);
3022         rcu_read_unlock();
3023     }
3024
3025     return result;
3026 }
```

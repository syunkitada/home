# Memory


## Contents
| Link | Description |
| --- | --- |
| [MemoryAPI](#memoryapi)             | MemoryAPIについて |
| [MemoryRegionOps](#memoryregionops) | Ram、MMIOのMemoryRegionにおいて、読み書きを行うためのインターフェイス |
| [KVMにおけるPIO、MMIO](#kvm-io)     | KVMのIOについて |


## MemoryAPI
* Memoryは、MemoryRegionオブジェクトの非循環グラフ(閉路のない有向グラフ)でモデリングされる
    * シンク(リーフノード)は、RAM Region、MMIO Regionで、他のノードはバス、メモリコントローラ、及び再ルーティングされたMemoryRegionを表す
* MemoryAPIは、すべてのルートMemoryRegion、中間MemoryRegionsのためのAddressApaceを提供する
    * これらは、CPUやデバイスのviewpointから見えるメモリとして表される
* MemoryRegionには以下のタイプがある
    * RAM、MMIO、ROM、ROM device、IOMMU region、container、alias、reservation region
* MemoryRegionは、AddressSpaceのrootか、あるRegion(container)のsubregionとして属する
* デバイスについて
    * PIO、MMIOを行うデバイスはMemoryRegionとして登録し、VMはメモリアドレスでデバイスにアクセスして読み書きを行う

* Guestがメモリにアクセスしたとき、以下のルールでメモリを選択する
    * root Regionのすべての直接的なSubRegionは、そのアドレスに対して照合される
        * そのアドレスがそのSubRegionのオフセットサイズ外にある場合、そのSubRegionは破棄されている
        * そのSubRegionがleaf(RAM or MMIO)なら、その検索は終了し、leaf Regionを返す
        * そのSubRegionがContainerなら、(そのアドレスがSubRegionのOffsetによって調整された後に)再帰的に同じアルゴリズムで探索する
        * そのSubRegionがAliasなら、(そのアドレスがSubRegionのOffsetによって調整された後に)その検索はAliasをターゲットとして再帰的に続けられる
        * ContainerやAlias Subregionにおいて再帰的な検索でマッチしない場合(Containerのカバレッジのholeのため)、
            * もしこれが、CotainerやRAMバッキングを持つContainerである場合、検索を終了し、Conteiner自体を返す
            * そうでなければ、優先順位にしたがって次のSubRegionの検索を続ける
    * SubRegionがそのアドレスに一致しない場合は、no match foundとして検索を終了する


## MemoryRegionOps
* Ram、MMIOのMemoryRegionへ読み書きを行う時に利用するインターフェイス
> memory.c
```
  1312 static uint64_t memory_region_ram_device_read(void *opaque,
  1313                                               hwaddr addr, unsigned size)
  1314 {
  1315     MemoryRegion *mr = opaque;
  1316     uint64_t data = (uint64_t)~0;
  1317
  1318     switch (size) {
  1319     case 1:
  1320         data = *(uint8_t *)(mr->ram_block->host + addr);
  1321         break;
  1322     case 2:
  1323         data = *(uint16_t *)(mr->ram_block->host + addr);
  1324         break;
  1325     case 4:
  1326         data = *(uint32_t *)(mr->ram_block->host + addr);
  1327         break;
  1328     case 8:
  1329         data = *(uint64_t *)(mr->ram_block->host + addr);
  1330         break;
  1331     }
  1332
  1333     trace_memory_region_ram_device_read(get_cpu_index(), mr, addr, data, size);
  1334
  1335     return data;
  1336 }
  1337
  1338 static void memory_region_ram_device_write(void *opaque, hwaddr addr,
  1339                                            uint64_t data, unsigned size)
  1340 {
  1341     MemoryRegion *mr = opaque;
  1342
  1343     trace_memory_region_ram_device_write(get_cpu_index(), mr, addr, data, size);
  1344
  1345     switch (size) {
  1346     case 1:
  1347         *(uint8_t *)(mr->ram_block->host + addr) = (uint8_t)data;
  1348         break;
  1349     case 2:
  1350         *(uint16_t *)(mr->ram_block->host + addr) = (uint16_t)data;
  1351         break;
  1352     case 4:
  1353         *(uint32_t *)(mr->ram_block->host + addr) = (uint32_t)data;
  1354         break;
  1355     case 8:
  1356         *(uint64_t *)(mr->ram_block->host + addr) = data;
  1357         break;
  1358     }
  1359 }
  1360
  1361 static const MemoryRegionOps ram_device_mem_ops = {
  1362     .read = memory_region_ram_device_read,
  1363     .write = memory_region_ram_device_write,
  1364     .endianness = DEVICE_HOST_ENDIAN,
  1365     .valid = {
  1366         .min_access_size = 1,
  1367         .max_access_size = 8,
  1368         .unaligned = true,
  1369     },
  1370     .impl = {
  1371         .min_access_size = 1,
  1372         .max_access_size = 8,
  1373         .unaligned = true,
  1374     },
  1375 };
```


## kvmにおけるPIO、MMIO
* PIO(Port I/O)、MMIO(Memory-Mapped I/O)などが発生するとそれをハンドルするためにVM_EXITされる
* QEMUでは、VM_EXITの理由から、適切なエミュレーションを行う
* virtioによるIOでは、この仕組とはまた別なので注意(VM_EXITしない)

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

* PIO、MMIOともに、address_space_rwで、QEMUのaddress_spaceに読み書きを行う
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
* flatview_write_continueで、MemoryRegionに設定されたMMIOデバイスを利用してwrite処理に入る
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

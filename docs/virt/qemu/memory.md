# MemoryAPI(memory.c)
* MemoryAPIは、メモリ、I/O bus、QEMU Machineのコントローラの機能を提供する
    * 基本的なRAM
    * kvmのためのcoalesce memory(結合メモリ)のセットアップ
    * kvmのためのioeventfd regionのセットアップ
* Memoryは、MemoryRegionオブジェクトの非循環グラフ(閉路のない有向グラフ)でモデリングされる
    * シンク(リーフノード)は、RAM Region、MMIO Regionで、他のノードはバス、メモリコントローラ、及び再ルーティングされたMemoryRegionを表す
* MemoryAPIは、すべてのルートMemoryRegion、中間MemoryRegionsのためのAddressApaceを提供する
    * これらは、CPUやデバイスのviewpointから見えるメモリとして表される
* MemoryRegionには以下のタイプがある
    * RAM


作成されたMemoryRegionは、AddressSpaceかContainerに追加される
memory_region_add_subregion

owner objectが死んだ時に、MemoryRegionもなくなる



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

```
Example memory map
------------------

system_memory: container@0-2^48-1
 |
 +---- lomem: alias@0-0xdfffffff ---> #ram (0-0xdfffffff)
 |
 +---- himem: alias@0x100000000-0x11fffffff ---> #ram (0xe0000000-0xffffffff)
 |
 +---- vga-window: alias@0xa0000-0xbffff ---> #pci (0xa0000-0xbffff)
 |      (prio 1)
 |
 +---- pci-hole: alias@0xe0000000-0xffffffff ---> #pci (0xe0000000-0xffffffff)

pci (0-2^32-1)
 |
 +--- vga-area: container@0xa0000-0xbffff
 |      |
 |      +--- alias@0x00000-0x7fff  ---> #vram (0x010000-0x017fff)
 |      |
 |      +--- alias@0x08000-0xffff  ---> #vram (0x020000-0x027fff)
 |
 +---- vram: ram@0xe1000000-0xe1ffffff
 |
 +---- vga-mmio: mmio@0xe2000000-0xe200ffff
```




## Memory data structures
* AddressSpaceが、全メモリの管理単位
    * システム用のaddress_spaceと、ioポート用のaddress_spaceの2つが定義されている

> memory.c
```
 85 static MemoryRegion *system_memory;
 86 static MemoryRegion *system_io;
 87
 88 AddressSpace address_space_io;
 89 AddressSpace address_space_memory;
```

> include/exec/memory.h
```
 306 struct AddressSpace {
 307     /* All fields are private. */
 308     struct rcu_head rcu;
 309     char *name;
 310     MemoryRegion *root;
 311
 312     /* Accessed via RCU.  */
 313     struct FlatView *current_map;
 314
 315     int ioeventfd_nb;
 316     struct MemoryRegionIoeventfd *ioeventfds;
 317     QTAILQ_HEAD(memory_listeners_as, MemoryListener) listeners;
 318     QTAILQ_ENTRY(AddressSpace) address_spaces_link;
 319 };
```

* QEMUでは、メモリ空間のアドレスをアドレスをキーとしたradix treeとして管理している
    * linuxと同じ
* MemoryRegionSectionがキーを表すノード
* MemoryRegionが中間ノード
    * MemoryRegionが、アクセス先のaddrを持っている

> include/exec/memory.h
``` c
 334 struct MemoryRegionSection {
 335     MemoryRegion *mr;
 336     FlatView *fv;
 337     hwaddr offset_within_region;
 338     Int128 size;
 339     hwaddr offset_within_address_space;
 340     bool readonly;
 341 };
```

> memory.c
```
 218 struct MemoryRegion {
 219     Object parent_obj;
 220
 221     /* All fields are private - violators will be prosecuted */
 222
 223     /* The following fields should fit in a cache line */
 224     bool romd_mode;
 225     bool ram;
 226     bool subpage;
 227     bool readonly; /* For RAM regions */
 228     bool rom_device;
 229     bool flush_coalesced_mmio;
 230     bool global_locking;
 231     uint8_t dirty_log_mask;
 232     bool is_iommu;
 233     RAMBlock *ram_block;
 234     Object *owner;
 233     RAMBlock *ram_block;
 234     Object *owner;
 235
 236     const MemoryRegionOps *ops;
 237     void *opaque;
 238     MemoryRegion *container;
 239     Int128 size;
 240     hwaddr addr;
 241     void (*destructor)(MemoryRegion *mr);
 242     uint64_t align;
 243     bool terminates;
 244     bool ram_device;
 245     bool enabled;
 246     bool warning_printed; /* For reservations */
 247     uint8_t vga_logging_count;
 248     MemoryRegion *alias;
 249     hwaddr alias_offset;
 250     int32_t priority;
 251     QTAILQ_HEAD(subregions, MemoryRegion) subregions;
 252     QTAILQ_ENTRY(MemoryRegion) subregions_link;
 253     QTAILQ_HEAD(coalesced_ranges, CoalescedMemoryRange) coalesced;
 254     const char *name;
 255     unsigned ioeventfd_nb;
 256     MemoryRegionIoeventfd *ioeventfds;
 257 };
```

* AddressSpaceDispatchがradix treeの実体
> exec.c
``` c
 174 typedef PhysPageEntry Node[P_L2_SIZE];
 175
 176 typedef struct PhysPageMap {
 177     struct rcu_head rcu;
 178
 179     unsigned sections_nb;
 180     unsigned sections_nb_alloc;
 181     unsigned nodes_nb;
 182     unsigned nodes_nb_alloc;
 183     Node *nodes;
 184     MemoryRegionSection *sections;
 185 } PhysPageMap;
 186
 187 struct AddressSpaceDispatch {
 188     MemoryRegionSection *mru_section;
 189     /* This is a multi-level map on the physical address space.
 190      * The bottom level has pointers to MemoryRegionSections.
 191      */
 192     PhysPageEntry phys_map;
 193     PhysPageMap map;
 194 };
```


## MemoryRegionOps
* MemoryRegionに登録したデバイスへ読み書きを行う時に利用するインターフェイス
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



# AddressSpaceの初期化


## Contents
| Link | Description |
| --- | --- |
| [AddressSpaceの初期化](#starting-point-address-space-init)          | main関数が定義されてるファイル   |
| [PIO用のMemoryRegionの初期化](#io-mem-init)                         | PIO用のMemoryRegionの初期化処理  |
| [AddressSpaceの初期化](address-space-init)                          | AddressSpaceの初期化処理         |
| [address_space_update_topology](#address_space_update_topology)     | AddressSpaceのトポロジを初期化   |
| [address_space_update_ioeventfds](#address_space_update_ioeventfds) | AddressSpaceのioeventfdsを初期化 |


<a name="starting-point-address-space-init"></a>
## AddressSpaceの初期化処理の起点
* systemのAddressSpaceの初期化は、main関数内のcpu_exec_init_all()で行われる
> vl.c
```
3091 int main(int argc, char **argv, char **envp)
3092 {
...
4276     cpu_exec_init_all();
...
```

* cpu_exec_init_allで、PIO用のMemoryRegionの初期化、AdressSpaceの初期化を行う
> exec.c
```
3263 void cpu_exec_init_all(void)
3264 {
3265     qemu_mutex_init(&ram_list.mutex);
...
3273     finalize_target_page_bits();
3274     io_mem_init();
3275     memory_map_init();
3276     qemu_mutex_init(&map_client_list_lock);
3277 }
```


## PIO用のMemoryRegionの初期化
* io_mem_rom, io_mem_unassigned, io_mem_notdirty, io_mem_watchをPIO用のMemoryRegionとして初期化する
> exec.c
```
91   MemoryRegion io_mem_rom, io_mem_notdirty;
92   static MemoryRegion io_mem_unassigned;
213  static MemoryRegion io_mem_watch;

2733 static void io_mem_init(void)
2734 {
2735     memory_region_init_io(&io_mem_rom, NULL, &unassigned_mem_ops, NULL, NULL, UINT64_MAX);
2736     memory_region_init_io(&io_mem_unassigned, NULL, &unassigned_mem_ops, NULL,
2737                           NULL, UINT64_MAX);
...
2742     memory_region_init_io(&io_mem_notdirty, NULL, &notdirty_mem_ops, NULL,
2743                           NULL, UINT64_MAX);
2744     memory_region_clear_global_locking(&io_mem_notdirty);
2745
2746     memory_region_init_io(&io_mem_watch, NULL, &watch_mem_ops, NULL,
2747                           NULL, UINT64_MAX);
2748 }
```

> memory.c
```
1523 void memory_region_init_io(MemoryRegion *mr,
1524                            Object *owner,
1525                            const MemoryRegionOps *ops,
1526                            void *opaque,
1527                            const char *name,
1528                            uint64_t size)
1529 {
1530     memory_region_init(mr, owner, name, size);
1531     mr->ops = ops ? ops : &unassigned_mem_ops;
1532     mr->opaque = opaque;
1533     mr->terminates = true;
1534 }
```


## AddressSpaceの初期化
* system用のメモリ(system_memory)をmallocして、MemoryRegionとして初期化し、これをrootにしてAddressSpaceを作成する
* system_io用のメモリ(system_io)をmallocして、PIO用のMemoryRegionとして初期化し、これをrootにしてAddressSpaceを作成する
> exec.c
```
  85 static MemoryRegion *system_memory;
  86 static MemoryRegion *system_io;
  87
  88 AddressSpace address_space_io;
  89 AddressSpace address_space_memory;

2793 static void memory_map_init(void)
2794 {
2795     system_memory = g_malloc(sizeof(*system_memory));
2796
2797     memory_region_init(system_memory, NULL, "system", UINT64_MAX);
2798     address_space_init(&address_space_memory, system_memory, "memory");
2799
2800     system_io = g_malloc(sizeof(*system_io));
2801     memory_region_init_io(system_io, NULL, &unassigned_io_ops, NULL, "io",
2802                           65536);
2803     address_space_init(&address_space_io, system_io, "I/O");
2804 }
```

> memory.c
```
  2772 void address_space_init(AddressSpace *as, MemoryRegion *root, const char *name)
  2773 {
  2774     memory_region_ref(root);
  2775     as->root = root;
  2776     as->current_map = NULL;
  2777     as->ioeventfd_nb = 0;
  2778     as->ioeventfds = NULL;
  2779     QTAILQ_INIT(&as->listeners);
  2780     QTAILQ_INSERT_TAIL(&address_spaces, as, address_spaces_link);
  2781     as->name = g_strdup(name ? name : "anonymous");
  2782     address_space_update_topology(as);
  2783     address_space_update_ioeventfds(as);
  2784 }
```


## address_space_update_topology
* flat_views(FlatTableのGHashTable)を初期化
* AddressSpaceのTopologyを作成
> memory.c
```
   50 static GHashTable *flat_views;

   971 static void flatviews_init(void)
   972 {
   973     static FlatView *empty_view;
   974
   975     if (flat_views) {
   976         return;
   977     }
   978
   979     flat_views = g_hash_table_new_full(g_direct_hash, g_direct_equal, NULL,
   980                                        (GDestroyNotify) flatview_unref);
   981     if (!empty_view) {
   982         empty_view = generate_memory_topology(NULL);
   983         /* We keep it alive forever in the global variable.  */
   984         flatview_ref(empty_view);
   985     } else {
   986         g_hash_table_replace(flat_views, NULL, empty_view);
   987         flatview_ref(empty_view);
   988     }
   989 }
  ...
  1058 static void address_space_update_topology(AddressSpace *as)
  1059 {
  1060     MemoryRegion *physmr = memory_region_get_flatview_root(as->root);
  1061
  1062     flatviews_init();
  1063     if (!g_hash_table_lookup(flat_views, physmr)) {
  1064         generate_memory_topology(physmr);
  1065     }
  1066     address_space_set_flatview(as);
  1067 }
```

* MemoryRegionのTopologyを作成する
* MemoryRegionからFlatViewを作成し、render_memory_regionで、MemoryRegionをFlatViewにレンダリングする
* viewのnrに登録されたdispatchの初期化もここで行う?
> memory.c
```
   780 /* Render a memory topology into a list of disjoint absolute ranges. */
   781 static FlatView *generate_memory_topology(MemoryRegion *mr)
   782 {
   783     int i;
   784     FlatView *view;
   785
   786     view = flatview_new(mr);
   787
   788     if (mr) {
   789         render_memory_region(view, mr, int128_zero(),
   790                              addrrange_make(int128_zero(), int128_2_64()), false);
   791     }
   792     flatview_simplify(view);
   793
   794     view->dispatch = address_space_dispatch_new(view);
   795     for (i = 0; i < view->nr; i++) {
   796         MemoryRegionSection mrs =
   797             section_from_flat_range(&view->ranges[i], view);
   798         flatview_add_to_dispatch(view, &mrs);
   799     }
   800     address_space_dispatch_compact(view->dispatch);
   801     g_hash_table_replace(flat_views, mr, view);
   802
   803     return view;
   804 }
```


## address_space_update_ioeventfds(as)
* AddressSpaceからFlatViewを取得
* FlatViewを探索し、MemoryRegionのioeventfdを利用する場合は、address_space_add_del_ioeventfdsを実行
    * このなかでMemoryのListenerのeventfd_addを行う
```
   870 static void address_space_update_ioeventfds(AddressSpace *as)
   871 {
   872     FlatView *view;
   873     FlatRange *fr;
   874     unsigned ioeventfd_nb = 0;
   875     MemoryRegionIoeventfd *ioeventfds = NULL;
   876     AddrRange tmp;
   877     unsigned i;
   878
   879     view = address_space_get_flatview(as);
   880     FOR_EACH_FLAT_RANGE(fr, view) {
   881         for (i = 0; i < fr->mr->ioeventfd_nb; ++i) {
   882             tmp = addrrange_shift(fr->mr->ioeventfds[i].addr,
   883                                   int128_sub(fr->addr.start,
   884                                              int128_make64(fr->offset_in_region)));
   885             if (addrrange_intersects(fr->addr, tmp)) {
   886                 ++ioeventfd_nb;
   887                 ioeventfds = g_realloc(ioeventfds,
   888                                           ioeventfd_nb * sizeof(*ioeventfds));
   889                 ioeventfds[ioeventfd_nb-1] = fr->mr->ioeventfds[i];
   890                 ioeventfds[ioeventfd_nb-1].addr = tmp;
   891             }
   892         }
   893     }
   894
   895     address_space_add_del_ioeventfds(as, ioeventfds, ioeventfd_nb,
   896                                      as->ioeventfds, as->ioeventfd_nb);
   897
   898     g_free(as->ioeventfds);
   899     as->ioeventfds = ioeventfds;
   900     as->ioeventfd_nb = ioeventfd_nb;
   901     flatview_unref(view);
   902 }
```

```
 806 static void address_space_add_del_ioeventfds(AddressSpace *as,
 807                                              MemoryRegionIoeventfd *fds_new,
 808                                              unsigned fds_new_nb,
 809                                              MemoryRegionIoeventfd *fds_old,
 810                                              unsigned fds_old_nb)
 811 {
 820     iold = inew = 0;
 821     while (iold < fds_old_nb || inew < fds_new_nb) {
 822         if (iold < fds_old_nb
 ...
 835         } else if (inew < fds_new_nb
 836                    && (iold == fds_old_nb
 837                        || memory_region_ioeventfd_before(fds_new[inew],
 838                                                          fds_old[iold]))) {
 ...
 845             MEMORY_LISTENER_CALL(as, eventfd_add, Reverse, &section,
 846                                  fd->match_data, fd->data, fd->e);
 847             ++inew;
 848         } else {
 849             ++iold;
 850             ++inew;
 851         }
 852     }
 853 }
```

```
 130 #define MEMORY_LISTENER_CALL(_as, _callback, _direction, _section, _args...) \
 131     do {                                                                \
 132         MemoryListener *_listener;                                      \
 133         struct memory_listeners_as *list = &(_as)->listeners;           \
 134                                                                         \
 135         switch (_direction) {                                           \
 136         case Forward:                                                   \
 137             QTAILQ_FOREACH(_listener, list, link_as) {                  \
 138                 if (_listener->_callback) {                             \
 139                     _listener->_callback(_listener, _section, ##_args); \
 140                 }                                                       \
 141             }                                                           \
 142             break;                                                      \
 143         case Reverse:                                                   \
 144             QTAILQ_FOREACH_REVERSE(_listener, list, memory_listeners_as, \
 145                                    link_as) {                           \
 146                 if (_listener->_callback) {                             \
 147                     _listener->_callback(_listener, _section, ##_args); \
 148                 }                                                       \
 149             }                                                           \
 150             break;                                                      \
 151         default:                                                        \
 152             abort();                                                    \
 153         }                                                               \
 154     } while (0)
```

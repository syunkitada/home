# kvm-all eventfd
* eventfdを利用して、VM_EXITせずにPIO/MMIOをハンドリングする

* kvm初期化時にmemory_listener.listener.eventfd_addを登録しておく
    * address_space_init時にeventfd_addが行われる
> accel/kvm/kvm-all.c
1454 static int kvm_init(MachineState *ms)
1455 {
...
1644     if (kvm_eventfds_allowed) {
1645         s->memory_listener.listener.eventfd_add = kvm_mem_ioeventfd_add;
1646         s->memory_listener.listener.eventfd_del = kvm_mem_ioeventfd_del;
1647     }
...
1673 }

> accel/kvm/kvm-all.c
``` c
 580 static int kvm_set_ioeventfd_mmio(int fd, hwaddr addr, uint32_t val,
 581                                   bool assign, uint32_t size, bool datamatch)
 582 {
 583     int ret;
 584     struct kvm_ioeventfd iofd = {
 585         .datamatch = datamatch ? adjust_ioeventfd_endianness(val, size) : 0,
 586         .addr = addr,
 587         .len = size,
 588         .flags = 0,
 589         .fd = fd,
 590     };
 591
 592     if (!kvm_enabled()) {
 593         return -ENOSYS;
 594     }
 595
 596     if (datamatch) {
 597         iofd.flags |= KVM_IOEVENTFD_FLAG_DATAMATCH;
 598     }
 599     if (!assign) {
 600         iofd.flags |= KVM_IOEVENTFD_FLAG_DEASSIGN;
 601     }
 602
 603     ret = kvm_vm_ioctl(kvm_state, KVM_IOEVENTFD, &iofd);
 604
 605     if (ret < 0) {
 606         return -errno;
 607     }
 608
 609     return 0;
 610 }
 611
 612 static int kvm_set_ioeventfd_pio(int fd, uint16_t addr, uint16_t val,
 613                                  bool assign, uint32_t size, bool datamatch)
 614 {
 615     struct kvm_ioeventfd kick = {
 616         .datamatch = datamatch ? adjust_ioeventfd_endianness(val, size) : 0,
 617         .addr = addr,
 618         .flags = KVM_IOEVENTFD_FLAG_PIO,
 619         .len = size,
 620         .fd = fd,
 621     };
 622     int r;
 623     if (!kvm_enabled()) {
 624         return -ENOSYS;
 625     }
 626     if (datamatch) {
 627         kick.flags |= KVM_IOEVENTFD_FLAG_DATAMATCH;
 628     }
 629     if (!assign) {
 630         kick.flags |= KVM_IOEVENTFD_FLAG_DEASSIGN;
 631     }
 632     r = kvm_vm_ioctl(kvm_state, KVM_IOEVENTFD, &kick);
 633     if (r < 0) {
 634         return r;
 635     }
 636     return 0;
 637 }
```


## address_space_init
* ここで、登録するデバイスがeventfdを利用する場合は、eventfd_addを行う
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

 870 static void address_space_update_ioeventfds(AddressSpace *as)
 871 {
 ...
 895     address_space_add_del_ioeventfds(as, ioeventfds, ioeventfd_nb,
 896                                      as->ioeventfds, as->ioeventfd_nb);
 ...
 902 }

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

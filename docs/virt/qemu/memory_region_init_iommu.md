# 


> hw/i386/intel_iommu.c
```
2690 VTDAddressSpace *vtd_find_add_as(IntelIOMMUState *s, PCIBus *bus, int devfn)
2691 {
```


```
1677 void memory_region_init_iommu(void *_iommu_mr,
1678                               size_t instance_size,
1679                               const char *mrtypename,
1680                               Object *owner,
1681                               const char *name,
1682                               uint64_t size)
1683 {
1684     struct IOMMUMemoryRegion *iommu_mr;
1685     struct MemoryRegion *mr;
1686
1687     object_initialize(_iommu_mr, instance_size, mrtypename);
1688     mr = MEMORY_REGION(_iommu_mr);
1689     memory_region_do_init(mr, owner, name, size);
1690     iommu_mr = IOMMU_MEMORY_REGION(mr);
1691     mr->terminates = true;  /* then re-forwards */
1692     QLIST_INIT(&iommu_mr->iommu_notify);
1693     iommu_mr->iommu_notify_flags = IOMMU_NOTIFIER_NONE;
1694 }
```

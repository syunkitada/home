# memory tuning

http://www.slideshare.net/janghoonsim/kvm-performance-optimization-for-ubuntu?qid=fb99f565-8ae4-44d3-9b58-8d8487197566&v=&b=&from_search=3

## THP
### Paging level
| Platform | Page size | Address bit used | Paging levels | splitting |
| --- | --- | --- | --- | --- |
| x86_64 | 4KB(default) | 48 | 4 | 9+9+9+9+12 |
| x86_64 | 2MB(THP)     | 48 | 3 | 9+9+9+21   |

```
# THPが有効かどうか調べる
# alwaysが有効
$ cat /sys/kernel/mm/transparent_hugepage/enabled
[always] madvise never

# set mode
$ sudo sh -c 'echo <mode> > /sys/kernel/mm/transparent_hugepage/enabled'

# Huge pageを確認
$ cat /proc/meminfo| grep Huge
AnonHugePages:    391168 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB

# パラメータを調整
$ sudo ls /sys/kernel/mm/transparent_hugepage/khugepaged
alloc_sleep_millisecs  defrag  full_scans  max_ptes_none  pages_collapsed  pages_to_scan  scan_sleep_millisecs

$ grep thp /proc/vmstat
thp_fault_alloc 1393
thp_fault_fallback 0
thp_collapse_alloc 44
thp_collapse_alloc_failed 0
thp_split 976
thp_zero_page_alloc 1
thp_zero_page_alloc_failed 0

```

# ksm
KSM (kernel samepage merging)
echo "1" > /sys/kernel/mm/ksm/run

# for numa
/sys/kernel/mm/ksm/merge_across_nodes

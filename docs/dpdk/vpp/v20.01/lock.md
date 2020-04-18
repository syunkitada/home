# lock

## spinlock

```c:lb/lb.c
    34 #define lb_get_writer_lock() clib_spinlock_lock (&lb_main.writer_lock)
    35 #define lb_put_writer_lock() clib_spinlock_unlock (&lb_main.writer_lock)
```

```c:vppinfra/lock.h
 51 typedef struct
 52 {
 53   CLIB_CACHE_LINE_ALIGN_MARK (cacheline0);
 54   u32 lock;
 55 #if CLIB_DEBUG > 0
 56   pid_t pid;
 57   uword thread_index;
 58   void *frame_address;
 59 #endif
 60 } *clib_spinlock_t;
 61
 62 static inline void
 63 clib_spinlock_init (clib_spinlock_t * p)
 64 {
 65   *p = clib_mem_alloc_aligned (CLIB_CACHE_LINE_BYTES, CLIB_CACHE_LINE_BYTES);
 66   clib_memset ((void *) *p, 0, CLIB_CACHE_LINE_BYTES);
 67 }
 68
 69 static inline void
 70 clib_spinlock_free (clib_spinlock_t * p)
 71 {
 72   if (*p)
 73     {
 74       clib_mem_free ((void *) *p);
 75       *p = 0;
 76     }
 77 }
 78
 79 static_always_inline void
 80 clib_spinlock_lock (clib_spinlock_t * p)
 81 {
 82   u32 free = 0;
 83   while (!clib_atomic_cmp_and_swap_acq_relax_n (&(*p)->lock, &free, 1, 0))
 84     {
 85       /* atomic load limits number of compare_exchange executions */
 86       while (clib_atomic_load_relax_n (&(*p)->lock))
 87         CLIB_PAUSE ();
 88       /* on failure, compare_exchange writes (*p)->lock into free */
 89       free = 0;
 90     }
 91   CLIB_LOCK_DBG (p);
 92 }
```

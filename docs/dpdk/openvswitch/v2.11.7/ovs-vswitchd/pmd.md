# pmd

```c:lib/dpif-netdev.c
5185 /* Return true if needs to revalidate datapath flows. */
5186 static bool
5187 dpif_netdev_run(struct dpif *dpif)
5188 {


1845 static int
1846 dpif_netdev_port_add(struct dpif *dpif, struct netdev *netdev,
1847                      odp_port_t *port_nop)
1848 {
1849     struct dp_netdev *dp = get_dp_netdev(dpif);
1850     char namebuf[NETDEV_VPORT_NAME_BUFSIZE];
1851     const char *dpif_port;
1852     odp_port_t port_no;
1853     int error;
1854
1855     ovs_mutex_lock(&dp->port_mutex);
1856     dpif_port = netdev_vport_get_dpif_port(netdev, namebuf, sizeof namebuf);
1857     if (*port_nop != ODPP_NONE) {
1858         port_no = *port_nop;
1859         error = dp_netdev_lookup_port(dp, *port_nop) ? EBUSY : 0;
1860     } else {
1861         port_no = choose_port(dp, dpif_port);
1862         error = port_no == ODPP_NONE ? EFBIG : 0;
1863     }
1864     if (!error) {
1865         *port_nop = port_no;
1866         error = do_add_port(dp, dpif_port, netdev_get_type(netdev), port_no);
1867     }
1868     ovs_mutex_unlock(&dp->port_mutex);
1869
1870     return error;
1871 }

1819 static int
1820 do_add_port(struct dp_netdev *dp, const char *devname, const char *type,
1821             odp_port_t port_no)
1822     OVS_REQUIRES(dp->port_mutex)
1823 {
1824     struct dp_netdev_port *port;
1825     int error;
1826
1827     /* Reject devices already in 'dp'. */
1828     if (!get_port_by_name(dp, devname, &port)) {
1829         return EEXIST;
1830     }
1831
1832     error = port_create(devname, type, port_no, &port);
1833     if (error) {
1834         return error;
1835     }
1836
1837     hmap_insert(&dp->ports, &port->node, hash_port_no(port_no));
1838     seq_change(dp->port_seq);
1839
1840     reconfigure_datapath(dp);
1841
1842     return 0;
1843 }


4786 /* Must be called each time a port is added/removed or the cmask changes.
4787  * This creates and destroys pmd threads, reconfigures ports, opens their
4788  * rxqs and assigns all rxqs/txqs to pmd threads. */
4789 static void
4790 reconfigure_datapath(struct dp_netdev *dp)
4791     OVS_REQUIRES(dp->port_mutex)
4792 {
4793     struct dp_netdev_pmd_thread *pmd;
4794     struct dp_netdev_port *port;
4795     int wanted_txqs;
4796
4797     dp->last_reconfigure_seq = seq_read(dp->reconfigure_seq);
4798
4799     /* Step 1: Adjust the pmd threads based on the datapath ports, the cores
4800      * on the system and the user configuration. */
4801     reconfigure_pmd_threads(dp);
...


4669 static void
4670 reconfigure_pmd_threads(struct dp_netdev *dp)
4671     OVS_REQUIRES(dp->port_mutex)
4672 {
...
4729     /* Check for required new pmd threads */
4730     FOR_EACH_CORE_ON_DUMP(core, pmd_cores) {
4731         pmd = dp_netdev_get_pmd(dp, core->core_id);
4732         if (!pmd) {
4733             pmd = xzalloc(sizeof *pmd);
4734             dp_netdev_configure_pmd(pmd, dp, core->core_id, core->numa_id);
4735             pmd->thread = ovs_thread_create("pmd", pmd_thread_main, pmd);
4736             VLOG_INFO("PMD thread on numa_id: %d, core id: %2d created.",
4737                       pmd->numa_id, pmd->core_id);
4738             changed = true;
4739         } else {
4740             dp_netdev_pmd_unref(pmd);
4741         }
4742     }
...
4754     ovs_numa_dump_destroy(pmd_cores);
4755 }



5398 static void *
5399 pmd_thread_main(void *f_)
5400 {
5401     struct dp_netdev_pmd_thread *pmd = f_;
5402     struct pmd_perf_stats *s = &pmd->perf_stats;
5403     unsigned int lc = 0;
5404     struct polled_queue *poll_list;
5405     bool exiting;
5406     int poll_cnt;
5407     int i;
5408     int process_packets = 0;
5409
5410     poll_list = NULL;
5411
5412     /* Stores the pmd thread's 'pmd' to 'per_pmd_key'. */
5413     ovsthread_setspecific(pmd->dp->per_pmd_key, pmd);
5414     ovs_numa_thread_setaffinity_core(pmd->core_id);
5415     dpdk_set_lcore_id(pmd->core_id);
5416     poll_cnt = pmd_load_queues_and_ports(pmd, &poll_list);
5417     dfc_cache_init(&pmd->flow_cache);
5418 reload:
5419     pmd_alloc_static_tx_qid(pmd);
5420
5421     atomic_count_init(&pmd->pmd_overloaded, 0);
5422
5423     /* List port/core affinity */
5424     for (i = 0; i < poll_cnt; i++) {
5425        VLOG_DBG("Core %d processing port \'%s\' with queue-id %d\n",
5426                 pmd->core_id, netdev_rxq_get_name(poll_list[i].rxq->rx),
5427                 netdev_rxq_get_queue_id(poll_list[i].rxq->rx));
5428        /* Reset the rxq current cycles counter. */
5429        dp_netdev_rxq_set_cycles(poll_list[i].rxq, RXQ_CYCLES_PROC_CURR, 0);
5430     }
5431
5432     if (!poll_cnt) {
5433         while (seq_read(pmd->reload_seq) == pmd->last_reload_seq) {
5434             seq_wait(pmd->reload_seq, pmd->last_reload_seq);
5435             poll_block();
5436         }
5437         lc = UINT_MAX;
5438     }
5439
5440     pmd->intrvl_tsc_prev = 0;
5441     atomic_store_relaxed(&pmd->intrvl_cycles, 0);
5442     cycles_counter_update(s);
5443     /* Protect pmd stats from external clearing while polling. */
5444     ovs_mutex_lock(&pmd->perf_stats.stats_mutex);
5445     for (;;) {
5446         uint64_t rx_packets = 0, tx_packets = 0;
5447
5448         pmd_perf_start_iteration(s);
5449
5450         for (i = 0; i < poll_cnt; i++) {
5451
5452             if (poll_list[i].emc_enabled) {
5453                 atomic_read_relaxed(&pmd->dp->emc_insert_min,
5454                                     &pmd->ctx.emc_insert_min);
5455             } else {
5456                 pmd->ctx.emc_insert_min = 0;
5457             }
5458
# 受信処理
5459             process_packets =
5460                 dp_netdev_process_rxq_port(pmd, poll_list[i].rxq,
5461                                            poll_list[i].port_no);
5462             rx_packets += process_packets;
5463         }
5464
5465         if (!rx_packets) {
5466             /* We didn't receive anything in the process loop.
5467              * Check if we need to send something.
5468              * There was no time updates on current iteration. */
5469             pmd_thread_ctx_time_update(pmd);
5470             tx_packets = dp_netdev_pmd_flush_output_packets(pmd, false);
5471         }
5472
5473         if (lc++ > 1024) {
5474             bool reload;
5475
5476             lc = 0;
5477
5478             coverage_try_clear();
5479             dp_netdev_pmd_try_optimize(pmd, poll_list, poll_cnt);
5480             if (!ovsrcu_try_quiesce()) {
5481                 emc_cache_slow_sweep(&((pmd->flow_cache).emc_cache));
5482             }
5483
5484             atomic_read_relaxed(&pmd->reload, &reload);
5485             if (reload) {
5486                 break;
5487             }
5488         }
5489         pmd_perf_end_iteration(s, rx_packets, tx_packets,
5490                                pmd_perf_metrics_enabled(pmd));
5491     }
5492     ovs_mutex_unlock(&pmd->perf_stats.stats_mutex);
5493
5494     poll_cnt = pmd_load_queues_and_ports(pmd, &poll_list);
5495     exiting = latch_is_set(&pmd->exit_latch);
5496     /* Signal here to make sure the pmd finishes
5497      * reloading the updated configuration. */
5498     dp_netdev_pmd_reload_done(pmd);
5499
5500     pmd_free_static_tx_qid(pmd);
5501
5502     if (!exiting) {
5503         goto reload;
5504     }
5505
5506     dfc_cache_uninit(&pmd->flow_cache);
5507     free(poll_list);
5508     pmd_free_cached_ports(pmd);
5509     return NULL;
5510 }
```

```c:lib/dpif-netdev.c
4243 static int
4244 dp_netdev_process_rxq_port(struct dp_netdev_pmd_thread *pmd,
4245                            struct dp_netdev_rxq *rxq,
4246                            odp_port_t port_no)
4247 {
4248     struct pmd_perf_stats *s = &pmd->perf_stats;
4249     struct dp_packet_batch batch;
4250     struct cycle_timer timer;
4251     int error;
4252     int batch_cnt = 0;
4253     int rem_qlen = 0, *qlen_p = NULL;
4254     uint64_t cycles;
4255
4256     /* Measure duration for polling and processing rx burst. */
4257     cycle_timer_start(&pmd->perf_stats, &timer);
4258
4259     pmd->ctx.last_rxq = rxq;
4260     dp_packet_batch_init(&batch);
4261
4262     /* Fetch the rx queue length only for vhostuser ports. */
4263     if (pmd_perf_metrics_enabled(pmd) && rxq->is_vhost) {
4264         qlen_p = &rem_qlen;
4265     }
4266
4267     error = netdev_rxq_recv(rxq->rx, &batch, qlen_p);
4268     if (!error) {
4269         /* At least one packet received. */
4270         *recirc_depth_get() = 0;
4271         pmd_thread_ctx_time_update(pmd);
4272         batch_cnt = batch.count;
4273         if (pmd_perf_metrics_enabled(pmd)) {
4274             /* Update batch histogram. */
4275             s->current.batches++;
4276             histogram_add_sample(&s->pkts_per_batch, batch_cnt);
4277             /* Update the maximum vhost rx queue fill level. */
4278             if (rxq->is_vhost && rem_qlen >= 0) {
4279                 uint32_t qfill = batch_cnt + rem_qlen;
4280                 if (qfill > s->current.max_vhost_qfill) {
4281                     s->current.max_vhost_qfill = qfill;
4282                 }
4283             }
4284         }
4285         /* Process packet batch. */
4286         dp_netdev_input(pmd, &batch, port_no);
4287
4288         /* Assign processing cycles to rx queue. */
4289         cycles = cycle_timer_stop(&pmd->perf_stats, &timer);
4290         dp_netdev_rxq_add_cycles(rxq, RXQ_CYCLES_PROC_CURR, cycles);
4291
4292         dp_netdev_pmd_flush_output_packets(pmd, false);
4293     } else {
```

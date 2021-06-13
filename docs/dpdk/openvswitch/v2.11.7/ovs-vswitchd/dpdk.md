# dpdk

## 初期化処理

```c:lib/dpdk.c
448 void
449 dpdk_init(const struct smap *ovs_other_config)
450 {
451     static bool enabled = false;
452
453     if (enabled || !ovs_other_config) {
454         return;
455     }
456
457     const char *dpdk_init_val = smap_get_def(ovs_other_config, "dpdk-init",
458                                              "false");
459
460     bool try_only = !strcasecmp(dpdk_init_val, "try");
461     if (!strcasecmp(dpdk_init_val, "true") || try_only) {
462         static struct ovsthread_once once_enable = OVSTHREAD_ONCE_INITIALIZER;
463
464         if (ovsthread_once_start(&once_enable)) {
465             VLOG_INFO("Using %s", rte_version());
466             VLOG_INFO("DPDK Enabled - initializing...");
467             enabled = dpdk_init__(ovs_other_config);
468             if (enabled) {
469                 VLOG_INFO("DPDK Enabled - initialized");
470             } else if (!try_only) {
471                 ovs_abort(rte_errno, "Cannot init EAL");
472             }
473             ovsthread_once_done(&once_enable);
474         } else {
475             VLOG_ERR_ONCE("DPDK Initialization Failed.");
476         }
477     } else {
478         VLOG_INFO_ONCE("DPDK Disabled - Use other_config:dpdk-init to enable");
479     }
480     dpdk_initialized = enabled;
481 }
```

## 受信処理

```c:lib/netdev-dpdk.c
2234 static int
2235 netdev_dpdk_rxq_recv(struct netdev_rxq *rxq, struct dp_packet_batch *batch,
2236                      int *qfill)
2237 {
2238     struct netdev_rxq_dpdk *rx = netdev_rxq_dpdk_cast(rxq);
2239     struct netdev_dpdk *dev = netdev_dpdk_cast(rxq->netdev);
2240     struct ingress_policer *policer = netdev_dpdk_get_ingress_policer(dev);
2241     int nb_rx;
2242     int dropped = 0;
2243
2244     if (OVS_UNLIKELY(!(dev->flags & NETDEV_UP))) {
2245         return EAGAIN;
2246     }
2247
2248     nb_rx = rte_eth_rx_burst(rx->port_id, rxq->queue_id,
2249                              (struct rte_mbuf **) batch->packets,
2250                              NETDEV_MAX_BURST);
2251     if (!nb_rx) {
2252         return EAGAIN;
2253     }
2254
2255     if (policer) {
2256         dropped = nb_rx;
2257         nb_rx = ingress_policer_run(policer,
2258                                     (struct rte_mbuf **) batch->packets,
2259                                     nb_rx, true);
2260         dropped -= nb_rx;
2261     }
2262
2263     /* Update stats to reflect dropped packets */
2264     if (OVS_UNLIKELY(dropped)) {
2265         rte_spinlock_lock(&dev->stats_lock);
2266         dev->stats.rx_dropped += dropped;
2267         rte_spinlock_unlock(&dev->stats_lock);
2268     }
2269
2270     batch->count = nb_rx;
2271     dp_packet_batch_init_packet_fields(batch);
2272
2273     if (qfill) {
2274         if (nb_rx == NETDEV_MAX_BURST) {
2275             *qfill = rte_eth_rx_queue_count(rx->port_id, rxq->queue_id);
2276         } else {
2277             *qfill = 0;
2278         }
2279     }
```

```c:lib/netdev-dpdk.c
5013 #define NETDEV_DPDK_CLASS_BASE                          \
5014     NETDEV_DPDK_CLASS_COMMON,                           \
5015     .init = netdev_dpdk_class_init,                     \
5016     .destruct = netdev_dpdk_destruct,                   \
5017     .set_tx_multiq = netdev_dpdk_set_tx_multiq,         \
5018     .get_carrier = netdev_dpdk_get_carrier,             \
5019     .get_stats = netdev_dpdk_get_stats,                 \
5020     .get_custom_stats = netdev_dpdk_get_custom_stats,   \
5021     .get_features = netdev_dpdk_get_features,           \
5022     .get_status = netdev_dpdk_get_status,               \
5023     .reconfigure = netdev_dpdk_reconfigure,             \
5024     .rxq_recv = netdev_dpdk_rxq_recv,                   \
5025     DPDK_FLOW_OFFLOAD_API
5026
5027 static const struct netdev_class dpdk_class = {
5028     .type = "dpdk",
5029     NETDEV_DPDK_CLASS_BASE,
5030     .construct = netdev_dpdk_construct,
5031     .set_config = netdev_dpdk_set_config,
5032     .send = netdev_dpdk_eth_send,
5033 };
5034
5035 static const struct netdev_class dpdk_ring_class = {
5036     .type = "dpdkr",
5037     NETDEV_DPDK_CLASS_BASE,
5038     .construct = netdev_dpdk_ring_construct,
5039     .set_config = netdev_dpdk_ring_set_config,
5040     .send = netdev_dpdk_ring_send,
5041 };
```

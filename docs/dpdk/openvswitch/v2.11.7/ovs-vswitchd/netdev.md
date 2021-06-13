# netdev

```c:lib/netdev.c
 686 /* Attempts to receive a batch of packets from 'rx'.  'batch' should point to
 687  * the beginning of an array of NETDEV_MAX_BURST pointers to dp_packet.  If
 688  * successful, this function stores pointers to up to NETDEV_MAX_BURST
 689  * dp_packets into the array, transferring ownership of the packets to the
 690  * caller, stores the number of received packets in 'batch->count', and returns
 691  * 0.
 692  *
 693  * The implementation does not necessarily initialize any non-data members of
 694  * 'batch'.  That is, the caller must initialize layer pointers and metadata
 695  * itself, if desired, e.g. with pkt_metadata_init() and miniflow_extract().
 696  *
 697  * Returns EAGAIN immediately if no packet is ready to be received or another
 698  * positive errno value if an error was encountered. */
 699 int
 700 netdev_rxq_recv(struct netdev_rxq *rx, struct dp_packet_batch *batch,
 701                 int *qfill)
 702 {
 703     int retval;
 704
 705     retval = rx->netdev->netdev_class->rxq_recv(rx, batch, qfill);
 706     if (!retval) {
 707         COVERAGE_INC(netdev_received);
 708     } else {
 709         batch->count = 0;
 710     }
 711     return retval;
 712 }
```

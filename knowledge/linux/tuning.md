# tuning

## tuned

- [tuned](https://github.com/redhat-performance/tuned)
  - チューニング項目の参考になりそう
  - [profiles](https://github.com/redhat-performance/tuned/tree/master/profiles)
  - [plugins](https://github.com/redhat-performance/tuned/tree/master/tuned/plugins)
- [latency-performance](https://github.com/redhat-performance/tuned/blob/b894a3ee3f0e0782963ee1268c819ebc437398d3/profiles/latency-performance/tuned.conf)
  - [force_latency=cstate.id_no_zero:1|3](https://github.com/redhat-performance/tuned/blob/b894a3ee3f0e0782963ee1268c819ebc437398d3/profiles/latency-performance/tuned.conf#L9)
    - https://github.com/redhat-performance/tuned/blob/master/tuned/plugins/plugin_cpu.py
    - /dev/cpu_dma_latency を使って latency を強制する
      - これに 0[us]を入れると、idle から復帰までの時間が 0 になる
      - 数値はバイナリ形式で書き込む
      - デバイスをオープンして数値を書き込んでから閉じるまでの間、指定した状態が維持される
  - [governor=performance, energy_perf_bias=performance](https://github.com/redhat-performance/tuned/blob/b894a3ee3f0e0782963ee1268c819ebc437398d3/profiles/latency-performance/tuned.conf#L10-L11)
    - https://github.com/redhat-performance/tuned/blob/master/tuned/plugins/plugin_cpu.py
  - [min_perf_pct=100](https://github.com/redhat-performance/tuned/blob/b894a3ee3f0e0782963ee1268c819ebc437398d3/profiles/latency-performance/tuned.conf#L12)
    - https://github.com/redhat-performance/tuned/blob/master/tuned/plugins/plugin_cpu.py
    - 下限の CPU 周波数を 100 にする
  - [vm.dirty_ratio=10, vm.dirty_background_ratio=3](https://github.com/redhat-performance/tuned/blob/b894a3ee3f0e0782963ee1268c819ebc437398d3/profiles/latency-performance/tuned.conf#L20-L26)
- [throughput-performance](https://github.com/redhat-performance/tuned/blob/master/profiles/throughput-performance/tuned.conf)
  - transparent_hugepages=never
  - readahead=>4096
  - [vm.dirty_ratio=40, vm.dirty_background_ratio=10](https://github.com/redhat-performance/tuned/blob/master/profiles/throughput-performance/tuned.conf#L36-L42)
- [network-latency](https://github.com/redhat-performance/tuned/blob/b894a3ee3f0e0782963ee1268c819ebc437398d3/profiles/network-latency/tuned.conf)
  - latency-performance を継承
  - net.core.busy_read
  - net.core.busy_poll

## Observation Performance

## Problem Statement Method

- パフォーマンスに問題があると思うか？
- このシステムはこれまでうまく機能していたか？
- 最近の変更は何か？（ソフトウェア? ハードウェア?)
- パフォーマンスの低下をレイテンシや実行時間で表現できるか？
- 問題が他の人やアプリケーションに影響するか？（またはあたただけか？）
- 環境は？ソフトウェア、ハードウェア、インスタンスタイプは？バージョンは？設定は？

## Workload Characterizaon Method

- 誰がその負荷を引き起こしているか？PID、UID、IP アドレス、etc
- なぜその負荷が呼び出されたか？コードパス、スタックとレース、etc
- その負荷は何か？IOPS、tput、type、r/w
- その負荷は時間とともにどのように変化するか？

## The USE Method

- 参考 1: [The USE Method](http://www.brendangregg.com/usemethod.html)
- 参考 2: [USE Method: Linux Performance Checklist](http://www.brendangregg.com/USEmethod/use-linux.html)
  各リソース(CPU, disks, busses, ...)の以下の項目についてチェックする
- utilization: リソースがビジー状態になった平均時間
- saturation(さちる、飽和): キューに積まれてる長さ、キューイングされてる時間
- errors: エラーイベントの数

## Hardware

```
-- CPU Interconnect -- |CPU| -- Memory Bus -- |DRAM|

-- I/O Bus -- |I/O Bridge| -- |I/O Controller| -- |Disk|
                                               -- |Disk|
                                               -- |Swap|
                           -- |Network Controller|| -- |Port|
                                                    -- |Port|
```

USE Method: Checklist

## Off-CPU Analysis

- 参考 1: [Off-CPU Analysis](http://www.brendangregg.com/offcpuanalysis.html)
- Off-CPU の状態にフォーカスして解析を行うこと
- スレッドは、ファイルシステム、ネットワーク IO、同期ロック、ページング/スワッピング、明示的なタイマーやシグナル、などを理由に CPU を離れる(Off-CPU)

```
(Runnable) -- schedule                                -> (Executing) -- anon. major fault -> (Anon. Paging)
           <- preempted or time quantum expired       --             <- page in           --
           <- wakeup -- (Sleep) <- I/O wait           --
           <- acquire -- (Lock) <- block              --
           <- work arrives -- (Idle) <- wait for work --

CPU Sampling ----------------------------------------------->
     |  |  |  |  |  |  |                      |  |  |  |  |
     A  A  A  A  B  B  B                      B  A  A  A  A
    A(---------.                                .----------)
               |                                |
               B(--------.                   .--)
                         |                   |         user-land
   - - - - - - - - - - syscall - - - - - - - - - - - - - - - - -
                         |                   |         kernel
                         X     Off-CPU       |
                       block . . . . . interrupt
```

## CPU Profile Method

- 参考: [Flame Graphs](http://www.brendangregg.com/flamegraphs.html)
- CPU のプロファイルを取得する
- すべてのソフトウェアの CPU 使用率から 1%以上のものを把握する
- それらの CPU 使用率からパフォーマンス問題が広いものを発見する

```
OS
| Applications            |
|      | System libraries |
 -------------------------
| System Call Interface   |
 -------------------------
| Linux Kernel                                       |
| VFS                    | Sockets  | Scheduler      |
| File Systems           | TCP/UDP  | Virtual Memory |
| Volume Manager         | IP       |                |
| Block Device Interface | Ethernet |                |
| ------------------------
| Device Drivvers         |
 -------------------------
| Firmware                |
 -------------------------

Hardware
|CPU| -- Memory Bus -- |DRAM|
|   | -- I/O Bus -- |I/O Bridge| -- |I/O Controller| -- |Disk|
                    |          |                     -- |Disk|
                    |          |                     -- |Swap|
                    |          | -- |Network Controller|| -- |Port|
                    |          |                          -- |Port|
```

- http://cdn.oreillystatic.com/en/assets/1/event/122/Linux%20perf%20tools%20Presentation.pdf

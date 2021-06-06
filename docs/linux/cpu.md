# CPU

## CPU のパフォーマンススケールについて

- CPU は様々なクロック周波数や電圧構成で動作することができる
- クロック周波数が高く電圧が高いと、多くの命令を実行できるが、消費電力も多くなる
- CPU は、P-States と C-States によって周波数や電力を制御する
  - P-States
    - クロック周波数と電力を制御するための状態
  - C-States
    - Idle 状態における電力消費を抑えるための状態
- Kernel は、アルゴリズムにより必要な CPU 容量（単位時間に実行できる命令数）を推定して、CPU の P-States を設定する
- この周波数の調整は定期的に行われており、これを周波数スケーリングと呼ぶ
- 周波数スケーリングは、以下の 3 層のコードから構成される CPUFreq(CPU Frequency scaling)サブシステムによってサポートされている
  - Core
    - 共通のコード基盤とユーザスペースインターフェイスを提供する
  - Scaling governors
    - 必要な CPU 容量を推定するためのアルゴリズム実装
  - Scaling drivers
    - プラットフォーム固有のハードウェアインターフェイスにアクセスしてハードウェアと通信する
    - Scaling governor で使用可能な P-States に関する情報を提供する
    - スケーリングガバナーの要求に応じて ハードウェアの P-States の状態を変更する

### Policy Interface in sysfs

- Kernel の初期化処理中に、CPUFreq core は、sysfs directory (kobject)を、/sys/devices/system/cpu/ 配下に作成する
- /sys/devices/system/cpu/cpufreq/policyX に、各 CPU ごとの Policy 設定(attributes)が配置されており、これらにより CPUFreq の動作を制御したり、CPUFreq から情報を取得することができる

```
# /sys/devices/system/cpu/cpufreq/policyX
$ ls /sys/devices/system/cpu/cpufreq/policy0
affected_cpus  cpuinfo_cur_freq  cpuinfo_transition_latency  scaling_available_frequencies  scaling_driver    scaling_min_freq
bios_limit     cpuinfo_max_freq  freqdomain_cpus             scaling_available_governors    scaling_governor  scaling_setspeed
cpb            cpuinfo_min_freq  related_cpus                scaling_cur_freq               scaling_max_freq  stats/

# driverの確認
$ cat /sys/devices/system/cpu/cpufreq/policy0/scaling_driver
acpi-cpufreq

# governorの確認
$ cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
ondemand

# 最大周波数
$ cat /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
3400000

# 最小周波数
$ cat /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
1550000

# Biosによる制限
$ cat /sys/devices/system/cpu/cpufreq/policy0/bios_limit
3400000

# 全CPUのgovernorを確認する
$ grep '' /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor:ondemand
/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor:ondemand
/sys/devices/system/cpu/cpu10/cpufreq/scaling_governor:ondemand
/sys/devices/system/cpu/cpu11/cpufreq/scaling_governor:ondemand
/sys/devices/system/cpu/cpu2/cpufreq/scaling_governor:ondemand
/sys/devices/system/cpu/cpu3/cpufreq/scaling_governor:ondemand
/sys/devices/system/cpu/cpu4/cpufreq/scaling_governor:ondemand
/sys/devices/system/cpu/cpu5/cpufreq/scaling_governor:ondemand
/sys/devices/system/cpu/cpu6/cpufreq/scaling_governor:ondemand
/sys/devices/system/cpu/cpu7/cpufreq/scaling_governor:ondemand
/sys/devices/system/cpu/cpu8/cpufreq/scaling_governor:ondemand
/sys/devices/system/cpu/cpu9/cpufreq/scaling_governor:ondemand
```

### CPUFreq Stats

- 以下のディレクトリ内に cpu の周波数変化の統計情報がある
- /sys/devices/system/cpu/cpu0/cpufreq/stats/\*
- [CPUFreq Stats](https://www.kernel.org/doc/Documentation/cpu-freq/cpufreq-stats.txt)

```
$ ls /sys/devices/system/cpu/cpufreq/policy0/stats
reset  time_in_state  total_trans  trans_table


# カウンタをリセットする
$ echo '1' | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/stats/reset

# すべてのCPUのカウンタをリセットする
$ echo '1' | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/stats/reset
1


# 各周波数ごとの動作時間(usertime units)が記録されている
# usertime unitsは、10ms
$ cat /sys/devices/system/cpu/cpufreq/policy0/stats/time_in_state
3400000 3661
2800000 460
1550000 1944320


# 周波数が遷移した回数
$ cat /sys/devices/system/cpu/cpufreq/policy0/stats/total_trans
244


# 周波数の遷移表
$ cat /sys/devices/system/cpu/cpufreq/policy0/stats/trans_table
From   :    To
       :   3400000   2800000   1550000
3400000:         0        17        53
2800000:        12         0        55
1550000:        58        50         0


# 周波数の確認
$ cat /proc/cpuinfo| grep MHz
cpu MHz         : 1555.574
cpu MHz         : 1551.938
cpu MHz         : 3893.328
cpu MHz         : 3892.303
cpu MHz         : 1554.666
cpu MHz         : 1556.543
cpu MHz         : 1375.079
cpu MHz         : 1374.843
cpu MHz         : 1374.393
cpu MHz         : 1374.590
cpu MHz         : 1374.630
cpu MHz         : 1374.328


# 現在の周波数の確認(Idle状態のときは周波数の最小値を下回る?)
$ cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
1342590
# 周波数の最小値
$ cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
1550000
# 周波数の最大値
$ cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
3400000
```

### Scaling Drivers

- intel_pstate
  - Intel 用のドライバ
- intel_cpufreq
  - Kernel 5.7 以降で利用できる Intel 用のドライバ
  - ハードウェア管理の P-States(HWP)をサポートしない CPU（第 5 世代以降の Intel Core に対して「パッシブモード: intel_cpufreq」を選択する）
- acpi-cpufreq
  - ACPI プロセッサを利用するためのドライバ
  - AMD はこれを利用する

### Scaling Governors

- performance
  - ポリシーオブジェクトにアタッチされると、scaling_max_freq の値をリクエストする
  - scaling_max_freq, scaling_min_freq が更新されるたびに、再度リクエストされる
- powersave
  - ポリシーオブジェクトにアタッチされると、scaling_min_freq の値をリクエストする
  - scaling_max_freq, scaling_min_freq が更新されるたびに、再度リクエストされる
- userspace
  - この Governor 自体は何もしないが、scaling_setspeed が書き込まれると、それをリクエストする
- schedutil
  - CPU スケジューラから入手可能な CPU 使用率データを使用して周波数をリクエストする
- ondemand
  - CPU の負荷情報を使用して周波数をリクエストする
- conservative
  - CPU の負荷情報を使用して周波数をリクエストする
  - ondemand とアルゴリズムが異なり、周波数の変化が ondemand よりもゆるやか

### Frequency Boost

- プロセッサは、特定の条件下で一部のコアの周波数を一時的に閾値を超えて動作させる機能を持っている
- この周波数をブーストする機能を、Intel は Turbo Boost、AMD は Turbo Core もしくは Core Performance Boost と呼んでいる
- 周波数ブーストのメカニズムは、ハードウェアベースまたはソフトウェアベースのものがある
  - 違いは、ブーストのトリガーがハードウェアかソフトウェアの違いである
- 以下で、ブーストの有効・無効を切り替えられる

```
# intel_pstateを利用してる場合は、以下を1にするとターボブーストを無効にする
/sys/devices/system/cpu/intel_pstate/no_turbo

# acpi-cpufreqを利用している場合は、以下を1にするとターボブーストを有効にする
/sys/devices/system/cpu/cpufreq/boost
```

### BIOS の設定

- Kernel 側の設定だけで周波数が制御できない場合は、BIOS で以下の設定を見直す必要がある
- CPU の周波数制限の設定
- CPU の省電力設定
  - [参考](https://www.thomas-krenn.com/en/wiki/Disable_CPU_Power_Saving_Management_in_BIOS)

```
# BIOSの制限(bios_limit)を明示的に無視する
$ echo 1 | sudo tee /sys/module/processor/parameters/ignore_ppc


# 永続化するには、boot optionに以下を追加する
processor.ignore_ppc=1

# もしくは、以下を作成する
$ cat /etc/modprobe.d/ignore_ppc.conf
options processor ignore_ppc=1
```

## 周波数制御のためのツール照会

### cpufrequtils

- cpufreq-info で CPU の状態を確認できる
  - 基本的には、/sys/devices/system/cpu/cpufreq/policyX を読みやすくしたものである
  - 主に見るのは以下
    - current policy
    - current CPU frequency
    - cpufreq stats

```
$ cpufreq-info
cpufrequtils 008: cpufreq-info (C) Dominik Brodowski 2004-2009
Report errors and bugs to cpufreq@vger.kernel.org, please.
analyzing CPU 0:
  driver: acpi-cpufreq
  CPUs which run at the same hardware frequency: 0
  CPUs which need to have their frequency coordinated by software: 0
  maximum transition latency: 4294.55 ms.
  hardware limits: 1.55 GHz - 3.40 GHz
  available frequency steps: 3.40 GHz, 2.80 GHz, 1.55 GHz
  available cpufreq governors: conservative, ondemand, userspace, powersave, performance, schedutil
  current policy: frequency should be within 1.55 GHz and 3.40 GHz.
                  The governor "ondemand" may decide which speed to use
                  within this range.
  current CPU frequency is 1.38 GHz.
  cpufreq stats: 3.40 GHz:1.01%, 2.80 GHz:0.10%, 1.55 GHz:98.89%  (661)
analyzing CPU 1:
  driver: acpi-cpufreq
  CPUs which run at the same hardware frequency: 1
  CPUs which need to have their frequency coordinated by software: 1
  maximum transition latency: 4294.55 ms.
  hardware limits: 1.55 GHz - 3.40 GHz
  available frequency steps: 3.40 GHz, 2.80 GHz, 1.55 GHz
  available cpufreq governors: conservative, ondemand, userspace, powersave, performance, schedutil
  current policy: frequency should be within 1.55 GHz and 3.40 GHz.
                  The governor "ondemand" may decide which speed to use
                  within this range.
  current CPU frequency is 1.44 GHz.
  cpufreq stats: 3.40 GHz:0.38%, 2.80 GHz:0.16%, 1.55 GHz:99.45%  (1051)
```

- governor を変更する

```
# cpufrequtils の設定ファイル
$ cat << EOS | sudo tee /etc/default/cpufrequtils
ENABLE="true"
GOVERNOR="performance"
MAX_SPEED=0
MIN_SPEED=0
EOS

# cpufrequtils をリスタートする
# cpufrequtils はシステム起動時にも実行される
$ sudo systemctl restart cpufrequtils
```

### turbostat

- CPU の周波数やモードに関する以下の情報を一定間隔（デフォルトは 5 秒）で表示します
  - Core
    - プロセッサのコア番号
  - CPU
    - Linux CPU(論理プロセッサ)番号
  - Bzy_MHz
    - この数値が TSC の値よりも大きい場合、CPU はターボモードになる
  - TSC_MHz
    - 間隔全体を通じたクロック平均速度
  - C1, C2
    - プロセッサの各状態だった時間

```
$ sudo turbostat
turbostat version 19.08.31 - Len Brown <lenb@kernel.org>
CPUID(0): AuthenticAMD 0xd CPUID levels; 0x8000001f xlevels; family:model:stepping 0x17:8:2 (23:8:2)
CPUID(1): SSE3 MONITOR - - - TSC MSR - HT -
CPUID(6): APERF, No-TURBO, No-DTS, No-PTM, No-HWP, No-HWPnotify, No-HWPwindow, No-HWPepp, No-HWPpkg, No-EPB
CPUID(7): No-SGX
RAPL: 262 sec. Joule Counter Range, at 250 Watts
cpu6: POLL: CPUIDLE CORE POLL IDLE
cpu6: C1: ACPI FFH MWAIT 0x0
cpu6: C2: ACPI IOPORT 0x414
cpu6: cpufreq driver: acpi-cpufreq
cpu6: cpufreq governor: ondemand
cpufreq boost: 1
cpu0: MSR_RAPL_PWR_UNIT: 0x000a1003 (0.125000 Watts, 0.000015 Joules, 0.000977 sec.)
Core    CPU     Avg_MHz Busy%   Bzy_MHz TSC_MHz IRQ     POLL    C1      C2      POLL%   C1%     C2%     CorWatt PkgWatt
-       -       2       0.12    1402    3394    1561    2       263     868     0.00    0.23    99.67   0.04    7.31
0       0       4       0.26    1424    3394    312     0       84      159     0.00    0.82    98.94   0.01    7.31
0       1       1       0.07    1497    3394    70      0       6       42      0.00    0.04    99.90
1       2       2       0.15    1353    3394    120     0       3       81      0.00    0.09    99.77   0.01
1       3       1       0.05    1351    3394    43      0       10      24      0.00    0.18    99.77
2       4       2       0.17    1361    3394    175     0       23      125     0.00    0.20    99.64   0.01
2       5       3       0.18    1381    3394    174     0       9       133     0.00    0.14    99.70
4       6       1       0.08    1470    3394    57      0       2       31      0.00    0.03    99.90   0.01
4       7       1       0.04    1443    3394    53      0       5       34      0.00    0.10    99.86
5       8       3       0.21    1387    3394    295     0       92      107     0.00    0.13    99.68   0.01
5       9       1       0.04    1409    3394    51      0       11      27      0.00    0.01    99.96
6       10      0       0.03    1430    3394    57      1       1       36      0.00    0.00    99.97   0.01
6       11      2       0.13    1427    3394    154     1       17      69      0.00    1.03    98.85
Core    CPU     Avg_MHz Busy%   Bzy_MHz TSC_MHz IRQ     POLL    C1      C2      POLL%   C1%     C2%     CorWatt PkgWatt
-       -       2       0.13    1444    3394    1549    23      205     895     0.00    0.12    99.76   0.05    7.35
0       0       2       0.17    1379    3394    290     0       103     121     0.00    0.68    99.16   0.01    7.35
0       1       1       0.09    1380    3394    84      0       0       57      0.00    0.00    99.92
1       2       1       0.10    1376    3394    138     0       7       118     0.00    0.01    99.90   0.01
1       3       0       0.02    1401    3394    23      0       1       13      0.00    0.02    99.96
2       4       4       0.26    1377    3394    250     0       14      148     0.00    0.03    99.72   0.01
2       5       2       0.18    1381    3394    142     0       1       92      0.00    0.02    99.82
4       6       5       0.34    1584    3394    116     0       25      74      0.00    0.25    99.42   0.01
4       7       0       0.02    1688    3394    43      0       25      19      0.00    0.24    99.74
5       8       1       0.04    1404    3394    56      0       1       41      0.00    0.01    99.96   0.00
5       9       0       0.02    1399    3394    32      0       6       20      0.00    0.01    99.97
6       10      2       0.13    1519    3394    211     23      21      83      0.00    0.17    99.70   0.01
6       11      2       0.16    1406    3394    164     0       1       109     0.00    0.00    99.85
```

### x86_energy_perf_policy

- x86 用の P-Stat を特定のレジスタを通じて設定することができる
  - レジスタの参照や書き込みを禁止してる場合は利用できない
- 参考
  - [x86_energy_perf_policy](https://man.archlinux.org/man/x86_energy_perf_policy.8)
  - [A.9. X86_ENERGY_PERF_POLICY](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/performance_tuning_guide/sect-red_hat_enterprise_linux-performance_tuning_guide-tool_reference-x86_energy_perf_policy)

```
# 現行ポリシーを表示する（見えない）
$ sudo x86_energy_perf_policy -r

# policyを設定する（できない）
$ sudo x86_energy_perf_policy performance
x86_energy_perf_policy: EPB not enabled on this platform
```

## References

- [CPU Performance Scaling](https://www.kernel.org/doc/html/latest/admin-guide/pm/cpufreq.html)
- [CPU frequency scaling](https://wiki.archlinux.org/index.php/CPU_frequency_scaling)
- [CPU frequency and voltage scaling code in the Linux(TM) kernel](https://www.kernel.org/doc/Documentation/cpu-freq/governors.txt)
- [CPU frequency and voltage scaling statistics in the Linux(TM) kernel](https://www.kernel.org/doc/Documentation/cpu-freq/cpufreq-stats.txt)

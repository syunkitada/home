# cpu

taskset -c 3

# governor

```
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


# driverの確認
$ cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver
acpi-cpufreq

# governorの確認
$ cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
ondemand

# 最大周波数
$ cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
3400000

# 最小周波数
$ cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
1550000

grep ""
$ cat /sys/devices/system/cpu/cpu0/cpufreq/bios_limit
3400000


# 以下のディレクトリないにcpuの周波数変化の統計情報がある
# /sys/devices/system/cpu/cpu0/cpufreq/stats/*
#
https://www.kernel.org/doc/Documentation/cpu-freq/cpufreq-stats.txt



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

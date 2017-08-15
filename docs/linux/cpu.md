# cpu


$ cat /proc/cpuinfo

$ cpufreq-info
cpufrequtils 008: cpufreq-info (C) Dominik Brodowski 2004-2009
Report errors and bugs to cpufreq@vger.kernel.org, please.
analyzing CPU 0:
  driver: intel_pstate
  CPUs which run at the same hardware frequency: 0
  CPUs which need to have their frequency coordinated by software: 0
  maximum transition latency: 0.97 ms.
  hardware limits: 800 MHz - 4.30 GHz
  available cpufreq governors: performance, powersave
  current policy: frequency should be within 800 MHz and 4.30 GHz.
                  The governor "powersave" may decide which speed to use
                  within this range.
  current CPU frequency is 1.47 GHz.
analyzing CPU 1:
  driver: intel_pstate
  CPUs which run at the same hardware frequency: 1
  CPUs which need to have their frequency coordinated by software: 1
  maximum transition latency: 0.97 ms.
  hardware limits: 800 MHz - 4.30 GHz
  available cpufreq governors: performance, powersave
  current policy: frequency should be within 800 MHz and 4.30 GHz.
                  The governor "powersave" may decide which speed to use
                  within this range.
  current CPU frequency is 1.84 GHz.


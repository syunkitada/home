# SSD

## TOSHIBA THNSNJ256GCSU
* type MLC
* sequential read: 534 MB/s {510 MiB/s}
* sequential write: 482 MB/s {460 MiB/s}
* MTTF 1,500,000 時間

### smartctl
```
$ sudo smartctl -i /dev/sda
smartctl 6.5 2016-01-24 r4214 [x86_64-linux-4.4.0-59-generic] (local build)
Copyright (C) 2002-16, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Device Model:     TOSHIBA THNSNJ256GCSU
Serial Number:    359S10DDT7SW
LU WWN Device Id: 5 00080d 9103488e2
Firmware Version: JURA0101
User Capacity:    256,060,514,304 bytes [256 GB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    Solid State Device
Form Factor:      2.5 inches
Device is:        Not in smartctl database [for details use: -P showall]
ATA Version is:   ACS-2 (minor revision not indicated)
SATA Version is:  SATA 3.1, 6.0 Gb/s (current: 6.0 Gb/s)
Local Time is:    Sun Feb 25 21:32:56 2018 JST
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

$ sudo smartctl -t short /dev/sdb
$ sudo smartctl -l selftest /dev/sdb
=== START OF READ SMART DATA SECTION ===
SMART Self-test log structure revision number 1
Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
# 1  Short offline       Completed without error       00%      4758         -
```


## Colorful SL500 320GB
* type TLC
* sequential read: 530MB/s
* sequential write: 450MB/s
* random read: 50,000 IOPS
* random write: 75,000 IOPS
* MTBF: 150時間

### smartctl
```
$ sudo smartctl -i /dev/sdb
smartctl 6.5 2016-01-24 r4214 [x86_64-linux-4.4.0-59-generic] (local build)
Copyright (C) 2002-16, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Device Model:     Colorful SL500 320GB
Serial Number:    AA000000000000001780
Firmware Version: Q0616B0
User Capacity:    320,072,933,376 bytes [320 GB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    Solid State Device
Form Factor:      2.5 inches
Device is:        Not in smartctl database [for details use: -P showall]
ATA Version is:   ACS-2 T13/2015-D revision 3
SATA Version is:  SATA 3.2, 6.0 Gb/s (current: 6.0 Gb/s)
Local Time is:    Sun Feb 25 20:32:41 2018 JST
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

$ sudo smartctl -t short /dev/sdb
$ sudo smartctl -l selftest /dev/sdb
=== START OF READ SMART DATA SECTION ===
SMART Self-test log structure revision number 1
Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
# 1  Short offline       Completed without error       00%         0         -
```

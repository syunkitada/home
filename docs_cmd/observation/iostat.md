# iostat

- iostat は、指定されたインターバルごとに/proc/diskstats を読んで、 統計情報の計算を行って出力する
- https://www.kernel.org/doc/Documentation/iostats.txt
- ソースコード
  - https://github.com/sysstat/sysstat/blob/master/iostat.c

```
752 void read_diskstats_stat_work(int curr, char *diskstats)
753 {
...
772         /* major minor name rio rmerge rsect ruse wio wmerge wsect wuse running use aveq dcio dcmerge dcsect dcuse flio fltm */
773         i = sscanf(line, "%u %u %s %lu %lu %lu %lu %lu %lu %lu %u %u %u %u %lu %lu %lu %u %lu %u",
774                &major, &minor, dev_name,
775                &rd_ios, &rd_merges_or_rd_sec, &rd_sec_or_wr_ios, &rd_ticks_or_wr_sec,
776                &wr_ios, &wr_merges, &wr_sec, &wr_ticks, &ios_pgr, &tot_ticks, &rq_ticks,
777                &dc_ios, &dc_merges, &dc_sec, &dc_ticks,
778                &fl_ios, &fl_ticks);
779
780         if (i >= 14) {
781             sdev.rd_ios     = rd_ios;
782             sdev.rd_merges  = rd_merges_or_rd_sec;
783             sdev.rd_sectors = rd_sec_or_wr_ios;
784             sdev.rd_ticks   = (unsigned int) rd_ticks_or_wr_sec;
785             sdev.wr_ios     = wr_ios;
786             sdev.wr_merges  = wr_merges;
787             sdev.wr_sectors = wr_sec;
788             sdev.wr_ticks   = wr_ticks;
789             sdev.ios_pgr    = ios_pgr;
790             sdev.tot_ticks  = tot_ticks;
791             sdev.rq_ticks   = rq_ticks;
792
793             if (i >= 18) {
794                 /* Discard I/O */
795                 sdev.dc_ios     = dc_ios;
796                 sdev.dc_merges  = dc_merges;
797                 sdev.dc_sectors = dc_sec;
798                 sdev.dc_ticks   = dc_ticks;
799             }
800
801             if (i >= 20) {
802                 /* Flush I/O */
803                 sdev.fl_ios     = fl_ios;
804                 sdev.fl_ticks   = fl_ticks;
805             }
806         }
```

## References

- [iostat -x の出力を Linux Kernel ソースコードから理解する](https://blog.etsukata.com/2013/10/iostat-x-linux-kernel.html)
- [iostat の値はどこから来るのか](https://qiita.com/sato4557/items/b2e966d0777796778dfe)

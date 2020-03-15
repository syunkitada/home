# カーネルパニック

## Double Fault

- 例外処理中に、何らかの理由により処理できない場合に発生する
- CPU によって発生することが多いが、Kernel のバグによって発生することもある
- 基本的にユーザ空間で発生するものではない
- また、Double Fault の発生中に、何らかの理由により処理できない場合は Triple Fault が発生し、CPU が Shutdown する

# nmi_watchdog

- watchdog は、カーネルハング（カーネルストール）を検出し、カーネルハング時にカーネルパニックさせる。
- 定期的に CPU に対して NMI 割り込み(NonMaskable Interapt)を発生させる。
- カウンタ値を確認し、前回の値から変化がない場合にはをインクリメントする。
- エラーカウンタが一定以上の値になった際、カーネルハングとみなしてパニックとなる

## sysrq により明示的に誘発する

```
goapp@ubuntu:/$ sudo sh -c 'echo c > /proc/sysrq-trigger'
[sudo] password for goapp:
[33742.800945] sysrq: SysRq : This sysrq operation is disabled.

goapp@ubuntu:/$ sudo sysctl -w kernel.sysrq=1
kernel.sysrq = 1

goapp@ubuntu:/$ sudo sh -c 'echo c > /proc/sysrq-trigger'
[33992.507658] sysrq: SysRq : Trigger a crash
[33992.508433] BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
...
```

## Sysctl

```
kernel.hardlockup_panic = 0
kernel.hung_task_panic = 0
kernel.panic = 0
kernel.panic_on_io_nmi = 0
kernel.panic_on_oops = 0
kernel.panic_on_rcu_stall = 0
kernel.panic_on_unrecovered_nmi = 0
kernel.panic_on_warn = 0
kernel.panic_print = 0
kernel.softlockup_panic = 0
kernel.unknown_nmi_panic = 0
vm.panic_on_oom = 0
```

## kdump

- kdump は、クラッシュ時にメモリ内容をファイルに保存する機能
- kdump を利用するには、システムカーネルとは別にダンプキャプチャカーネルが必要
  - システムカーネルがクラッシュすると、通常はメモリの内容は失われる
  - kdump からキックされる kexec によってダンプキャプチャカーネルを起動され、メモリの内容を保存する
  - ダンプキャプチャカーネルはあらかじめシステムカーネルのメモリ領域に読み込ませておく必要がある

### ubuntu

- https://help.ubuntu.com/lts/serverguide/kernel-crash-dump.html

```
$ sudo apt-get install kdump-tools
$ sudo grep crash /etc/default/grub.d/kdump-tools.cfg
GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT crashkernel=512M-:192M"
$ sudo update-grub
$ sudo reboot
$ cat /proc/cmdline
... crashkernel=512M-:192M
```

- crashkernel=512M-:192M
  - メモリが 512M-以上なら、192M を確保する
  - そうでないなら、メモリを確保しない

## crash によるデバッグ

```

\$ crash .../vmcore

```

```

```

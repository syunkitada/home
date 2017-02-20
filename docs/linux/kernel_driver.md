# カーネルデバイスドライバ

``` bash
$ sudo yum install make gcc kernel kernel-devel kernel-headers

$ sudo reboot

$ rpm -qa | grep kernel
kernel-3.10.0-327.el7.x86_64
kernel-devel-3.10.0-514.6.1.el7.x86_64
kernel-3.10.0-514.6.1.el7.x86_64
kernel-tools-3.10.0-327.el7.x86_64
kernel-headers-3.10.0-514.6.1.el7.x86_64
kernel-tools-libs-3.10.0-327.el7.x86_64

$ uname -r
3.10.0-514.6.1.el7.x86_64
```

hello.c
```
/**
 * @file    hello.c
 * @author  Derek Molloy
 * @date    4 April 2015
 * @version 0.1
 * @brief  An introductory "Hello World!" loadable kernel module (LKM) that can display a message
 * in the /var/log/kern.log file when the module is loaded and removed. The module can accept an
 * argument when it is loaded -- the name, which appears in the kernel log files.
 * @see http://www.derekmolloy.ie/ for a full description and follow-up descriptions.
*/

#include <linux/init.h>             // Macros used to mark up functions e.g., __init __exit
#include <linux/module.h>           // Core header for loading LKMs into the kernel
#include <linux/kernel.h>           // Contains types, macros, functions for the kernel

MODULE_LICENSE("GPL");              ///< The license type -- this affects runtime behavior
MODULE_AUTHOR("Derek Molloy");      ///< The author -- visible when you use modinfo
MODULE_DESCRIPTION("A simple Linux driver for the BBB.");  ///< The description -- see modinfo
MODULE_VERSION("0.1");              ///< The version of the module

static char *name = "world";        ///< An example LKM argument -- default value is "world"
module_param(name, charp, S_IRUGO); ///< Param desc. charp = char ptr, S_IRUGO can be read/not changed
MODULE_PARM_DESC(name, "The name to display in /var/log/kern.log");  ///< parameter description

/** @brief The LKM initialization function
 *  The static keyword restricts the visibility of the function to within this C file. The __init
 *  macro means that for a built-in driver (not a LKM) the function is only used at initialization
 *  time and that it can be discarded and its memory freed up after that point.
 *  @return returns 0 if successful
 */
static int __init helloBBB_init(void){
   printk(KERN_INFO "EBB: Hello %s from the BBB LKM!\n", name);
   return 0;
}

/** @brief The LKM cleanup function
 *  Similar to the initialization function, it is static. The __exit macro notifies that if this
 *  code is used for a built-in driver (not a LKM) that this function is not required.
 */
static void __exit helloBBB_exit(void){
   printk(KERN_INFO "EBB: Goodbye %s from the BBB LKM!\n", name);
}

/** @brief A module must use the module_init() module_exit() macros from linux/init.h, which
 *  identify the initialization function at insertion time and the cleanup function (as
 *  listed above)
 */
module_init(helloBBB_init);
module_exit(helloBBB_exit);
```

Makefile
```
obj-m+=hello.o

all:
        make -C /lib/modules/$(shell uname -r)/build/ M=$(PWD) modules
clean:
        make -C /lib/modules/$(shell uname -r)/build/ M=$(PWD) clean
```

```
$ ls
Makefile  hello.c

$ make

$ ls
Makefile  Module.symvers  hello.c  hello.ko  hello.mod.c  hello.mod.o  hello.o  modules.order

# insmodコマンドはカレントディレクトリにあるドライバをロードするためのもの
# modprobeコマンドは「/lib/modules/`uname -r`」からドライバを探してロードする
$ sudo insmod hello.ko

$ modinfo hello.ko
filename:       /home/fabric/helloworld/hello.ko
version:        0.1
description:    A simple Linux driver for the BBB.
author:         Derek Molloy
license:        GPL
rhelversion:    7.3
srcversion:     0DD9FE0DE42157F9221E608
depends:
vermagic:       3.10.0-514.6.1.el7.x86_64 SMP mod_unload modversions
parm:           name:The name to display in /var/log/kern.log (charp)


# vermagic: ビルドした環境のカーネルバージョン SMP(マルチプロセッサ対応) mod_unload(ドライバアンロード可)
# vermagic:       3.10.0-514.6.1.el7.x86_64 SMP mod_unload modversions

$ lsmod | grep hello
#       Size(メモリサイズ) Used(参照カウンタ)  by(依存ドライバ）
hello   12535              0

$ cat /proc/modules | grep hello
hello 12535 0 - Live 0xffffffffa04e9000 (OE)

$ ls /sys/module/ | grep hello
hello

$ ls /sys/module/hello
coresize  initsize   notes       refcnt       sections    taint   version
holders   initstate  parameters  rhelversion  srcversion  uevent

$ sudo rmmod hello.ko
$ lsmod  | grep hello
```

# Refereces
* [Writing a Linux Kernel Module ? Part 1: Introduction](http://derekmolloy.ie/writing-a-linux-kernel-module-part-1-introduction/)

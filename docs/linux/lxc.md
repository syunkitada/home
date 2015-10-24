# lxc

$ sudo yum install epel-release
$ sudo yum install lxc, lxc-templates, wget, bridge-utils

$ sudo brctl addbr virbr0
$ sudo ip link set dev virbr0 up


# 非特権コンテナ
$ sudo vim /etc/lxc/lxc-usernet
owner veth lxcbr0 10

非特権ユーザに与えるネットワークデバイスの範囲を設定するために使う /etc/lxc/lxc-usernet を設定します。 デフォルトでは、ホスト上で全くネットワークデバイスを割り当てできないことになっていますので、このファイルに以下のような設定を追加します:
これは、"your-username" にブリッジ lxcbr0 に接続する 10 個の veth デバイスの作成を許可するという意味です。

mkdir ~/.config/lxc/ -p
cp /etc/lxc/default.conf ~/.config/lxc/

$ vim ~/config/lxc/default.conf
lxc.network.type = veth
lxc.network.link = virbr0
lxc.network.flags = up
> lxc.id_map = u 0 100000 65536
> lxc.id_map = g 0 100000 65536

$ sudo lxc-create -t download -n my-container
Setting up the GPG keyring
Downloading the image index

---
DIST    RELEASE ARCH    VARIANT BUILD
---
centos  6       amd64   default 20151024_02:16
centos  6       i386    default 20151024_02:16
centos  7       amd64   default 20151024_02:16
debian  jessie  amd64   default 20151023_22:42
debian  jessie  armel   default 20151023_22:42
debian  jessie  armhf   default 20151023_22:42
debian  jessie  i386    default 20151023_22:42
debian  sid     amd64   default 20151024_04:12
debian  sid     armel   default 20151023_22:42
debian  sid     armhf   default 20151023_22:42
debian  sid     i386    default 20151024_04:12
debian  squeeze amd64   default 20151023_22:42
debian  squeeze armel   default 20150826_22:42
debian  squeeze i386    default 20151023_22:42
debian  wheezy  amd64   default 20151023_22:42
debian  wheezy  armel   default 20151023_22:42
debian  wheezy  armhf   default 20151023_22:42
debian  wheezy  i386    default 20151023_22:42
fedora  19      amd64   default 20150618_01:27
fedora  19      armhf   default 20150621_01:27
fedora  19      i386    default 20150619_01:27
fedora  20      amd64   default 20150619_01:27
fedora  20      armhf   default 20150621_01:27
fedora  20      i386    default 20150619_01:27
fedora  21      amd64   default 20151024_01:27
fedora  21      armhf   default 20151024_01:27
fedora  21      i386    default 20151024_01:27
fedora  22      amd64   default 20151024_01:27
fedora  22      armhf   default 20151024_01:27
fedora  22      i386    default 20151024_01:27
gentoo  current amd64   default 20151024_04:12
gentoo  current armhf   default 20151019_14:12
gentoo  current i386    default 20151024_04:12
oracle  6.5     amd64   default 20151024_04:13
oracle  6.5     i386    default 20151024_04:13
plamo   5.x     amd64   default 20151023_21:36
plamo   5.x     i386    default 20151023_21:36
ubuntu  precise amd64   default 20151024_04:13
ubuntu  precise armel   default 20151023_20:20
ubuntu  precise armhf   default 20151023_20:20
ubuntu  precise i386    default 20151024_04:13
ubuntu  trusty  amd64   default 20151024_04:13
ubuntu  trusty  arm64   default 20150604_03:49
ubuntu  trusty  armhf   default 20151023_20:20
ubuntu  trusty  i386    default 20151024_04:13
ubuntu  trusty  ppc64el default 20151024_04:13
ubuntu  vivid   amd64   default 20151024_04:13
ubuntu  vivid   arm64   default 20150604_03:49
ubuntu  vivid   armhf   default 20151023_20:20
ubuntu  vivid   i386    default 20151024_04:13
ubuntu  vivid   ppc64el default 20151024_04:13
ubuntu  wily    amd64   default 20151024_04:13
ubuntu  wily    arm64   default 20150604_03:49
ubuntu  wily    armhf   default 20151023_20:20
ubuntu  wily    i386    default 20151024_04:13
ubuntu  wily    ppc64el default 20151024_04:13
---

Distribution: centos
Release: 7
Architecture: amd64

Downloading the image index
Downloading the rootfs

...
...

---
You just created a CentOS container (release=7, arch=amd64, variant=default)

To enable sshd, run: yum install openssh-server

For security reason, container images ship without user accounts
and without a root password.

Use lxc-attach or chroot directly into the rootfs to set a root password
or create user accounts.

```


$ sudo lxc-start -n my-container -d
$ sudo lxc-info -n my-container
Name:           my-container
State:          RUNNING
PID:            2388
CPU use:        0.05 seconds
BlkIO use:      13.52 MiB
Memory use:     7.55 MiB
KMem use:       0 bytes
Link:           vethQ8CYGJ
 TX bytes:      648 bytes
 RX bytes:      648 bytes
 Total bytes:   1.27 KiB

$ sudo lxc-ls -f
my-container


$ sudo lxc-attach -n my-container

$ sudo lxc-stop -n my-container
$ sudo lxc-destroy -n my-container

# Ubuntu のアップグレード方法

以下のファイルで Prompt=lts となってるのを確認してください  
以下の場合はアップグレードの対象は LTS に限定されます

```
$ cat /etc/update-manager/release-upgrades
# Default behavior for the release upgrader.

[DEFAULT]
# Default prompting and upgrade behavior, valid options:
#
#  never  - Never check for, or allow upgrading to, a new release.
#  normal - Check to see if a new release is available.  If more than one new
#           release is found, the release upgrader will attempt to upgrade to
#           the supported release that immediately succeeds the
#           currently-running release.
#  lts    - Check to see if a new LTS release is available.  The upgrader
#           will attempt to upgrade to the first LTS release available after
#           the currently-running one.  Note that if this option is used and
#           the currently-running release is not itself an LTS release the
#           upgrader will assume prompt was meant to be normal.
Prompt=lts
```

以下の手順で、アップグレードを実施できます

```
# 現在のバージョンを確認する
$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 18.04.6 LTS
Release:        18.04
Codename:       bionic

# パッケージを最新にしておく
$ sudo apt update
$ sudo apt full-upgrade -y
$ sudo apt --purge autoremove -y
$ sudo reboot

# アップグレードを実施
# 適宜、'yes', 'no' を聞かれるので確認しつつ入力する（基本的に 'y' を押してればOK）
# 最後にrebootするかを聞かれるので、問題なければ 'y' を押してrebootする
$ sudo do-release-upgrade

# リブート後にバージョンを確認する
$ uname -mrs
Linux 5.4.0-122-generic x86_64

$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 20.04.4 LTS
Release:        20.04
Codename:       focal
```

### 新しいメジャーリリースが出てるのにアップグレードできない場合

```
# do-release-upgradeを実行しても、新しいLTSがないと表示されません
$ sudo do-release-upgrade
Checking for a new Ubuntu release
There is no development version of an LTS available.
To upgrade to the latest non-LTS development release
set Prompt=normal in /etc/update-manager/release-upgrades.
```

一般ユーザ向けは、ある程度の安定性が求められるため 22.04.0 が出ても 22.04.1 がでるまでは表示されません  
もし、強制的にインストールしたい場合は -d, --devel-release オプションを付けることでインストールできます

```
$ sudo do-release-upgrade -d
```

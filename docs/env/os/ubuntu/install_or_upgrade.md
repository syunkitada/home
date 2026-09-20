# Install Ubuntu

## How to install

以下を参考にLiveUSB を作成して、インストールします。

- https://rufus.ie/
- https://www.ubuntu.com/

## How to upgrade

メジャーアップグレードは、対象リリースの公式リリースノートを確認したうえで実施します。開始前にバックアップを取得し、空き容量、第三者リポジトリ、復旧手段を確認してください。LTSからLTSへは原則として連続するリリースを順番に更新します。

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
# 削除されるパッケージや設定変更の内容を 'yes', 'no' で聞かれるので確認してから進める（基本的に 'y' を押してればOK）
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

一般ユーザ向けは、ある程度の安定性が求められるため、LTSの最初のポイントリリースが出るまで次のLTSへのアップグレードが表示されないことがあります。
`-d` または `--devel-release` は開発版へのアップグレードを指定するオプションです。通常の環境や本番環境で、アップグレードを強制する目的では使用しないでください。

```
# 検証環境で開発版を試す場合のみ
$ sudo do-release-upgrade -d
```

## Example: upgrade to Ubuntu 24.04

以下は Ubuntu 22.04 から 24.04 へ更新したときの記録です。現在の対象リリースやアップグレード可否は、利用中のUbuntuバージョンに対応する公式ドキュメントで確認してください。

```
$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 22.04.4 LTS
Release:        22.04
Codename:       jammy


# パッケージを最新にしておく
$ sudo apt update
$ sudo apt full-upgrade -y
$ sudo apt --purge autoremove -y
$ sudo reboot
```

```
$ sudo do-release-upgrade
Checking for a new Ubuntu release

= Welcome to Ubuntu 24.04 LTS 'Noble Numbat' =

The Ubuntu team is proud to announce Ubuntu 24.04 LTS 'Noble Numbat'.

To see what's new in this release, visit:
  https://wiki.ubuntu.com/NobleNumbat/ReleaseNotes
...
```

After reboot:

```
$ cat /etc/os-release
PRETTY_NAME="Ubuntu 24.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.3 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo
```

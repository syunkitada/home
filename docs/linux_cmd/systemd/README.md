# systemd

## systemd とは

- systemd は最初に起動するプロセス(PID=1)で Linux の起動処理や、Linux システムの管理を行う
- systemd の登場以前では SysVinit が起動処理を担っていた
  - SysVinit では init プロセス(PID=1)が最初に起動する
- すべてのプロセスは systemd の子プロセスとなる
- systemd に関連したプロセスとして以下がある
  - systemd-journald
  - systemd-logind
  - systemd-resolved
  - systemd-machined
    - 仮想マシンプロセス追跡プロセス

## 仕組み

- systemd は、Unit という単位でサービスを管理する
- Unit には依存と順序の関係が定義できる
- runlevel ごとに設定された target を default.target の Unit として、そこに記述されている依存関係を満たすように、各 Unit を立ち上げていく

```
# runlevelを確認
$ runlevel
N 3

# デフォルトのtargetを確認
$ systemctl get-default
multi-user.target

# targetの実態
$ ls -l /lib/systemd/system/ | grep runlevel
lrwxrwxrwx. 1 root root   15  4月 22  2020 runlevel0.target -> poweroff.target
lrwxrwxrwx. 1 root root   13  4月 22  2020 runlevel1.target -> rescue.target
drwxr-xr-x. 2 root root   50  4月 22  2020 runlevel1.target.wants
lrwxrwxrwx. 1 root root   17  4月 22  2020 runlevel2.target -> multi-user.target
drwxr-xr-x. 2 root root   50  4月 22  2020 runlevel2.target.wants
lrwxrwxrwx. 1 root root   17  4月 22  2020 runlevel3.target -> multi-user.target
drwxr-xr-x. 2 root root   50  4月 22  2020 runlevel3.target.wants
lrwxrwxrwx. 1 root root   17  4月 22  2020 runlevel4.target -> multi-user.target
drwxr-xr-x. 2 root root   50  4月 22  2020 runlevel4.target.wants
lrwxrwxrwx. 1 root root   16  4月 22  2020 runlevel5.target -> graphical.target
drwxr-xr-x. 2 root root   50  4月 22  2020 runlevel5.target.wants
lrwxrwxrwx. 1 root root   13  4月 22  2020 runlevel6.target -> reboot.target
-rw-r--r--. 1 root root  761  4月  7  2020 systemd-update-utmp-runlevel.service
```

- multi-user.target が完了したら、/lib/systemd/system/multi-user.target.wants, /etc/systemd/system/multi-user.target.wants 内のすべての Unit が開始される
- systemctl enable [unit] でサービスの自動起動を有効化すると、/etc/systemd/system/multi-user.target.wants にシンボリックリンクが作成される

```
$ ls /lib/systemd/system/multi-user.target.wants
dbus.service  getty.target  systemd-ask-password-wall.path  systemd-logind.service  systemd-update-utmp-runlevel.service  systemd-user-sessions.service

$ ls /etc/systemd/system/multi-user.target.wants
auditd.service   crond.service       kdump.service      postfix.service   rhel-configure.service  rsyslog.service  tuned.service
chronyd.service  irqbalance.service  nfs-client.target  remote-fs.target  rpcbind.service         sshd.service
```

- systemctl list-dependencies で、default.target を起点とした依存関係のツリーを確認できる
- 緑は成功、赤は失敗、白はその他(依存関係が満たされず、起動されなかった、など)

```
$ systemctl list-dependencies
```

- systemctl list-unit-files で、各 Unit ファイルを確認できる

```
$ systemctl list-units --type target
$ systemctl list-unit-files --type=service
```

## Unit の種類

- .service
  - プロセスの起動・停止に関する設定
- .socket
  - ソケットの監視設定 -ソケットへの接続を検出すると特定のプロセスを起動”といった動作を実現可
- .mount
  - ファイルシステムのマウント／アンマウントに関する設定
  - ファイル名は「マウントポイント.mount」となる
  - /etc/fstab の内容を元に Systemd が自動作成する
- .udev
  - システムが認識しているデバイス情報を保持する
  - udev デーモンによって自動作成される
- .path
  - パスの監視設定
  - 監視ディレクトリにファイルが置かれたらサービス起動”といった動作を実現可
- .target
  - 複数の Unit をとりまとめる Unit

## watchdog

## 参考

- [RHEL 7 における systemd の概要](https://access.redhat.com/ja/articles/1379593)

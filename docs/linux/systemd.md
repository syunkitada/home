# Systemd

## systemd

## initscript

- centos6 では、/etc/init.d/にデーモンサービス用の initscript を配置します
  - centos7 でも、systemd 用のサービスを使わずに initscript を利用する場合もある
- initscript の中身はただのシェルスクリプトで、 これが service や chkconfig コマンドから呼び出されて、 サービスの start, stop, restart などを提供します
- 作り方
  - ひな形が、/usr/share/doc/initscripts-\*/svsvinitfiles にあるので、これを/etc/init.d に入れて使うといい
  - 基本的にサンプルの中に作り方などがすべて書かれているので、それを参考にすると initscript が作成できます
  - 既存の initscript を参考するのも良い

```bash
$ sudo cp /usr/share/doc/initscripts-9.03.46/sysvinitfiles /etc/init.d/openstack-keystone
$ sudo chmod 755 /etc/init.d/openstack-keystone
```

## edit

```
systemd edit tuned
```

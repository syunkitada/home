# initscript

centosでは、/etc/init.d/にデーモンサービス用のinitscriptを配置します。

initscriptの中身はただのシェルスクリプトで、
これがserviceやchkconfigコマンドから呼び出されて、
サービスのstart, stop, restartなどを提供します。


## 作り方
ひな形が、  
/usr/share/doc/initscripts-*/svsvinitfiles  
にあるので、これを/etc/init.dに入れて使うといいです。
基本的にサンプルの中に作り方などがすべて書かれているので、
それを参考にするとinitscriptが作成できます。(既存のinitscriptを参考するのも良いです。)

``` bash
% sudo cp /usr/share/doc/initscripts-9.03.46/sysvinitfiles /etc/init.d/openstack-keystone
% sudo chmod 755 /etc/init.d/openstack-keystone
```

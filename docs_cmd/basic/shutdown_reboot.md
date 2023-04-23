# shutdown, reboot

[DOC] 電源管理をします

## shutdown

```
$ shutdown [ -t sec ] [-arkhcfF ] time [ message ] [now]

# システムを停止する
$ sudo shutdown -h now

# リブートする
$ sudo shutdown -r now

# 実行中のシャットダウンをキャンセルする
$ sudo shutdown -c
```

## reboot

```
# 通常リブート
$ sudo reboot

# shutdownを起動せずに、強制的にhaltまたはrebootする
$ sudo reboot -f

# システムを停止する時に、電源を切る
$ sudo reboot -p
```

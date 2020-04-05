# Etheriumの掘り方


## ウォレット・アドレスの準備
やり方は2通り
* 個人で作成する
    * 以下のコマンドで作成できる
        * $ geth account new
    * 以下のようなアドレス(公開鍵)が出力されるので、このアドレスを掘るときに利用する
        * 3f01b267f52f8204a9fcd6ff2ca6711f509c7542
    * ローカルで管理しているaccountの一覧は以下で確認できる
    * 秘密鍵の場所もここに書かれている
        * geth account list
* bitflyerなどの取引所でアドレスを作成する（現金化するならこっち)
    * このアドレスを掘るときに利用する


## 環境準備
* 環境は、Ubuntu16、GPX1060
* cudaのインストール
```
sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
sudo apt update
sudo apt install cuda cuda-drivers

sudo reboot
```

## ethminerをダウンロードして、以下を実行してマイニング開始
* pool、[your address]は適宜書き換えてください
```
$ ./ethminer --farm-recheck 200 -U -S asia1.ethermine.org:4444 -FS asia1.ethermine.org:14444 -O [your address]
```


## おまけ: pinningしてみた
* 結果は効果なし、そもそもGPUの性能で掘り効率が変わるのでCPUをpinningしたところで意味がない
```
# isolの設定
$ sudo vim /etc/default/grub
GRUB_CMDLINE_LINUX="isolcpus=1"

$ sudo grub-mkconfig -o /boot/grub/grub.cfg
$ sudo reboot

$ cat /proc/cmdline
BOOT_IMAGE=/boot/vmlinuz-4.4.0-59-generic root=UUID=c5a29305-9548-4405-a4d2-5687eda29d87 ro isolcpus=1 quiet splash vt.handoff=7

# tasksetでisolしたコアにpinningして実行
$ taskset -c 1 ./ethminer --farm-recheck 200 -U -S asia1.ethermine.org:4444 -FS asia1.ethermine.org:14444 -O [your address]

# pinningの確認
$ ps ax | grep eth
2875 pts/1    Sl+    0:02 ./ethminer --farm-recheck 200 -U -S asia1.ethermine.org:4444 -FS asia1.ethermine.org:14444 -O xxxx
$ cat /proc/2875/status | grep Cpus
Cpus_allowed:   2
Cpus_allowed_list:      1
```


## モニタリング
* 基本的にGPUが100%張り付いてて、その他のリソースはほとんど使われない
```
# cpuの温度を見る
$ watch -n 10 cat /sys/class/thermal/thermal_zone0/temp

# GPUの利用率、温度を見る
$ watch -n 10 nvidia-smi

# メモリを見る
$ vmstat 1

# CPUを見る
$ mpstat -P ALL 1

# プロセスを見る
$ pidstat 1 -r -u -p [etheminer pid]
```

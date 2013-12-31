home
====

自分用のホームディレクトリの設定ファイル群です。  
bash, vimなど。

以下、初期設定時のマニュアルです。

* [Windowsの設定](#windowsの設定)
* [CentOSの設定](#centosの設定)


## Windowsの設定

### cygwinのインストール
パッケージは、Defaultのものと、以下などをチェックしてインストール  
ついでに、KaoriYaのgvimや、puttyもまとめて置いとく

* develop
 * gccのコンパイラ各種(c, c++, objectiv-c など)
 * git
 * make
* editor
 * vim
 * vim-common

### homeディレクトリの変更
    $ vim /etc/passwd
      ユーザのホームディレクトリが、/home/<username> となっているので、
      /cygdrive/c/Users/<username> に書き変えて保存する

### mittyの設定
* Looksから、半透明に設定
* Textから、フォントを設定（MSゴシックとか）

### git の設定
    $ git config --global user.name "syunkitada"
    $ git config --global user.email "syun.kitada@gmail.com"
    $ git config --global core.autocrlf false

### sshの鍵作成
    $ ssh-keygen -t rsa -b 5096 -C "hoge@piyo.com"
    公開鍵(.ssh/id_rsa.pub)をgit_hubや、sshで利用するサーバのホームに置いておく
    
    秘密鍵からputtyのpagent用の秘密鍵(id_rsa.ppk)を作成しておく
    また、以下のようなショートカットを作成しておくと便利
    pagent.exe C:\Users\<username>\.ssh\id_rsa.ppk

    git-hubに公開鍵を登録して、接続テストしてみる
    $ ssh -T git@github.com
    
    gitでsshを利用する場合、環境変数GIT_SSHにputtyのplink.exeのパスをセットしておくとエージェント認証できる
    .bashrcに書いておこう
    $ export GIT_SSH=plinkパス
    
### 設定ファイルの配置
    $ git clone git@github.com:syunkitada/home.git
    $ cd home
    $ ./setup_win_clone_neobundle.sh
    
    エクスプローラからsetup_win.bat を管理者権限で実行
    （setup_win.batは、各種設定ファイルのシンボリックリンクをユーザディレクトリに配置する）
 
    .bashrc内で、plinkのパスを適宜変更



## CentOSの設定

CentOS-6.5-i386-minimal を想定  
サーバとしての用途を想定  

### ユーザの設定
    $ useradd hoge
    $ passwd hoge
    $ gpasswd -a hoge wheel
    $ visudo
      # 以下のコメントアウトを解除する
      %wheel ALL=(ALL) ALL

### ネットワークの設定
ブート時にネットワークに接続するようにする

    $ vi /etc/sysconfig/network-scripts/ifcfg-eth0
      ONBOOT=yes
    $ sudo service network restart

### パッケージのインストール

    $ sudo yum update
    $ sudo yum install git gcc vim wget

### sshの設定

    scpなどで、公開鍵(id_rsa.pub)をホームディレクトリに持ってくる
    $ mkdir .ssh
    $ chmod 700 .ssh
    $ cp id_rsa.pub .ssh/authorized_keys
    $ chmod 600 .ssh/authorized_keys

    これで、公開鍵を使ってのssh接続が可能になる
    接続テストができたら、rootでのログインとパスワード認証を無効にしておく

    $ sudo vi /etc/ssh/sshd_config
      PermitRootLogin no
      PasswordAuthentication no
    
    $ sudo service sshd restart

### 設定ファイルの配置
    $ git clone git@github.com:syunkitada/home.git
    $ cd home
    $ ./setup_cent.sh
    




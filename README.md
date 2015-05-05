home
====

自分用の環境設定に関するファイル群です。  
ドットファイル郡や各種設定ファイルなどを梱包しています。

## 目次
* [キーバインドについて](#キーバインドの設定)
* [Windowsの設定](#windowsの初期設定)
* [CentOSの設定](#centosの初期設定)


## キーバインドの設定
ユーザPCはWindows7を想定し、キーバインドの設定は基本的にautohotkeyで管理しています。  
詳しくは、[autohotkey](https://github.com/syunkitada/autohotkey)を参照してください。 

### チートシート
![mycheatsheet](http://dl.dropboxusercontent.com/u/29431105/shed/cheatsheats/mycheatsheet.png)


## Windowsの初期設定

### cygwinのインストール
パッケージは、Defaultのものと、以下などをチェックしてインストール  
ついでに、KaoriYaのgvimや、puttyもまとめて置いとく

* Develop
 * gccのコンパイラ各種(c, c++, objectiv-c など)
 * git
 * make
* Editor
 * vim
 * vim-common
* Net
 * bind-utils 
 * curl
 * openssl
 * wget
 * ping
* Python
 * python
 * python-crypto
* Utils
 * tmux

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
    // $ git config --global core.autocrlf false

### sshの鍵作成
    $ ssh-keygen -t rsa -b 5096 -C "hoge@piyo.com"
    
作成した公開鍵(.ssh/id_rsa.pub)は、git_hubや、sshで利用するサーバのホームに置いておく。
    
git-hubに公開鍵を登録したら、接続テストしてみる。
    
    $ ssh -T git@github.com
    
gitでsshを利用する場合、環境変数GIT_SSHにputtyのplink.exeのパスをセットしておくとエージェント認証できる。  
（.bashrcに書いておこう）

    $ export GIT_SSH=plinkパス

エージェント認証用に、秘密鍵からputtyのpagent用の秘密鍵(id_rsa.ppk)を作成しておく。  
また、以下のようなショートカットを作成しておくと便利です。

    pagent.exe C:\Users\<username>\.ssh\id_rsa.ppk

    
### 設定ファイルの配置
    $ git clone git@github.com:syunkitada/home.git
    $ cd home
    $ ./setup_win_clone_neobundle.sh
    
エクスプローラからsetup_win.bat を管理者権限で実行する。  
（setup_win.batは、各種設定ファイルのシンボリックリンクをユーザディレクトリに配置する）
 
.bashrc内で、plinkのパスを適宜変更します。

### vimの設定
コンソールからvimを立ち上げると、neobundleがプラグインをインストールします。

この時点だと、vimshellがvimからは使えるが、gvimからは使えない。（vimprocのコンパイル環境が異なるため）  
なので、gvimがあるフォルダのplugins/vimproc/autoload/vimproc_win64.dll を.vim/bundle/vimproc/autoload/にコピーする必要がある。  
また、cygwin64/bin のパスを通しておくことで、gvimのvimshellからコマンドが実行できるようになる。

### pythonの設定
1. [setuptools](https://pypi.python.org/pypi/setuptools) のインストール
    * [ez_setup.py](https://bootstrap.pypa.io/ez_setup.py) をダウンロードして、"$ python ez_setup.py" を実行
2. pipとその他パッケージのインストール
   ``` bash
   $ easy_install pip
  
   $ pip install flake8
   $ pip install fabric
   ```

### xampp環境
* xamppインストール
* xampp/php, xampp/perl/bin をWindowsのPATHに追加
* php.confのopenssl 有効にしたり


## CentOSの初期設定

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
ブート時にネットワークに接続するようにする。

    $ vi /etc/sysconfig/network-scripts/ifcfg-eth0
      ONBOOT=yes
    $ sudo service network restart

### sshの設定

事前に、scpなどで公開鍵(id_rsa.pub)をホームディレクトリに持ってくる。

    $ mkdir .ssh
    $ chmod 700 .ssh
    $ cp id_rsa.pub .ssh/authorized_keys
    $ chmod 600 .ssh/authorized_keys

これで、公開鍵を使ってのssh接続が可能になる。
接続テストができたら、rootでのログインとパスワード認証を無効にしておく。

    $ sudo vi /etc/ssh/sshd_config
      PermitRootLogin no
      PasswordAuthentication no
    
    $ sudo service sshd restart


### 設定ファイルの配置
    $ git clone git@github.com:syunkitada/home.git
    $ cd home
    $ ./setup_cent.sh


### パッケージのインストール
    # tmuxとvimをインストール
    $ ./install_local all
    
    # pipのインストール
    $ ./install_pip




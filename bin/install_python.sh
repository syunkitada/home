#!/bin/sh

# python開発環境のためのセットアップスクリプトです

pushd tmp
# python-devel, libxml2-devel, libxslt-devel, libevent-devel
# pipはソースからインストールしようとするのでビルド環境を整える必要がある
sudo yum install python-devel libxml2-devel libxslt-devel libevent-devel

wget http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tgz
tar xzvf Python-2.7.3.tgz
cd Python-2.7.3
./configure --enable-shared --with-threads
make
sudo make install
sudo cp libpython2.7.so libpython2.7.so.1.0 /usr/lib
sudo ldconfig

# pipのインストール
wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | sudo python
rm -rf setuptools*

# pipは、setuptoolsに含まれているeasy_installの置き換えとして開発されているものです
sudo easy_install pip
popd


# flake8は、コーディングルールをチェックするpep8とシンタックスチェックをするPyFlakes合わせたものです
sudo pip install flake8

# 
sudo pip install jedi

# コードチェック
# $ flake8 [file path]


# virtualenv, wrapperはpythonの仮想化環境を作成し、
# pythonをバージョンごとに管理するためのものです
sudo pip install virtualenv
sudo pip install virtualenvwrapper

# virtualenv環境の作成
# $ mkvirtualenv env-hogehoge

# アクティベート
# $ workon env-hogehoge

# ディアクティベート
# $ deactivate

# 現在のvirtualenv環境を表示するために .bash_profileに以下を追記しとく
# export WORKON_HOME=$HOME/.virtualenvs
# source `which virtualenvwrapper.sh`

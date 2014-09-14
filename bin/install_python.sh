#!/bin/sh

# python開発環境のためのセットアップスクリプトです

pushd tmp
# * python-devel, libxml2-devel, libxslt-devel は、setup.pyでbuild, installするために必要
sudo yum install python-devel libxml2-devel libxslt-devel

# distributeのインストール
# distributeは、setuptoolsの互換パッケージです
# （setuptoolsは、ほとんどメンテナンスされていないので、こっちのが良い）
# distribute_setup.pyは、distributeをインストールするためのスクリプトです
wget http://python-distribute.org/distribute_setup.py
sudo python distribute_setup.py
rm -rf distribute*

# pipは、setuptoolsに含まれているeasy_installの置き換えとして開発されているものです
sudo easy_install pip
popd


# flake8は、コーディングルールをチェックするpep8とシンタックスチェックをするPyFlakes合わせたものです
sudo pip install flake8

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

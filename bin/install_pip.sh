pushd tmp
sudo yum install python-devel libxml2-devel libxslt-devel
wget http://python-distribute.org/distribute_setup.py
sudo python distribute_setup.py
sudo easy_install pip
popd


# * python-devel, libxml2-devel, libxslt-devel は、setup.pyでbuild, installするために必要。
# distribute_setup.pyは、distributeをインストールするためのスクリプトです。  
# distributeは、setuptoolsの互換パッケージです。  
# （setuptoolsは、ほとんどメンテナンスされていないので、こっちのが良い）
# pipは、setuptoolsに含まれているeasy_installの置き換えとして開発されているものです。

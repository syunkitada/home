pushd tmp
sudo yum install python-devel libxml2-devel libxslt-devel
wget http://python-distribute.org/distribute_setup.py
sudo python distribute_setup.py
sudo easy_install pip
popd

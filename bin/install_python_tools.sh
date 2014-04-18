#!/bin/sh

sudo yum install python-devel libxml2-devel libxslt-devel
curl -L http://python-distribute.org/distribute_setup.py | sudo python
rm -rf distribute-*.tar.gz
sudo easy_install pip

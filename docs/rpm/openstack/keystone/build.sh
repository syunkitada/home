#!/bin/bash -xe

cd ../
TOP_DIR=/tmp/keystone/master/rpmbuild
SRC_DIR=$TOP_DIR/SOURCES
rm -rf $TOP_DIR
mkdir -p $SRC_DIR
tar -cf $SRC_DIR/keystone.tar.gz keystone
cd keystone

rpmbuild --bb keystone.spec \
    --define "_topdir /tmp/keystone/master/rpmbuild" 

#!/bin/bash

set +ex

OS_NAME=$(grep "^NAME=" /etc/os-release | awk -F '=' '{print $2}' | sed -e 's/"//g' | awk -F ' ' '{print $1}')
OS_VERSION=$(grep "^VERSION_ID=" /etc/os-release | awk -F '=' '{print $2}' | sed -e 's/"//g' | awk -F '.' '{print $1}')

echo "OS_NAME=$OS_NAME, OS_VERSION=$OS_VERSION"
if [ "$OS_NAME" = "Rocky" ]; then
	source ./setup_rocky8.sh
fi
if [ "$OS_NAME" = "Ubuntu" ]; then
	echo "hoge"
	# source ./setup_ubuntu20
fi

setup_init

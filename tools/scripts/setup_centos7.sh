#!/bin/bash

set -e
. confrc

function setup_dev_tools() {
	if ! grep epel /etc/yum.repos.d/* >/dev/null 2>&1; then
		sudo yum install -y epel-release
	fi

	sudo yum install -y gcc gcc-c++ libevent-devel ncurses-devel
	sudo yum install -y man wget git zsh

	# python3
	sudo yum install -y python3 python3-devel python3-pip
	sudo pip3 install --upgrade pip

	# node
	if [ ! -e /usr/local/bin/node ]; then
		sudo yum install -y nodejs npm --enablerepo epel
		sudo npm install --global n
		sudo /usr/local/bin/n 16.20.0
		sudo yum remove -y nodejs npm

		mkdir -p "${NPM_PACKAGES}"
		npm config set prefix "${HOME}/.npm-packages"
	fi
}

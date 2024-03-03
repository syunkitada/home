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

		setup_npm_config

		sudo -E npm install --global n
		sudo -E /usr/local/bin/n "${NODE_VERSION}"
		sudo yum remove -y nodejs npm

		# npmのpathが変わったことによりbashのキャッシュによってnpmのpath解決できなくなるので、bashのキャッシュを消します
		hash -r
	fi
	mkdir -p "${NPM_PACKAGES}"
	npm config set prefix "${HOME}/.npm-packages"
}

# install tmux
function setup_tmux() {
	if [ ! -e ~/.local/bin/tmux ]; then
		_PWD=$PWD
		cd /tmp || exit 1
		curl -kLO "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
		tar -zxvf "tmux-${TMUX_VERSION}.tar.gz"
		cd "tmux-${TMUX_VERSION}" || exit 1
		./configure --prefix="${HOME}/.local"
		make
		sudo make install
		cd ../
		rm -rf tmux-*
		cd "${_PWD}"
	fi
}

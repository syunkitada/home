#!/bin/bash

set -e
. confrc

function setup_base_tools() {
	# findutils:  find command
	sudo yum install -y findutils
}

function setup_dev_tools() {
	sudo yum install -y gcc gcc-c++ libevent-devel ncurses-devel
	sudo yum install -y man wget git zsh

	# python3
	sudo yum install -y python3 python3-devel python3-pip

	# node
	if [ ! -e /usr/local/bin/node ]; then
		sudo yum install -y nodejs npm
		sudo npm install --global n
		sudo /usr/local/bin/n stable
		sudo yum remove -y nodejs npm

		mkdir -p "${NPM_PACKAGES}"
		npm config set prefix "${HOME}/.npm-packages"
	fi
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

function setup_dev_clang() {
	# clang-tools-extraにclangdも入ってます
	sudo yum install -y clang clang-tools-extra
}

function help() {
	cat <<EOS
setup_base_tools
setup_dev_tools
setup_tmux
EOS
}

if [ $# != 0 ]; then
	"${@}"
fi

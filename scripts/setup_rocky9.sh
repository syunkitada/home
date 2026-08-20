#!/bin/bash

set -e
. confrc

function setup_base_tools() {
	# findutils:  find command
	sudo dnf install -y findutils
}

function setup_dev_tools() {
	sudo dnf install -y gcc gcc-c++ libevent-devel ncurses-devel
	sudo dnf install -y man wget git zsh

	# python3
	sudo dnf install -y python3 python3-devel python3-pip

	# node
	curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash
	export NVM_DIR="$HOME/.config/nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
	nvm install "$(echo "${NODE_VERSION}" | cut -d. -f1)"

	# setup_npm_config
	# mkdir -p "${NPM_PACKAGES}"
	# npm config set prefix "${HOME}/.npm-packages"
}

# install tmux
function setup_tmux() {
	if [ ! -e ~/.local/bin/tmux ]; then
		(
			sudo dnf install -y bison gcc make ncurses-devel libevent-devel pkgconfig autoconf automake
			cd /tmp || exit 1
			curl -LO "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
			tar -zxvf "tmux-${TMUX_VERSION}.tar.gz"
			cd "tmux-${TMUX_VERSION}" || exit 1
			./configure --prefix="${HOME}/.local"
			make
			sudo make install
		)
	fi
}

function setup_dev_clang() {
	# clang-tools-extraにclangdも入ってます
	sudo dnf install -y clang clang-tools-extra
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

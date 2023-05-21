#!/bin/bash

set -e
. confrc

function _install() {
	for pkg in "$@"; do
		dpkg -s "$pkg" || sudo apt install -y "$pkg"
	done
}

function setup_dev_tools() {
	# 汎用ツール類のインストール
	sudo apt update -y
	_install curl git zsh build-essential ncurses-dev snapd

	# pythonとその関連パッケージのインストール
	_install python3 python3-venv python3-dev python3-pip

	# setup node
	if [ ! -e /usr/local/bin/node ]; then
		_install nodejs npm

		setup_npm_config

		sudo -E npm install --global n
		sudo -E /usr/local/bin/n "${NODE_VERSION}"
		# npmのpathが変わったことによりnpmのpath解決できなくなるのでaliasを張ります
		alias npm=/usr/local/bin/npm
	fi
	mkdir -p "${HOME}/.npm-packages"
	npm config set prefix "${HOME}/.npm-packages"

	# https://github.com/watchexec/watchexec
	# ファイルの変更検知して自動でプロセス再起動してくれる
	if ! type watchexec; then
		WATCHEXEC_VERSION=${WATCHEXEC_VERSION:-1.21.1}
		cd /tmp || exit 1
		wget "https://github.com/watchexec/watchexec/releases/download/v${WATCHEXEC_VERSION}/watchexec-${WATCHEXEC_VERSION}-x86_64-unknown-linux-gnu.deb"
		sudo apt install "/tmp/watchexec-${WATCHEXEC_VERSION}-x86_64-unknown-linux-gnu.deb"
		rm "/tmp/watchexec-${WATCHEXEC_VERSION}-x86_64-unknown-linux-gnu.deb"
		cd - || exit 1
	fi
}

# install tmux
function setup_tmux() {
	_install libevent-dev ncurses-dev build-essential bison pkg-config
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
	_install clang clangd clang-format
}

# ファイル検索ツール
# _install silversearcher-ag

# razygit
# https://github.com/jesseduffield/lazygit
# LAZYGIT_VERSION=0.35
# if [ "$(lazygit --version | sed -r 's/^.*version=([0-9]+\.[0-9]+), .*$/\1/')" != "${LAZYGIT_VERSION}" ]; then
# 	curl -Lo lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/download/v0.35/lazygit_0.35_Linux_x86_64.tar.gz
# 	tar -xzf lazygit.tar.gz -C ~/.local/bin lazygit
# 	rm lazygit.tar.gz
# fi

function help() {
	cat <<EOS
setup_base_tools
setup_dev_tools
setup_tmux
setup_dev_clang
EOS
}

if [ $# != 0 ]; then
	"${@}"
fi

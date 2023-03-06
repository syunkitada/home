#!/bin/bash

set +ex

function install() {
	for pkg in "$@"; do
		dpkg -l "$pkg" || sudo apt install "$pkg"
	done
}

# 汎用ツール類のインストール
sudo apt update -y
install curl git zsh build-essential ncurses-dev snapd

# pythonとその関連パッケージのインストール
install python3 python3-venv python3-dev python3-pip

# for building tmux
install libevent-dev ncurses-dev build-essential bison pkg-config
./setup_tmux.sh

# ファイル検索ツール
install silversearcher-ag
# install fzf
if [ ! -e ~/.fzf ]; then
	git clone https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install --bin
fi

# razygit
# https://github.com/jesseduffield/lazygit
LAZYGIT_VERSION=0.35
if [ "$(lazygit --version | sed -r 's/^.*version=([0-9]+\.[0-9]+), .*$/\1/')" != "${LAZYGIT_VERSION}" ]; then
	curl -Lo lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/download/v0.35/lazygit_0.35_Linux_x86_64.tar.gz
	tar -xzf lazygit.tar.gz -C ~/.local/bin lazygit
	rm lazygit.tar.gz
fi

# setup node
if [ ! -e /usr/local/bin/node ]; then
	install -y nodejs npm
	sudo npm install --global n
	sudo n stable
	sudo apt remove -y nodejs npm

	mkdir -p "${HOME}/.npm-packages"
	npm config set prefix "${HOME}/.npm-packages"
fi

# setup language-servers for c
install clang clangd clang-format

# https://github.com/watchexec/watchexec
# ファイルの変更検知して自動でプロセス再起動してくれる
if ! type watchexec; then
	WATCHEXEC_VERSION=1.21.1
	cd /tmp || exit 1
	wget https://github.com/watchexec/watchexec/releases/download/v${WATCHEXEC_VERSION}/watchexec-${WATCHEXEC_VERSION}-x86_64-unknown-linux-gnu.deb
	sudo apt install /tmp/watchexec-${WATCHEXEC_VERSION}-x86_64-unknown-linux-gnu.deb
	rm /tmp/watchexec-${WATCHEXEC_VERSION}-x86_64-unknown-linux-gnu.deb
	cd - || exit 1
fi

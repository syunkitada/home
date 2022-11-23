#!/bin/bash

set -x
set +e

# 汎用ツール類のインストール
sudo apt update -y
sudo apt install -y curl git zsh tmux build-essential ncurses-dev snapd

# pythonとその関連パッケージのインストール
sudo apt install -y python3 python3-venv python3-dev python3-pip

# neovimおよびその依存パッケージのインストール
NEOVIM_VERSION=v0.7.2
if [ "$(nvim --version | grep 'NVIM v')" != "NVIM ${NEOVIM_VERSION}" ]; then
	curl -fsSL https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux64.tar.gz |
		gunzip | tar x --strip-components=1 -C ~/.local
fi

# ファイル検索ツール
sudo apt install -y silversearcher-ag
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
	sudo apt install -y nodejs npm
	sudo npm install --global n
	sudo n stable
	sudo apt remove -y nodejs npm

	mkdir -p "${HOME}/.npm-packages"
	npm config set prefix "${HOME}/.npm-packages"
fi

# setup language-servers for c
sudo apt install -y clang clangd clang-format

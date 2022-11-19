#!/bin/sh -xe

if ! grep epel /etc/yum.repos.d/* >/dev/null 2>&1; then
	sudo yum install -y epel-release
fi

# 汎用ツール類のインストール
sudo yum install -y gcc gcc-c++ libevent-devel ncurses-devel
sudo yum install -y man wget git zsh

# neovimおよびその依存パッケージのインストール
sudo yum -y install --enablerepo epel the_silver_searcher cscope ctags
sudo yum -y install python3 python3-devel python3-pip

# neovimおよびその依存パッケージのインストール
NEOVIM_VERSION=v0.7.2
if [ "$(nvim --version | grep 'NVIM v')" != "NVIM ${NEOVIM_VERSION}" ]; then
	curl -fsSL https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux64.tar.gz |
		gunzip | tar x --strip-components=1 -C ~/.local
fi

# fzfのインストール
if [ ! -e ~/.fzf ]; then
	git clone https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install --bin
fi

# setup node
if [ ! -e /usr/local/bin/node ]; then
	sudo yum install -y nodejs npm --enablerepo epel
	sudo npm install --global n
	sudo /usr/local/bin/n stable
	sudo yum remove -y nodejs npm

	mkdir -p "${HOME}/.npm-packages"
	npm config set prefix "${HOME}/.npm-packages"
fi

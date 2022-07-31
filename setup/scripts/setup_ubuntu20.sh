#!/bin/sh

# 汎用ツール類のインストール
sudo apt update -y
sudo apt install curl git zsh tmux build-essential vim ncurses-dev snapd -y

# neovimおよびその依存パッケージのインストール
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt update -y
sudo apt install -y neovim python3-pynvim
sudo apt install -y cscope

sudo apt install -y silversearcher-ag
sudo apt install -y python3 python3-venv python3-dev python3-pip

# exuberant-ctagsはメンテが止まっており、universal-ctagsに移行している途中(2019/12/15)
# sudo snap install universal-ctags
sudo apt install -y exuberant-ctags clang-format
curl https://raw.githubusercontent.com/jb55/typescript-ctags/master/.ctags > ~/.ctags

# install fzf
if [ ! -e ~/.fzf ]; then
    git clone https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
fi

if [ ! -e /usr/local/bin/node ]; then
    sudo apt install -y nodejs npm
    sudo npm install --global n
    sudo n stable
    sudo apt remove -y nodejs npm

    mkdir -p "${HOME}/.npm-packages"
    npm config set prefix "${HOME}/.npm-packages"
    npm install -g prettier prettier/vim-prettier
fi

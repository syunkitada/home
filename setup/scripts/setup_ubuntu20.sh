#!/bin/sh

# 汎用ツール類のインストール
sudo apt update -y
sudo apt install curl git zsh tmux build-essential vim ncurses-dev snapd -y

# neovimおよびその依存パッケージのインストール
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt update -y
sudo apt install -y neovim python3-pynvim

sudo apt install -y silversearcher-ag
sudo apt install -y python3 python3-venv python3-dev python3-pip

# exuberant-ctagsはメンテが止まっており、universal-ctagsに移行している途中(2019/12/15)
# sudo snap install universal-ctags
# sudo apt install -y exuberant-ctags
# curl https://raw.githubusercontent.com/jb55/typescript-ctags/master/.ctags > ~/.ctags

pip3 install --user pynvim neovim neovim-remote

# install fzf
if [ ! -e ~/.fzf ]; then
    git clone https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --bin
fi

if [ ! -e /usr/local/bin/node ]; then
    sudo apt install -y nodejs npm
    sudo npm install --global n
    sudo n stable
    sudo apt remove -y nodejs npm

    mkdir -p "${HOME}/.npm-packages"
    npm config set prefix "${HOME}/.npm-packages"
fi


# for language-servers
npm install -g pyright
pip3 install --user black flake8
npm install -g typescript typescript-language-server
npm install -g prettier
npm install -g @tailwindcss/language-server
sudo apt install -y clang clangd clang-format
go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest

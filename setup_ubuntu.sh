#!/bin/sh

sudo apt-get update -y
sudo apt-get install git zsh tmux build-essential vim ncurses-dev -y

# install neovim
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt-get update -y
sudo apt-get install -y neovim

sudo apt-get install -y python3-dev python3-pip
sudo pip install neovim

# exuberant-ctagsはメンテが止まっており、universal-ctagsに移行している途中(2019/12/15)
# sudo snap install universal-ctags
sudo apt-get install exuberant-ctags
curl https://raw.githubusercontent.com/jb55/typescript-ctags/master/.ctags > ~/.ctags

# install fzf
if [ ! -e ~/.fzf ]; then
    git clone https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

sudo apt install -y silversearcher-ag
sudo apt-get install -y nodejs npm
sudo npm install --global yarn

yarn global add prettier

# これがないとcoc extensionsがインストールできない
mkdir -p ~/.config/coc/extensions

# Setup golang environment
if [ ! -e ~/.goenv ]; then
    git clone https://github.com/syndbg/goenv.git ~/.goenv
    source ~/.zsh/go.zsh
    goenv install 1.12.15
    goenv global 1.12.15

    # https://github.com/go-godo/godo
    go get -u gopkg.in/godo.v2/cmd/godo

    # https://github.com/golang/tools/blob/master/gopls/doc/user.md
    go get -u golang.org/x/tools/gopls
fi

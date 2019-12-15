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

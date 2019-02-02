#!/bin/sh

sudo apt-get update -y
sudo apt-get install git zsh tmux build-essential vim ncurses-dev -y

# install neovim
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt-get update -y
sudo apt-get install -y neovim

sudo apt-get install -y python3-dev python3-pip

# install fzf
if [ ! -e ~/.fzf ]; then
    git clone https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

#!/bin/sh

sudo yum install man wget git gcc gcc-c++ zsh vim tmux ncurses-devel -y

# install neovim
sudo yum -y install epel-release
sudo yum -y install neovim

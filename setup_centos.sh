#!/bin/sh

if ! grep epel /etc/yum.repos.d/* > /dev/null 2>&1; then
    sudo yum install epel-release
fi

sudo yum install -y gcc gcc-c++ libevent-devel ncurses-devel
sudo yum install -y man wget git zsh vim

# install neovim
sudo yum -y install --enablerepo epel neovim the_silver_searcher cscope ctags
sudo yum -y install python3 python3-dev python3-pip
sudo pip3 install --user pynvim

# install fzf
if [ ! -e ~/.fzf ]; then
    git clone https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

if [ ! -e /usr/local/bin/node ]; then
    sudo yum install -y nodejs npm --enablerepo epel
    sudo npm install --global n
    sudo n stable
    sudo yum remove nodejs npm

    mkdir -p "${HOME}/.npm-packages"
    npm config set prefix "${HOME}/.npm-packages"
    npm install --global yarn
    yarn global add prettier prettier/vim-prettier
fi

# Setup golang environment
if [ ! -e ~/.goenv ]; then
    git clone https://github.com/syndbg/goenv.git ~/.goenv
    source ~/.zsh/go.zsh
    # goenv install 1.12.15
    # goenv global 1.12.15

    # https://github.com/go-godo/godo
    # go get -u gopkg.in/godo.v2/cmd/godo
fi

# install tmux
if [ ! -e /usr/loca/bin/tmux ]; then
    curl -kLO https://github.com/tmux/tmux/releases/download/2.8/tmux-2.8.tar.gz
    tar -zxvf tmux-2.8.tar.gz
    cd tmux-2.8
    ./configure
    make
    sudo make install
    cd ../
    rm -rf tmux-*
fi

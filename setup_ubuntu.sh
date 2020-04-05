#!/bin/sh

sudo apt-get update -y
sudo apt-get install git zsh tmux build-essential vim ncurses-dev snapd -y

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

if [ ! -e ~/.ccls ]; then
    cd /tmp
    sudo apt install -y clangd-9
    # sudo ln -s /usr/bin/clangd-9 /usr/bin/clangd
    # sudo apt install snapd cmake -y
    wget https://github.com/MaskRay/ccls/archive/0.20190823.5.tar.gz
    tar xf 0.20190823.5.tar.gz
    cd ccls-0.20190823.5
    exec "$HOME/src/ccls/Release/ccls" "$@"
    cd -
fi

if [ ! -e /usr/local/bin/node ]; then
    sudo apt install -y silversearcher-ag
    sudo apt install -y nodejs npm
    sudo npm install --global n
    sudo n stable
    sudo apt-get remove nodejs npm
    sudo npm install --global yarn
    yarn global add prettier prettier/vim-prettier
fi

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

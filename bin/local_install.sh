#!/bin/bash

# exit on error
set -e

if [ $# -ne 1 ]; then
    echo "please enter the app argument"
    echo "support app is vim, tmux, all"
    exit 1
fi

TMUX_VERSION=1.8
VIM_VERSION=7.4
INSTALLATION_DIR=$HOME/.local
TMP_WORKING_DIR=$HOME/tmp_working_dir

mkdir -p $INSTALLATION_DIR $TMP_WORKING_DIR
cd $TMP_WORKING_DIR

if [ $1 = tmux -o $1 = vim -o $1 = all ]; then
    # install libevent
    wget https://github.com/downloads/libevent/libevent/libevent-2.0.19-stable.tar.gz
    tar xvzf libevent*.tar.gz
    cd libevent*
    ./configure --prefix=$INSTALLATION_DIR --disable-shared
    make
    make install
    cd ..

    # install ncurses
    wget ftp://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz
    tar xvzf ncurses*.tar.gz
    cd ncurses*
    ./configure --prefix=$INSTALLATION_DIR
    make
    make install
    cd ..
fi

if [ $1 = tmux -o $1 = all ]; then
    # install tmux
    wget -O tmux-${TMUX_VERSION}.tar.gz http://sourceforge.net/projects/tmux/files/tmux/tmux-${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz/download
    tar xvzf tmux-*.tar.gz
    cd tmux-*
    ./configure CFLAGS="-I$INSTALLATION_DIR/include -I$INSTALLATION_DIR/include/ncurses" LDFLAGS="-L$INSTALLATION_DIR/lib -L$INSTALLATION_DIR/include/ncurses -L$INSTALLATION_DIR/include"
    CPPFLAGS="-I$INSTALLATION_DIR/include -I$INSTALLATION_DIR/include/ncurses" LDFLAGS="-static -L$INSTALLATION_DIR/include -L$INSTALLATION_DIR/include/ncurses -L$INSTALLATION_DIR/lib" make
    cp tmux $INSTALLATION_DIR/bin
    cd ..
fi

if [ $1 = vim -o $1 = all ]; then
    # install vim
    wget ftp://ftp.vim.org/pub/vim/unix/vim-${VIM_VERSION}.tar.bz2
    tar -xvf vim*.tar.bz2
    cd vim*
    ./configure --prefix=$INSTALLATION_DIR
    make
    make install
    cd ../
    rm -rf vim*
fi

# complete
rm -rf $TMP_WORKING_DIR
echo "\nSUCCESS INSTALLED "$1

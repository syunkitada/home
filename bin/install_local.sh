#!/bin/bash

# exit on error
set -e

if [ $# -ne 1 ]; then
    echo "please enter the app argument"
    echo "support app is vim, tmux, all"
    exit 1
fi

TMUX_VERSION=1.9
VIM_VERSION=7.4
INSTALLATION_DIR=$HOME/.local
TMP_WORKING_DIR=/tmp/install_local

mkdir -p $INSTALLATION_DIR $TMP_WORKING_DIR
pushd $TMP_WORKING_DIR

if [ $1 = tmux -o $1 = vim -o $1 = all ]; then
    # install libevent
    LIBEVENT=libevent-2.0.21-stable
    if [ ! -e ${LIBEVENT}.tar.gz ]; then
        wget http://downloads.sourceforge.net/project/levent/libevent/libevent-2.0/${LIBEVENT}.tar.gz
        tar xvzf ${LIBEVENT}.tar.gz
        pushd $LIBEVENT
        ./configure --prefix=$INSTALLATION_DIR --disable-shared
        make
        make install
        popd
    fi

    # install ncurses
    sudo yum install ncurses-devel -y
    NCURSES=ncurses-5.9
    if [ ! -e ${NCURSES}.tar.gz ]; then
        wget ftp://ftp.gnu.org/gnu/ncurses/${NCURSES}.tar.gz
        tar xvzf ${NCURSES}.tar.gz
        pushd $NCURSES
        ./configure --prefix=$INSTALLATION_DIR
        make
        make install
        popd
    fi
fi

if [ $1 = tmux -o $1 = all ]; then
    # install tmux
    if [ ! -e tmux-${TMUX_VERSION}.tar.gz ]; then
        wget -O tmux-${TMUX_VERSION}.tar.gz http://sourceforge.net/projects/tmux/files/tmux/tmux-${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz/download
        tar xvzf tmux-*.tar.gz
        pushd tmux-*
        ./configure CFLAGS="-I$INSTALLATION_DIR/include -I$INSTALLATION_DIR/include/ncurses" LDFLAGS="-L$INSTALLATION_DIR/lib -L$INSTALLATION_DIR/include/ncurses -L$INSTALLATION_DIR/include"
    CPPFLAGS="-I$INSTALLATION_DIR/include -I$INSTALLATION_DIR/include/ncurses" LDFLAGS="-static -L$INSTALLATION_DIR/include -L$INSTALLATION_DIR/include/ncurses -L$INSTALLATION_DIR/lib" make
        cp tmux $INSTALLATION_DIR/bin
        popd
    fi
fi

if [ $1 = vim -o $1 = all ]; then
    # install vim
    if [ ! -e vim-${VIM_VERSION}.tar.bz2 ]; then
        wget ftp://ftp.vim.org/pub/vim/unix/vim-${VIM_VERSION}.tar.bz2
        tar -xvf vim*.tar.bz2
        pushd vim*
        ./configure --prefix=$INSTALLATION_DIR
        make
        make install
        popd
    fi
fi

# complete
popd

echo "\nSUCCESS INSTALLED "$1


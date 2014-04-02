#!/bin/sh

wget ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2
tar -xvf vim-7.4.tar.bz2
cd vim74
./configure --prefix=/usr/local
make
sudo make install
cd ../
rm -rf vim74

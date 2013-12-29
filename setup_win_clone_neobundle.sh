#!/bin/sh

neobundle=`pwd`/.vim/bundle/neobundle.vim/

rm -rf $neobundle

git clone https://github.com/Shougo/neobundle.vim.git $neobundle


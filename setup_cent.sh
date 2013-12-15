#!/bin/sh

bashrc=`pwd`/.bashrc
vimrc=`pwd`/.vimrc
vrapperrc=`pwd`/.vrapperrc
gvimrc=`pwd`/.gvimrc
vim=`pwd`/.vim
bundle=${vim}/bundle/neobundle.vim/

ln_bashrc=${HOME}/.bash_profile
ln_vimrc=${HOME}/.vimrc
ln_vrapperrc=${HOME}/.vrapperrc
ln_gvimrc=${HOME}/.gvimrc
ln_vim=${HOME}/.vim

rm -f $ln_bashrc
rm -f $ln_vimrc
rm -f $ln_gvimrc
rm -rf $ln_vim
rm -f $ln_vrapperrc
rm -rf $bundle

ln -s $bashrc $ln_bashrc
ln -s $vimrc $ln_vimrc
ln -s $gvimrc $ln_gvimrc
ln -s $vim $ln_vim
ln -s $vrapperrc $ln_vrapperrc

git clone https://github.com/Shougo/neobundle.vim.git $bundle


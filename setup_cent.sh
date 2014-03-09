#!/bin/sh

bash_profile=`pwd`/.bash_profile
git_prompt=`pwd`/.git-prompt.sh
git_completion=`pwd`/.git-completion.bash
screenrc=`pwd`/.screenrc
vimrc=`pwd`/.vimrc
gvimrc=`pwd`/.gvimrc
vimshrc=`pwd`/.vimshrc
vim=`pwd`/.vim
neobundle=${vim}/bundle/neobundle.vim/
vrapperrc=`pwd`/.vrapperrc

ln_bash_profile=${HOME}/.bash_profile
ln_git_prompt=${HOME}/.git-prompt.sh
ln_git_completion=${HOME}/.git-completion.bash
ln_screenrc=${HOME}/.screenrc
ln_vimrc=${HOME}/.vimrc
ln_gvimrc=${HOME}/.gvimrc
ln_vimshrc=${HOME}/.vimshrc
ln_vim=${HOME}/.vim
ln_vrapperrc=${HOME}/.vrapperrc

rm -f  $ln_bash_profile
rm -f  $ln_git_prompt
rm -f  $ln_git_completion
rm -f  $ln_screenrc
rm -f  $ln_vimrc
rm -f  $ln_gvimrc
rm -f  $ln_vimshrc
rm -rf $ln_vim
rm -rf $neobundle
rm -f  $ln_vrapperrc

ln -s $bash_profile $ln_bash_profile
ln -s $git_prompt $ln_git_prompt
ln -s $git_completion $ln_git_completion
ln -s $screenrc $ln_screenrc
ln -s $vimrc $ln_vimrc
ln -s $gvimrc $ln_gvimrc
ln -s $vim $ln_vim
ln -s $vimshrc $ln_vimshrc
ln -s $vrapperrc $ln_vrapperrc

git clone https://github.com/Shougo/neobundle.vim.git $bundle

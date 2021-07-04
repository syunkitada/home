#!/bin/sh -xe

XDG_CONFIG_HOME=${HOME}/.config
mkdir -p ${XDG_CONFIG_HOME}

bash_profile=`pwd`/.bash_profile
zshrc=`pwd`/.zshrc
zsh=`pwd`/.zsh
git_prompt=`pwd`/.git-prompt.sh
git_completion=`pwd`/.git-completion.bash
screenrc=`pwd`/.screenrc
tmuxconf=`pwd`/.tmux.conf
vimrc=`pwd`/.vimrc
gvimrc=`pwd`/.gvimrc
vim=`pwd`/.vim
nvim=`pwd`/.nvim

ln_bash_profile=${HOME}/.bash_profile
ln_zshrc=${HOME}/.zshrc
ln_zsh=${HOME}/.zsh
ln_git_prompt=${HOME}/.git-prompt.sh
ln_git_completion=${HOME}/.git-completion.bash
ln_screenrc=${HOME}/.screenrc
ln_tmuxconf=${HOME}/.tmux.conf
ln_vimrc=${HOME}/.vimrc
ln_gvimrc=${HOME}/.gvimrc
ln_vim=${HOME}/.vim
ln_nvim=${HOME}/.config/nvim

rm -f $ln_bash_profile
rm -f $ln_zshrc
rm -f $ln_zsh
rm -f $ln_git_prompt
rm -f $ln_git_completion
rm -f $ln_screenrc
rm -f $ln_tmuxconf
rm -f $ln_vimrc
rm -f $ln_gvimrc
rm -f $ln_vim
rm -f $ln_nvim

ln -s $bash_profile $ln_bash_profile
ln -s $zshrc $ln_zshrc
ln -s $zsh $ln_zsh
ln -s $git_prompt $ln_git_prompt
ln -s $git_completion $ln_git_completion
ln -s $screenrc $ln_screenrc
ln -s $tmuxconf $ln_tmuxconf
ln -s $vimrc $ln_vimrc
ln -s $gvimrc $ln_gvimrc
ln -s $vim $ln_vim
ln -s $nvim $ln_nvim

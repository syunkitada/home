#!/bin/bash

source confrc
source ../../dotfiles/.envrc

function ok() {
	echo -e "\e[32m${1}\e[m"
}

function warn() {
	echo -e "\e[33m${1}\e[m"
}

function error() {
	echo -e "\e[31m${1}\e[m"
}

# check nvim
which_nvim=$(command -v nvim)
if [ "${which_nvim}" == "${HOME}/.local/bin/nvim" ]; then
	nvim_version=$(nvim --version | grep 'NVIM v' | awk '{print $2}')
	ok "nvim(${nvim_version}) is installed: ${which_nvim}"
	if [ "${nvim_version}" != "${NEOVIM_VERSION}" ]; then
		warn "nvim(${nvim_version}) is unexpected version: expected=${NEOVIM_VERSION}"
	fi
else
	error "nvim is not installed: ${which_nvim}"
fi

# check tmux
which_tmux=$(command -v tmux)
if [ "${which_tmux}" == "${HOME}/.local/bin/tmux" ]; then
	tmux_version=$(tmux -V | awk '{print $2}')
	ok "tmux(${tmux_version}) is installed: ${which_tmux}"
	if [ "${tmux_version}" != "${TMUX_VERSION}" ]; then
		warn "tmux(${tmux_version}) is unexpected version: expected=${TMUX_VERSION}"
	fi
else
	error "tmux is not installed: ${which_tmux}"
fi

# check fzf
which_fzf=$(command -v fzf)
if [ "${which_fzf}" == "${HOME}/.fzf/bin/fzf" ]; then
	ok "fzf is installed: ${which_fzf}"
else
	error "fzf is not installed: ${which_fzf}"
fi

# check npm
which_npm=$(command -v npm)
if [ "${which_npm}" == "/usr/local/bin/npm" ]; then
	ok "npm is installed: ${which_npm}"
else
	error "npm is not installed: ${which_npm}"
fi

# check go
which_go=$(command -v go)
if [ "${which_go}" == "/usr/local/bin/go" ]; then
	ok "go is installed: ${which_go}"
else
	error "go is not installed: ${which_go}"
fi

# check shfmt
which_shfmt=$(command -v shfmt)
if [ "${which_shfmt}" == "${HOME}/.local/bin/shfmt" ]; then
	ok "shfmt is installed: ${which_shfmt}"
else
	error "shfmt is not installed: ${which_shfmt}"
fi

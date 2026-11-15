#!/bin/bash

cd "$(dirname "$0")" || exit 1

source confrc
source "${HOME_ROOT_DIR}/home/.envrc"

CHECK_FAILED=0
IS_MACOS=false
if [ "$(uname -s)" = "Darwin" ]; then
	IS_MACOS=true
fi

function ok() {
	echo -e "\e[32m${1}\e[m"
}

function warn() {
	echo -e "\e[33m${1}\e[m"
}

function error() {
	CHECK_FAILED=1
	echo -e "\e[31m${1}\e[m"
}

# check nvim
which_nvim=$(command -v nvim)
if [ -n "${which_nvim}" ]; then
	nvim_version=$(nvim --version | grep 'NVIM v' | awk '{print $2}')
	ok "nvim(${nvim_version}) is installed: ${which_nvim}"
	if [ "${IS_MACOS}" != true ] && [ "${nvim_version}" != "${NEOVIM_VERSION}" ]; then
		warn "nvim(${nvim_version}) is unexpected version: expected=${NEOVIM_VERSION}"
	fi
else
	error "nvim is not installed: ${which_nvim}"
fi

# check tmux
which_tmux=$(command -v tmux)
if [ -n "${which_tmux}" ]; then
	tmux_version=$(tmux -V | awk '{print $2}')
	ok "tmux(${tmux_version}) is installed: ${which_tmux}"
	if [ "${IS_MACOS}" != true ] && [ "${tmux_version}" != "${TMUX_VERSION}" ]; then
		warn "tmux(${tmux_version}) is unexpected version: expected=${TMUX_VERSION}"
	fi
else
	error "tmux is not installed: ${which_tmux}"
fi

# check fzf
which_fzf=$(command -v fzf)
if [ -n "${which_fzf}" ]; then
	ok "fzf is installed: ${which_fzf}"
else
	error "fzf is not installed: ${which_fzf}"
fi

# check npm
which_npm=$(command -v npm)
if [ -n "${which_npm}" ]; then
	ok "npm is installed: ${which_npm}"
else
	error "npm is not installed"
fi

# check go
which_go=$(command -v go)
if [ -n "${which_go}" ]; then
	ok "go is installed: ${which_go}"
else
	error "go is not installed"
fi

# check shfmt
which_shfmt=$(command -v shfmt)
if [ -n "${which_shfmt}" ]; then
	ok "shfmt is installed: ${which_shfmt}"
else
	error "shfmt is not installed: ${which_shfmt}"
fi

exit "${CHECK_FAILED}"

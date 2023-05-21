#!/bin/bash

set -e
. confrc

# NVIM-0.8.X は、GLIBC_2.29を要求してくるがRocky8のGLIBは2.28なので、0.7.2を利用します
NEOVIM_VERSION=${NEOVIM_VERSION:-v0.7.2}
GO_VERSION=${GO_VERSION:-1.20.3}

function setup_base_tools() {
	echo "skip setup_base_tools"
}

function setup_init() {
	mkdir -p ~/.local
}

function setup_dotfiles() {
	# dotfiles 内のファイルのシンボリックリンクを ~/ に作成します
	# xdgconfig 内のファイルのシンボリックリンクを ~/.config に作成します

	export ROOT=${HOME}/home/
	cd "$ROOT"

	XDG_CONFIG_HOME=${HOME}/.config
	mkdir -p "${XDG_CONFIG_HOME}"

	for file in $(find dotfiles -name '.*' -printf "%f\n"); do
		src=${ROOT}/dotfiles/${file}
		dst=${HOME}/${file}
		rm -f "$dst"
		ln -s "$src" "$dst"
	done

	for file in $(ls xdgconfig); do
		src=${ROOT}/xdgconfig/${file}
		dst=${HOME}/.config/${file}
		rm -f "$dst"
		ln -s "$src" "$dst"
	done
}

function setup_nvim() {
	if [ "$(nvim --version | grep 'NVIM v')" != "NVIM ${NEOVIM_VERSION}" ]; then
		curl -fsSL "https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux64.tar.gz" |
			gunzip | tar x --strip-components=1 -C ~/.local
	fi

	# install for nvim
	pip3 install --user pynvim neovim neovim-remote
}

function setup_dev_python() {
	# install for python develop tools
	pip3 install --user black isort flake8

	# LSP
	npm install -g pyright
}

function setup_dev_web() {
	npm install -g typescript typescript-language-server
	npm install -g prettier
	npm install -g @tailwindcss/language-server
}

function setup_dev_go() {
	if [ "$(go version | grep 'go version' | awk '{print $3}')" != "go${GO_VERSION}" ]; then
		rm -rf /usr/local/go
		curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" |
			gunzip | sudo tar x --strip-components=1 -C /usr/local

		# LSP for go
		go install golang.org/x/tools/gopls@latest
		# formatter for go
		go install golang.org/x/tools/cmd/goimports@latest
	fi
}

function setup_dev_shell() {
	# LSP
	npm install -g bash-language-server

	set +e
	type shfmt
	type_shfmt=$?
	set -e
	if $type_shfmt -ne 0; then
		curl -L https://github.com/mvdan/sh/releases/download/v3.5.1/shfmt_v3.5.1_linux_amd64 -o ./shfmt
		chmod 755 ./shfmt
		mv ./shfmt ~/.local/bin/
	fi
}

function setup_fzf() {
	if [ ! -e ~/.fzf ]; then
		git clone https://github.com/junegunn/fzf.git ~/.fzf
		~/.fzf/install --bin
	fi
}

function setup_dev_rust() {
	# Setup rust environment
	if [ ! -e ~/.cargo ]; then
		curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path --profile default
	fi
}

function setup_dev_clang() {
	echo "skip setup_dev_clang"
}

function setup_npm_config() {
	echo "skip setup_npm_config"
}

function help() {
	cat <<EOS
setup_init
setup_dotfiles
setup_nvim
setup_fzf
setup_dev_go
setup_dev_web
setup_dev_python
setup_dev_rust
setup_dev_shell
EOS
}

if [ $# != 0 ]; then
	"${@}"
fi

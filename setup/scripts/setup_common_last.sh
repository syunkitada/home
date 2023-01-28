#!/bin/bash

set -x
set +e

# setup for python3
if type pip3; then
	# install for nvim
	pip3 install --user pynvim neovim neovim-remote

	# install for python develop tools
	pip3 install --user black flake8 isort
else
	echo "Skipped installing python tools because of pip3 is not installed"
fi

if type npm; then
	# setup for language-servers
	npm install -g pyright
	npm install -g typescript typescript-language-server
	npm install -g prettier
	npm install -g @tailwindcss/language-server
	npm install -g bash-language-server
else
	echo "Skipped installing npm tools because of npm(node) is not installed"
fi

# setup for go
if type go; then
	# lsp for go
	go install golang.org/x/tools/gopls@latest
	# formatter for go
	go install golang.org/x/tools/cmd/goimports@latest
else
	echo "Skipped install go tools"
fi

# setup for developing shell
if ! type shfmt; then
	curl -L https://github.com/mvdan/sh/releases/download/v3.5.1/shfmt_v3.5.1_linux_amd64 -o ./shfmt
	chmod 755 ./shfmt
	mv ./shfmt ~/.local/bin/
fi

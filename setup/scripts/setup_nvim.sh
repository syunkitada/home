#!/bin/bash

# neovimおよびその依存パッケージのインストール
NEOVIM_VERSION=v0.8.3
if [ "$(nvim --version | grep 'NVIM v')" != "NVIM ${NEOVIM_VERSION}" ]; then
	curl -fsSL https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux64.tar.gz |
		gunzip | tar x --strip-components=1 -C ~/.local
fi

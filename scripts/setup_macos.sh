#!/bin/bash

set -e
. confrc

function setup_base_tools() {
	if command -v brew >/dev/null 2>&1; then
		HOMEBREW=$(command -v brew)
	elif [ -x /opt/homebrew/bin/brew ]; then
		HOMEBREW=/opt/homebrew/bin/brew
	elif [ -x /usr/local/bin/brew ]; then
		HOMEBREW=/usr/local/bin/brew
	else
		echo "Homebrew is required. Install Homebrew, then run make again."
		return 1
	fi

	eval "$("$HOMEBREW" shellenv)"
	export HOMEBREW
}

function setup_dev_tools() {
	brew install fd git ripgrep watchexec zsh

	# Node.js is managed with nvm, matching the Linux setup.
	curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash
	export NVM_DIR="$HOME/.config/nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
	nvm install "$(echo "${NODE_VERSION}" | cut -d. -f1)"
}

function setup_nvim() {
	brew install neovim
}

function setup_tmux() {
	brew install tmux
}

function setup_dev_go() {
	brew install go
	go install golang.org/x/tools/gopls@latest
	go install golang.org/x/tools/cmd/goimports@latest
}

function setup_dev_shell() {
	brew install shfmt
	npm install -g bash-language-server
}

function setup_fzf() {
	brew install fzf
	if [ ! -e "$HOME/.fzf" ]; then
		git clone https://github.com/junegunn/fzf.git "$HOME/.fzf"
	fi
}

function setup_dev_clang() {
	brew install llvm
	mkdir -p "$HOME/.local/bin"
	llvm_bin="$(brew --prefix llvm)/bin"
	ln -sf "${llvm_bin}/clangd" "$HOME/.local/bin/clangd"
	ln -sf "${llvm_bin}/clang-format" "$HOME/.local/bin/clang-format"
}

function setup_dev_rust() {
	if [ "${ENABLE_RUST}" != "true" ]; then
		echo "Skip setup_dev_rust, because ENABLE_RUST is false"
		return
	fi

	if ! command -v cargo >/dev/null 2>&1; then
		curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path --profile default
	fi
	if [ "$(cargo-binstall -V 2>/dev/null | awk '{print $2}')" != "${CARGO_BINSTALL_VERSION}" ]; then
		cargo install cargo-binstall --locked --version "${CARGO_BINSTALL_VERSION}"
	fi

	if [ "${ENABLE_MARKDOWN_OXIDE}" = "true" ]; then
		cargo-binstall --git 'https://github.com/feel-ix-343/markdown-oxide' markdown-oxide --install-path "$HOME/.local/bin" -y --version "${MARKDOWN_OXIDE_VERSION}"
	fi
}

function help() {
	cat <<EOS
setup_base_tools
setup_dev_tools
setup_nvim
setup_tmux
setup_fzf
setup_dev_go
setup_dev_web
setup_dev_python
setup_dev_rust
setup_dev_shell
setup_dev_clang
setup_npm_config
EOS
}

if [ $# != 0 ]; then
	"${@}"
fi

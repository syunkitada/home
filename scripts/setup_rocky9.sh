#!/bin/bash

set -e
. confrc

function setup_base_tools() {
	# findutils:  find command
	sudo dnf install -y findutils curl
}

function setup_gh_cli() (
	set -e -o pipefail

	local arch
	case "$(uname -m)" in
		x86_64) arch=amd64 ;;
		aarch64) arch=arm64 ;;
		*)
			echo "Unsupported architecture for GitHub CLI RPM: $(uname -m)" >&2
			exit 1
			;;
	esac

	local release_tag
	release_tag=$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest |
		python3 -c 'import json, sys; print(json.load(sys.stdin)["tag_name"])')
	if [[ ! "$release_tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		echo "Unexpected GitHub CLI release tag: ${release_tag}" >&2
		exit 1
	fi

	local version="${release_tag#v}"
	local rpm_asset="gh_${version}_linux_${arch}.rpm"
	local checksums_asset="gh_${version}_checksums.txt"
	local release_url="https://github.com/cli/cli/releases/download/${release_tag}"
	local temp_dir
	temp_dir=$(mktemp -d)
	trap 'rm -rf -- "$temp_dir"' EXIT

	local rpm_path="${temp_dir}/${rpm_asset}"
	local checksums_path="${temp_dir}/${checksums_asset}"
	local keyring_path="${temp_dir}/githubcli-archive-keyring.asc"
	curl -fsSL --proto '=https' --proto-redir '=https' -o "$rpm_path" "${release_url}/${rpm_asset}"
	curl -fsSL --proto '=https' --proto-redir '=https' -o "$checksums_path" "${release_url}/${checksums_asset}"

	local expected_checksum
	expected_checksum=$(awk -v asset="$rpm_asset" '$2 == asset || $2 == ("*" asset) { print $1 }' "$checksums_path")
	if [[ ! "$expected_checksum" =~ ^[[:xdigit:]]{64}$ ]]; then
		echo "Could not find a valid SHA-256 checksum for ${rpm_asset}." >&2
		exit 1
	fi
	if ! printf '%s  %s\n' "$expected_checksum" "$rpm_path" | sha256sum --check --status; then
		echo "SHA-256 checksum verification failed for ${rpm_asset}." >&2
		exit 1
	fi

	curl -fsSL --proto '=https' --proto-redir '=https' -o "$keyring_path" https://cli.github.com/packages/githubcli-archive-keyring.asc
	if ! printf '%s  %s\n' 'cec6e9ed82d3949ca5f4428cc968b41ef5e7416cb3653cdfc2a421977663bbfd' "$keyring_path" | sha256sum --check --status; then
		echo "GitHub CLI signing key checksum verification failed." >&2
		exit 1
	fi

	sudo rpm --import "$keyring_path"
	sudo dnf install -y "$rpm_path"
)

function setup_dev_tools() {
	sudo dnf install -y gcc gcc-c++ libevent-devel ncurses-devel
	sudo dnf install -y man wget git zsh

	# python3
	sudo dnf install -y python3 python3-devel python3-pip

	setup_gh_cli

	# node
	curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash
	export NVM_DIR="$HOME/.config/nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
	nvm install "$(echo "${NODE_VERSION}" | cut -d. -f1)"

	# setup_npm_config
	# mkdir -p "${NPM_PACKAGES}"
	# npm config set prefix "${HOME}/.npm-packages"
}

# install tmux
function setup_tmux() {
	if [ ! -e ~/.local/bin/tmux ]; then
		(
			sudo dnf install -y bison gcc make ncurses-devel libevent-devel pkgconfig autoconf automake
			mkdir ~/tmp_setup_tmux
			cd ~/tmp_setup_tmux
			curl -LO "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
			tar -zxvf "tmux-${TMUX_VERSION}.tar.gz"
			cd "tmux-${TMUX_VERSION}" || exit 1
			./configure --prefix="${HOME}/.local"
			make
			sudo make install
			rm -rf ~/tmp_setup_tmux
		)
	fi
}

function setup_dev_clang() {
	# clang-tools-extraにclangdも入ってます
	sudo dnf install -y clang clang-tools-extra
}

function help() {
	cat <<EOS
setup_base_tools
setup_dev_tools
setup_tmux
EOS
}

if [ $# != 0 ]; then
	"${@}"
fi

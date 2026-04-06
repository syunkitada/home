# ------------------------------
# General Settings
# ------------------------------
source ~/.envrc

# load common scripts
for file in $(find ${XDG_CONFIG_HOME}/zsh/ -name '*.zsh' -type f | sort); do
	source "${file}"
done

# 拡張用の設定ファイルを読み込む
if [ -e ~/home_ex ]; then
	for file in $(find ~/home_ex/xdgconfig/zsh/ -name '*.zsh' -type f | sort); do
		source "${file}"
	done
fi

# [Depricated] 拡張用の設定ファイルを読み込む
if [ -e ~/.zsh_ex ]; then
	for file in $(find ~/.zsh_ex/ -name '*.zsh' -type f | sort); do
		source "${file}"
	done
fi

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ------------------------------
# General Settings
# ------------------------------
source ~/.envrc

# load common scripts
for file in $(find ${XDG_CONFIG_HOME}/zsh -name '*.zsh' -type f | sort); do
	source "${file}"
done

# 拡張用の設定ファイルを読み込む
if [ -e ~/home_ex ]; then
	for file in $(find ~/home_ex/zsh/ -name '*.zsh' -type f | sort); do
		source "${file}"
	done
fi

# [Depricated] 拡張用の設定ファイルを読み込む
if [ -e ~/.zsh_ex ]; then
	for file in $(find ~/.zsh_ex/ -name '*.zsh' -type f | sort); do
		source "${file}"
	done
fi

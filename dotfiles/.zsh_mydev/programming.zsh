#
# プログラミング言語系の環境設定
#


# ----------------------------------------------------------------------------------------------------
# settings for golang
# ----------------------------------------------------------------------------------------------------
export GOPATH=${HOME}/go
export PATH=/usr/local/go/bin:${HOME}/go/bin:$PATH
export GO111MODULE=on

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/owner/google-cloud-sdk/path.zsh.inc' ]; then source '/home/owner/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/owner/google-cloud-sdk/completion.zsh.inc' ]; then source '/home/owner/google-cloud-sdk/completion.zsh.inc'; fi
# ----------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------
# settings for javascript
# https://github.com/sindresorhus/guides/blob/main/npm-global-without-sudo.md
# mkdir -p "${HOME}/.npm-packages"
# npm config set prefix "${HOME}/.npm-packages"

NPM_PACKAGES="${HOME}/.npm-packages"

export PATH="$PATH:$NPM_PACKAGES/bin"
# ----------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------
# settings for rust
# ----------------------------------------------------------------------------------------------------
export PATH=$PATH:~/.cargo/bin
# ----------------------------------------------------------------------------------------------------




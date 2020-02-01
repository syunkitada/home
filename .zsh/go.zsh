export GOENV_ROOT=$HOME/.goenv
export PATH=$GOENV_ROOT/bin:$PATH
eval "$(goenv init -)"
export PATH=$PATH:$GOPATH/bin
export GO111MODULE=off

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/owner/google-cloud-sdk/path.zsh.inc' ]; then source '/home/owner/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/owner/google-cloud-sdk/completion.zsh.inc' ]; then source '/home/owner/google-cloud-sdk/completion.zsh.inc'; fi

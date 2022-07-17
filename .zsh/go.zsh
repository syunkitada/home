export GOPATH=${HOME}/go
export PATH=/usr/local/go/bin:${HOME}/go/bin:$PATH
export GO111MODULE=on

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/owner/google-cloud-sdk/path.zsh.inc' ]; then source '/home/owner/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/owner/google-cloud-sdk/completion.zsh.inc' ]; then source '/home/owner/google-cloud-sdk/completion.zsh.inc'; fi

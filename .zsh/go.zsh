export PATH=${PATH}:/usr/local/go/bin
export GOPATH=${HOME}/go

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/owner/google-cloud-sdk/path.zsh.inc' ]; then source '/home/owner/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/owner/google-cloud-sdk/completion.zsh.inc' ]; then source '/home/owner/google-cloud-sdk/completion.zsh.inc'; fi

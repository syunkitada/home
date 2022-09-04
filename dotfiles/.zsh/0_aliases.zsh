### Aliases ###
# for interactive operation
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# alias for misc
alias grep='grep --color'

# alias for some shortcuts for different directory listings
alias ls='ls -hF --color=always --show-control-chars'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# git関連のコマンド
# [COMMAND] key=gl; tags=git; action=lazygitを起動します;
alias gl='lazygit'

# tmux関連のコマンド
# [COMMAND] key=t; tags=tmux; action=over tmuxを起動します;
alias t='tmux'
# [COMMAND] key=tt; tags=tmux; action=under tmuxを起動します;
alias tt='IS_TMUXT=true tmux'
# [COMMAND] key=ta; tags=tmux; action=tmuxセッションにアタッチします;
alias ta='tmux a'
# [COMMAND] key=tl; tags=tmux; action=tmuxセッション一覧を表示します;
alias tl='tmux ls'

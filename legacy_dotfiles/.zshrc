bindkey -e # Set keybind to emacs

# Set Color
autoload -U colors; colors

### Ls Color ###
export LSCOLORS=ExFxCxdxBxegedabagacad
export CLICOLOR=true

tmp_prompt="
%D{%H:%M:%S} [%?,%j] %n@%{${fg[red]}%}%M%{${reset_color}%}:%~
\$ "
tmp_prompt2="%{${fg[cyan]}%}%_> %{${reset_color}%}"
tmp_sprompt="%{${fg[yellow]}%}%r is correct? [Yes, No, Abort, Edit]:%{${reset_color}%}"

PROMPT=$tmp_prompt
PROMPT2=$tmp_prompt2
SPROMPT=$tmp_sprompt

function mssh() {
    if [ $# != 1 ]; then
        echo "Usage: mssh [file]"
        return 1
    fi
    _mssh `cat $1`
}

function _mssh() {
    tmux new-window "ssh $1"
    shift
    for host in "$@";
    do
        tmux split-window "ssh -A $host"
        tmux select-layout even-horizontal > /dev/null
    done
    tmux set-window-option synchronize-panes on
    tmux select-layout tiled
}

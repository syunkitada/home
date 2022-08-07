# ----------------------------------------------------------------------------------------------------
# doc関連
# ----------------------------------------------------------------------------------------------------

docs_dir=~/docs

_git_clone() {
    git_repo=$1
    git_dir="${docs_dir}/`echo $git_repo | awk -F '/' '{print $NF}' | awk -F '.' '{print $1}'`"
    if [ ! -e $git_dir ]; then
        git clone $git_repo $git_dir
    else
        cd $git_dir
        git pull
    fi
}

make_docs() {
    mkdir -p $docs_dir
    _git_clone "git@github.com:syunkitada/programming_python.git"
}

alias doc='cd ~/home/docs && vim .'
alias docm=make_docs
alias docp="cd ${docs_dir} && find_grep_and_vim"

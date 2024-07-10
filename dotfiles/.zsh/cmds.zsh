#
# tmux helpers
#
function _tmux_new_cmd() {
	tmux new-window "bash --rcfile <(echo '$*')"
}

function _tmux_split_cmd() {
	tmux split-window "bash --rcfile <(echo '$*')"
}

function tx() {
	for i in {2..$1}; do
		tmux split-window "zsh"
	done
	tmux select-layout tiled
}

#
# ssh, scp helpers
#
# [COMMAND] key=ssh [options] dest [command]; tags=ssh; action=sshを実行します;
# [COMMAND] key=mssh [file]; tags=ssh; action=指定したファイルに記述されてるホスト一覧ごとにtmuxのパネルを作成してsshします;
function mssh() {
	if [ $# != 1 ]; then
		echo "Usage: mssh [file]"
		return 1
	fi
	_mssh $(cat $1)
}

function _mssh() {
	# 1つ目のホストに新しいwindowでsshする
	tmux new-window "ssh $1"
	# 2つ目以降のホストにsshする
	shift
	for host in "$@"; do
		tmux split-window "ssh -A $host"
		# tmux select-layout even-vertical > /dev/null
		tmux select-layout even-horizontal >/dev/null
	done
	tmux set-window-option synchronize-panes on
	tmux select-layout tiled
}

# [COMMAND] key=cssh [file] [command]; tags=ssh; action=指定したファイルに記述されてるホスト一覧ごとにtmuxのパネルを作成してsshで[command]を実行します;
function cssh() {
	if [ $# != 1 ]; then
		echo "Usage: cssh [file] [command]"
		return 1
	fi

	file=$1
	shift
	for host in $(cat $file); do
		result=$(ssh $host "$@")
		echo "${host}[$?] $result"
	done
}

# [COMMAND] key=scp [options] src dest; tags=ssh; action=scpでファイルを転送します;
# [COMMAND] key=scphome [host]; tags=ssh; action=homeの設定ファイルを[host]へscpします;
function scphome() {
	if [ $# != 1 ]; then
		echo "Usage: scphome [target]"
		return 1
	fi

	cd
	set -x
	tar -czf repos.tar.gz .cache/neovim-dein
	tar -czf home.tar.gz home
	tar -czf localsharenvim.tar.gz .local/share/nvim
	scp repos.tar.gz $1:
	scp home.tar.gz $1:
	scp localsharenvim.tar.gz $1:
	ssh $1 rm -rf ~/home
	ssh $1 rm -rf ~/.cache
	ssh $1 rm -rf ~/.local
	ssh $1 tar -xf ~/repos.tar.gz -C ~/
	ssh $1 tar -xf ~/home.tar.gz -C ~/
	ssh $1 tar -xf ~/localsharenvim.tar.gz -C ~/
	ssh $1 rm -rf ~/repos.tar.gz
	ssh $1 rm -rf ~/home.tar.gz

	ssh $1 rm -rf .local/share/nvim

	rm -rf repos.tar.gz
	rm -rf home.tar.gz
	set +x
	cd -
}

# [COMMAND] key=setup-dockerhome [host]; tags=docker; action=docker上での開発環境を整えます。
function setup-dockerhome() {
	if [ $# != 1 ]; then
		echo "Usage: dockercphome [container]"
		sudo docker ps
		return 1
	fi

	cd
	set -x
	sudo docker cp home $1:/root/
	sudo docker exec $1 bash -c 'cd /root/home && make setup'
	set +x
	cd -
}

#
# network helpers
#
function mping() {
	if [ $# != 1 ]; then
		echo "Usage: mping [file]"
		return 1
	fi

	_mping $(cat $1)
}

function _mping() {
	_tmux_new_cmd 'while true; do echo "`date +\"%H:%M:%S\"` `ping '$1' -c 1 -w 1 -W 1 | sed -n 2P`"; sleep 1s; done'
	shift
	for host in "$@"; do
		_tmux_split_cmd 'while true; do echo "`date +\"%H:%M:%S\"` `ping '$host' -c 1 -w 1 -W 1 | sed -n 2P`"; sleep 1s; done'
		tmux select-layout even-horizontal >/dev/null
	done
	tmux set-window-option synchronize-panes on
	tmux select-layout tiled
}

function wping() {
	if [ $# != 1 ]; then
		echo "Usage: wping [target]"
		return 1
	fi

	while true; do
		echo "$(date +"%H:%M:%S") $(ping $1 -c 1 -w 1 -W 1 | sed -n 2P)"
		sleep 1s
	done
}

function wcurl() {
	if [ $# != 1 ]; then
		echo "Usage: wcurl [target]"
		return 1
	fi

	while true; do
		echo "$(date +"%H:%M:%S") $1 $(curl $1 --connect-timeout 1 -s -o /dev/null -w 'time=%{time_starttransfer}s code=%{http_code}\n' -s)"
		sleep 1s
	done
}

function wdig() {
	if [ $# != 1 ]; then
		echo "Usage: wdig [target]"
		return 1
	fi

	while true; do
		echo "$(date +"%H:%M:%S") $1 $(\time -f '%e' -- dig +short $1 2>&1 | sed -r -e ':loop;N;$!b loop;s/\n/ time=/g')"
		sleep 1s
	done
}

# [COMMAND] key=ssh-add -l; tags=ssh; action=登録済みのssh鍵一覧を表示します;
# [COMMAND] key=sshadd; tags=ssh; action=ssh-agentに鍵を登録します;
alias sshadd="run_ssh_agent_and_ssh_add"
function run_ssh_agent_and_ssh_add() {
	ssh_auth_sock="$HOME/.ssh/agent"
	if [ -z "$SSH_AUTH_SOCK" ]; then
		# SSH_AUTH_SOCKが設定されてなければ設定する
		export SSH_AUTH_SOCK=$ssh_auth_sock
	fi
	if [ -n "$SSH_AGENT_PID" ]; then
		# SSH_AGENT_PIDが設定されており、プロセスが正しく存在するなら、ssh-add して終わり
		if kill -0 $SSH_AGENT_PID; then
			ssh_add
			return 0
		fi
	fi
	# ssh-agentが存在するなら、それをSSH_AGENT_PIDに設定して、ssh-addして終わり
	if pid=$(pgrep ssh-agent); then
		export SSH_AGENT_PID=$pid
		ssh_add
		return 0
	fi

	# 既存のsocketとプロセスを削除してから、ssh-agentを起動する
	rm -rf /tmp/ssh-*
	pkill ssh-agent
	eval $(ssh-agent)

	ln -snf "$SSH_AUTH_SOCK" $ssh_auth_sock
	export SSH_AUTH_SOCK=$ssh_auth_sock
	ssh_add
}

function ssh_add() {
	echo "SSH_AGENT_PID=${SSH_AGENT_PID}"
	echo "SSH_AUTH_SOCK=${SSH_AUTH_SOCK}"
	if ssh-add -l | grep ED25519; then
		echo "ssh-key is already registered"
	else
		ssh-add ~/.ssh/id_ed25519
	fi
}

# [COMMAND] key=genpass; tags=util; action=ランダムなパスワードを生成します;
function genpass() {
	cat /dev/urandom | tr -dc 'a-zA-Z0-9-_!?' | fold -w 64 | head -n 16 | sort -u
}

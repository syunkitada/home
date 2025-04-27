# Configure .gitconfig

git config --global credential.helper 'cache --timeout=2592000'

if [ "$(git config --global --get user.name)" = "" ]; then
	echo "Please configure git user.name
$ git config --global user.name $(whoami)
"
fi

if [ "$(git config --global --get user.email)" = "" ]; then
	echo "Please configure git user.email
$ git config --global user.email $(whoami)@example.com
"
fi

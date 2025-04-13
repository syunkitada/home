# zshがあるならzshを使う
[ -x "/bin/zsh" ] && exec /bin/zsh

echo "zsh isn't installed."

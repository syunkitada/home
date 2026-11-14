# Herdr command completion
if command -v herdr >/dev/null 2>&1; then
	source <(herdr completion zsh)
	compdef _herdr herdr
fi

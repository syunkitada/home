# https://github.com/sindresorhus/guides/blob/main/npm-global-without-sudo.md
# mkdir -p "${HOME}/.npm-packages"
# npm config set prefix "${HOME}/.npm-packages"

NPM_PACKAGES="${HOME}/.npm-packages"

export PATH="$PATH:$NPM_PACKAGES/bin"

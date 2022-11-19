#!/bin/bash

# Setup rust environment
if [ ! -e ~/.cargo ]; then
	curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path --profile default
fi

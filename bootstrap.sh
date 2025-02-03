#!/usr/bin/env bash

USER=$(id -un)
USER_GROUP=$(id -gn)

force=false
pull=false

for arg in "$@"; do
	case $arg in
	--pull | -p)
		pull=true
		;;
	esac
done

echo "Syncronising dotfiles..."

cd "$(dirname "${BASH_SOURCE}")"

if $pull; then
	echo "Pulling latest"
	git pull origin main
fi

function installDependencies() {
	echo "Installing Dependencies"

	echo "USER $USER HOME $HOME"

	sudo apt-get update
    if ! sudo apt-get install -y git rsync; then
        echo "Failed to install dependencies"
        exit 1
    fi
}

function syncDotfiles() {
	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		-avh --no-perms . $HOME
	echo "dotfiles have been synced!"
}

function installPackages() {
	echo "Installing Packages"

	if [ -d "$HOME/.local/bin" ]; then
		mkdir -p $HOME/.local/bin
	fi

	# Install vim, if not already installed
	if ! command -v vim &>/dev/null; then
		echo "Installing vim"
		sudo apt-get install -y vim
	else
		echo "vim is already installed"
	fi

	# Install laygit
	# https://github.com/jesseduffield/lazygit
	if ! command -v lazygit &>/dev/null; then
		echo "Installing lazygit"

		LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
		curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
		tar xf lazygit.tar.gz lazygit
		sudo install -o $USER -g $USER_GROUP lazygit -D -t $HOME/.local/bin/
	else
		echo "lazygit is already installed"
	fi

	echo "Packages have been installed!"
}

function cleanup {
	apt-get clean && rm -rf /var/lib/apt/lists/*
}

installDependencies

syncDotfiles
source $HOME/.bash_profile

installPackages
source $HOME/.bash_profile

cleanup

unset installDependencies syncDotfiles installPackages cleanup

echo "Bootstrap Complete"

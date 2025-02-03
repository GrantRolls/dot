#!/usr/bin/env bash

USER_GROUP=$(id -gn)

force=false
pull=false

for arg in "$@"; do
  case $arg in
    --pull|-p)
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

function syncDotfiles() {
    cp -r --preserve=mode,timestamps \
        --exclude=".git" \
        --exclude="bootstrap.sh" \
        --exclude="README.md" \
        . ~
	echo "dotfiles have been synced!"
}

function installPackages() {
	echo "Installing Packages"	
	sudo apt-get update

	# Install vim, if not already installed
	if ! command -v vim &>/dev/null; then
		echo "Installing vim"
		sudo apt install -y vim
	else
		echo "vim is already installed"
	fi

	if [ -d "$HOME/.local/bin" ]; then
		mkdir -p $HOME/.local/bin
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

syncDotfiles()
source ~/.bash_profile
installPackages()
source ~/.bash_profile

unset syncDotfiles installPackages

echo "Bootstrap Complete"	

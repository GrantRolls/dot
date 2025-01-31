#!/usr/bin/env bash

force=false
pull=false

for arg in "$@"; do
  case $arg in
    --force|-f)
      force=true
      ;;
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

# pre-req, rsync required
# Install rsync, if not already installed
if ! command -v rsync &>/dev/null; then
	echo "Installing rsync"
	sudo apt-get install -y rsync
fi

function doIt() {
	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		-avh --no-perms . ~
	source ~/.bash_profile
}

if $force; then
	doIt
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
	echo ""
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt
	fi
fi
echo "dotfiles have been Syncronising!"
unset doIt

echo "Installing Packages"
sudo apt-get update

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
	sudo install lazygit -D -t $HOME/.local/bin/
else
	echo "lazygit is already installed"
fi

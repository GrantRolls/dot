#!/usr/bin/env bash

USER=$(id -un)
USER_GROUP=$(id -gn)

pull=false
branch="main"

while [[ $# -gt 0 ]]; do
    case $1 in
	--pull | -p)
		pull=true
		shift
		;;

	--branch | -b)
		branch=$2
		shift 2
		;;
	esac
done

cd "$(dirname "${BASH_SOURCE}")"

function installDependencies() {
	echo "Installing Dependencies"
	sudo apt-get update
	if ! sudo apt-get install -y git rsync curl; then
		echo "Failed to install dependencies"
		exit 1
	fi
}

function dotsUpdate {
	branch=$1
	pull="${2:-false}"

	if git rev-parse --verify "$branch" >/dev/null 2>&1; then
		git checkout "$branch"
	fi

	if [ "$pull" = true ]; then
		echo "Pulling latest of $branch"
		git pull origin $branch
	fi
}

function syncDotfiles() {
	echo "Syncronising dotfiles to $HOME"

	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "bootstrap.sh" \
		--exclude "dotsInstallPackages" \
		--exclude "dotsUpdate" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		-avh --no-perms . $HOME
	echo "dotfiles have been synced!"
}

function cleanup {
	sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*
	unset installDependencies dotsUpdate syncDotfiles
}

installDependencies
dotsUpdate

syncDotfiles
source $HOME/.bash_profile

source dotsInstallPackages
dotsInstallPackages
unset dotsInstallPackages

source $HOME/.bash_profile

cleanup

echo "💪 Bootstrap Complete"

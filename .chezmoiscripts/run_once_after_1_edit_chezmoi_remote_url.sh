#!/bin/bash

set -o pipefail

function getGitRemoteURL(){
	chezmoi git remote get-url origin
}
currentRemoteURL=$(getGitRemoteURL)
echo current git remote origin $currentRemoteURL

if [[ "$currentRemoteURL" == git@* ]]
then
	echo "already SSH | exit"
	exit 0
fi

read -p "Do you want to change git http url to ssh url? (y/n or enter): " -n 1
if [[ "$REPLY" == "y" ]]; then
    remoteSSH=$(chezmoi git remote get-url origin | sed 's#https://github.com/#git@github.com:#')
    echo change to $remoteSSH
    chezmoi git remote set-url origin $remoteSSH

    echo ">> $(getGitRemoteURL)"
fi

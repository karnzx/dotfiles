#!/bin/bash

set -o pipefail

function getGitRemoteURL() {
    ~/bin/chezmoi git remote get-url origin
}
cd $(~/bin/chezmoi source-path)
currentRemoteURL=$(getGitRemoteURL)
echo current git remote origin "$currentRemoteURL"

if [[ "$currentRemoteURL" == git@* ]]; then
    echo "already SSH | exit"
    exit 0
fi

read -r -p "Do you want to change git http url to ssh url? (y/n or enter): " -n 1
echo
if [[ "$REPLY" == "y" ]]; then
    remoteSSH=$(~/bin/chezmoi git remote get-url origin | sed 's#https://#ssh://git@#')
    echo change to "$remoteSSH"
    ~/bin/chezmoi git remote set-url origin "$remoteSSH"

    echo ">> $(getGitRemoteURL)"
fi
cd - &> /dev/null

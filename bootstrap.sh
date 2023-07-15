#!/bin/bash

# NOTE: echo with >&2 is to make it appear only in screen because i want normal echo to be return of function

set -ueEo pipefail

install_requirements(){
    echo -e "Install requirements"
    sudo sh -c "apt-get update -qq >/dev/null"
    pre_reqs=(
        zip
    )
    sudo sh -c "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $pre_reqs >/dev/null"
}

install_bitwarden-cli(){
    command -v bw &>/dev/null && return 0
    local tmp
    tmp="$(mktemp -d)"
    pushd -- "$tmp"
    echo -e "Install Bitwarden-cli"
    curl -fSL "https://vault.bitwarden.com/download/?app=cli&platform=linux" -o bw.zip
    # unzip very quiet and move to /usr/local/bin
    sudo sh -c "unzip -qq bw.zip -d /usr/local/bin/" 
    sudo chmod +x /usr/local/bin/bw
    popd
}

bitwarden_login() {
    # perform login
    local bw_session
    bw_session=$(bw login ${BITWARDEN_EMAIL:-} --raw)
    if [ ! -z $bw_session ]; then
        echo $bw_session
    else
        echo "Login failed." >&2
        exit 1
    fi
}

bitwarden_unlock(){
    echo -e "Bitwarden unlock the vault" >&2
    # get bitwarden login session
    if bw status | grep -q '"status":"unauthenticated"'; then
        # not logged in, call login function
        echo "Not logged in, try login" >&2
        bitwarden_login
    else
        # already logged in
        local bw_session
        echo "Unlock vault with current user" >&2
        bw_session=$(bw unlock --raw)
        echo $bw_session
    fi
}
do_bootstrap(){
    # GITHUB_USERNAME as username of github repo | if empty default value is karnzx
    # BITWARDEN_EMAIL as email of bitwarden vault | if empty bw will read email from input
    echo -e "do bootstrap"
    local bw_session
    bw_session=$(bitwarden_unlock)
    # install chezmoi and apply dotfiles
    BW_SESSION=$bw_session sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ${GITHUB_USERNAME:-karnzx}
    echo -e "Bitwarden lock the vault"
    bw lock
}

install_requirements

install_bitwarden-cli

do_bootstrap
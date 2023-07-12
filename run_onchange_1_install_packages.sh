#!/bin/bash

# for no confussed
## (( WSL )) || return 0 
### exit if not WSL # wsl=0 -> 0 = false -> do return 0
#
## (( !WSL )) || return 0
### exit if WSL # wsl=1 -> !1 = 0 = false -> do return 0

set -xueE -o pipefail

if [[ "$(</proc/version)" == *[Mm]icrosoft* ]] 2>/dev/null; then
  readonly WSL=1 #true
else
  readonly WSL=0
fi

# Install a bunch of debian packages.
function install_packages() {
  local packages=(
    build-essential
    software-properties-common
    zsh
    rsync
    ssh
    curl
    wget
    gawk
    git
    man
    file
    htop
    libmagic1
    unzip
    zip
    tldr
    perl
    python3
    python3-pip
    socat 
    iproute2
    dnsutils
    num-utils
    zsh
    direnv
  )

  # if (( WSL )); then
  #   packages+=(dbus-x11)
  # fi

  sudo apt-get update
  sudo bash -c 'DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::options::=--force-confdef -o DPkg::options::=--force-confold upgrade -y'
  sudo apt-get install -y "${packages[@]}"
  sudo apt-get autoremove -y
  sudo apt-get autoclean
}

function install_docker() {
  command -v docker &>/dev/null && return 0
  curl -fsSL https://get.docker.com -o - | sh
  sudo usermod -aG docker $USER
}

function install_brew() {
  NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}

function install_tools(){
  local plugins=(
    # utils
    exa
    ripgrep
    jc
    yq
    jq
    bat
    diff-so-fancy
    neovim

    # cli
    awscli
    kubectl
    kubectx
    krew
    argocd
    k9s
    oha     # web load test in Rust https://github.com/hatoo/oha

    # monitoring
    bpytop  # better htop
    ctop    # docker contianer top
  )
  brew install "${plugins[@]}"
}

function install_krew_plugin(){
  local plugins=(
    oidc-login
  )
  kubectl krew install "${plugins[@]}"
}

function install_wsl2_ssh_pageant(){
  (( WSL )) || return 0
  # https://github.com/BlackReloaded/wsl2-ssh-pageant
  local win_home=$(wslpath $(cmd.exe /c 'echo %userprofile%' 2>/dev/null | sed 's/\r$//'))
  [ -d "$win_home/.ssh" ] || mkdir $win_home/.ssh
  [ -d "$HOME/.ssh" ] || mkdir "$HOME/.ssh"
  windows_destination="$win_home/.ssh/wsl2-ssh-pageant.exe"
  linux_destination="$HOME/.ssh/wsl2-ssh-pageant.exe"
  [ -f $linux_destination ] && return 0
  echo "Install wsl-ssh-pageant"
  wget -O "$windows_destination" "https://github.com/BlackReloaded/wsl2-ssh-pageant/releases/latest/download/wsl2-ssh-pageant.exe"
  chmod +x "$windows_destination"
  ln -sf $windows_destination $linux_destination
}

function install_in_tmp() {
  local tmp
  tmp="$(mktemp -d)"
  pushd -- "$tmp"
  popd
}


if [[ "$(id -u)" == 0 ]]; then
  echo "$BASH_SOURCE: please run as non-root" >&2
  exit 1
fi

umask g-w,o-w

install_packages
install_docker
install_brew
install_tools
install_krew_plugin
install_wsl2_ssh_pageant

echo SUCCESS

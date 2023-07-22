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
    libmagic1
    unzip
    zip
    tldr
    perl
    dnsutils
    num-utils # math
    zsh
    mycli
    httpie
    taskwarrior
    # packages require for tools
    socat iproute2 # install_wsl2_ssh_pageant
    libasound2-dev # install_focus
  )

  # if (( WSL )); then
  #   packages+=(dbus-x11)
  # fi

  sudo apt-get update -qq >/dev/null
  # DEBIAN_FRONTEND=noninteractive sudo apt-get install -y -qq $pre_reqs >/dev/null
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
  command -v brew &>/dev/null && return 0
  NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(brew shellenv)"
}

function share_tools(){
  # create symlink from brew to /usr/local/bin/
  local -A tools=(
    [nvim]="vim"
  )
  for key in "${!tools[@]}"; do
    printf "link %s to /usr/local/bin/%s\n" "$key" "${tools[$key]}"
    sudo ln -sf $HOMEBREW_PREFIX/bin/$key /usr/local/bin/${tools[$key]}
  done
}

function install_brew_packages(){
  local packages=(
    # utils
    exa
    ripgrep
    jc
    yq
    fx # interactive with JSON
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
    ghq     # Manage remote repository clones
    git-standup

    # monitoring
    bpytop  # better htop
    ctop    # docker contianer top
  )
  brew update
  brew install "${packages[@]}"
  share_tools
}

function install_krew_plugin(){
  local plugins=(
    oidc-login
  )
  kubectl krew install "${plugins[@]}"
}

# https://github.com/BlackReloaded/wsl2-ssh-pageant
function install_wsl2_ssh_pageant(){
  (( WSL )) || return 0
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

# pomodoro cli https://github.com/ayoisaiah/focus
function install_focus(){
    local version release_url
    version=${1-1.3.0}
    command -v focus &>/dev/null && focus -v | grep $version && return 0
    release_url=https://github.com/ayoisaiah/focus/releases/download/v${version}/focus_${version}_linux_amd64.tar.gz
    curl -LO $release_url
    tar -xvzf focus_${version}_linux_amd64.tar.gz
    chmod +x focus
    sudo mv focus /usr/local/bin
}

function install_in_tmp() {
  local tmp
  tmp="$(mktemp -d)"
  pushd -- "$tmp"
  "$@"
  popd
}


if [[ "$(id -u)" == 0 ]]; then
  echo "$BASH_SOURCE: please run as non-root" >&2
  exit 1
fi

umask g-w,o-w

install_packages
install_brew
install_brew_packages
install_krew_plugin
install_in_tmp install_focus

install_docker
install_wsl2_ssh_pageant

echo SUCCESS

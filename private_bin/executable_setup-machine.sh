#!/bin/bash

# for no confussed
## (( !WSL )) && return 0 
### exit if not WSL # wsl=0 -> !0 = 1 = true -> do return 0
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
    htop
    jq
    neovim
    libmagic1
    pipx
    command-not-found
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
    exa
    ripgrep
    jc
    yq
    bat
    diff-so-fancy

    awscli
    kubectl
    kubectx
    krew
    argocd
    k9s
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
  (( !WSL )) && return 0
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


# Avoid clock snafu when dual-booting Windows and Linux.
# See https://www.howtogeek.com/323390/how-to-fix-windows-and-linux-showing-different-times-when-dual-booting/.
function fix_clock() {
  (( !WSL )) || return 0
  timedatectl set-local-rtc 1 --adjust-system-clock
}

function win_install_fonts() {
  local dst_dir
  dst_dir="$(cmd.exe /c 'echo %LOCALAPPDATA%\Microsoft\Windows\Fonts' 2>/dev/null | sed 's/\r$//')"
  dst_dir="$(wslpath "$dst_dir")"
  mkdir -p "$dst_dir"
  local src
  for src in "$@"; do
    local file="$(basename "$src")"
    if [[ ! -f "$dst_dir/$file" ]]; then
      cp -f "$src" "$dst_dir/"
    fi
    local win_path
    win_path="$(wslpath -w "$dst_dir/$file")"
    # Install font for the current user. It'll appear in "Font settings".
    reg.exe add                                                 \
      'HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' \
      /v "${file%.*} (TrueType)" /t REG_SZ /d "$win_path" /f 2>/dev/null
  done
}

# Install a decent monospace font.
function install_fonts() {
  (( !WSL )) && return 0
  win_install_fonts ~/.local/share/fonts/NerdFonts/*.ttf
}

function add_to_sudoers() {
  # This is to be able to create /etc/sudoers.d/"$username". WITH NO PASSWORD
  if [[ "$USER" == *'~' || "$USER" == *.* ]]; then
    >&2 echo "$BASH_SOURCE: invalid username: $USER"
    exit 1
  fi

  sudo usermod -aG sudo "$USER"
  sudo tee /etc/sudoers.d/"$USER" <<<"$USER ALL=(ALL) NOPASSWD:ALL" >/dev/null
  sudo chmod 440 /etc/sudoers.d/"$USER"
}

function add_wsl_config() {
  (( !WSL )) && return 0
  [[ -f /etc/wsl.conf ]] && return 0
  cat <<EOF | sudo tee /etc/wsl.conf &>/dev/null
[boot]
systemd = true
[automount]
options = "metadata"
EOF
}

# function fix_dbus() {
#   (( !WSL )) && return 0
#   sudo dbus-uuidgen --ensure
# }

# Set preferences for various applications.
function set_preferences() {
  # X11
  if [[ -z "${DISPLAY+X}" ]]; then
    export DISPLAY=:0
  fi
}

function disable_motd_news() {
  (( !WSL )) || return 0
  sudo systemctl disable motd-news.timer
}

if [[ "$(id -u)" == 0 ]]; then
  echo "$BASH_SOURCE: please run as non-root" >&2
  exit 1
fi

umask g-w,o-w

add_to_sudoers
add_wsl_config

install_packages
install_docker
install_brew
install_fonts
install_tools
install_krew_plugin
install_wsl2_ssh_pageant

disable_motd_news

fix_clock
set_preferences

echo SUCCESS

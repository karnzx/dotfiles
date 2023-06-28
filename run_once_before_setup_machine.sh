#!/bin/bash

# for no confussed
## (( WSL )) || return 0 
### exit if not WSL # wsl=0 -> 0 = false -> do return 0
#
## (( !WSL )) || return 0
### exit if WSL # wsl=1 -> !1 = 0 = false -> do return 0

set -xueEo pipefail

umask o-w

mkdir -m 700 -p ~/.ssh/s

rm -rf ~/.cache

if [[ "$(</proc/version)" == *[Mm]icrosoft* ]] 2>/dev/null; then
  readonly WSL=1 #true
else
  readonly WSL=0
fi

sudo apt-get update
sudo sh -c 'DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" upgrade -y'
sudo apt-get install -y curl git
sudo apt-get autoremove -y
sudo apt-get autoclean

# install zsh5.8 on /usr/local/bin for non-root user  (default is /usr/bin)
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh-bin/master/install)" \
  sh -d /usr/local -e yes
sudo chsh -s /usr/local/bin/zsh "$USER"

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
  (( WSL )) || return 0
  [[ -f /etc/wsl.conf ]] && return 0
  cat <<EOF | sudo tee /etc/wsl.conf &>/dev/null
[boot]
systemd = true
[automount]
options = "metadata"
EOF
}

# Avoid clock snafu when dual-booting Windows and Linux.
# See https://www.howtogeek.com/323390/how-to-fix-windows-and-linux-showing-different-times-when-dual-booting/.
function fix_clock() {
  (( !WSL )) || return 0
  timedatectl set-local-rtc 1 --adjust-system-clock
}

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
  (( WSL )) || return 0
  win_install_fonts ~/.local/share/fonts/NerdFonts/*.ttf
}

# function fix_dbus() {
#   (( WSL )) || return 0
#   sudo dbus-uuidgen --ensure
# }

add_to_sudoers
add_wsl_config

install_fonts

disable_motd_news
fix_clock
set_preferences

# install package

# just run zsh to load new fresh dependency and exit
# -i for interactive (data download in interactive mode only)
bash -c "exec zsh -ic exit"

if [[ -t 0 && -n "${WSL_DISTRO_NAME-}" ]]; then
  read -p "Need to restart WSL to complete installation. Terminate WSL now? [y/N] " -n 1 -r
  echo
  if [[ ${REPLY,,} == @(y|yes) ]]; then
    wsl.exe --terminate "$WSL_DISTRO_NAME"
  fi
fi


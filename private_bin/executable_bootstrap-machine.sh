#!/bin/bash

set -xueEo pipefail

umask o-w

mkdir -m 700 -p ~/.ssh/s

rm -rf ~/.cache

sudo apt-get update
sudo sh -c 'DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" upgrade -y'
sudo apt-get install -y curl git
sudo apt-get autoremove -y
sudo apt-get autoclean

bash ~/bin/setup-machine.sh

# if [[ -f ~/bin/bootstrap-machine-private.sh ]]; then
#   bash ~/bin/bootstrap-machine-private.sh
# fi

if [[ -t 0 && -n "${WSL_DISTRO_NAME-}" ]]; then
  read -p "Need to restart WSL to complete installation. Terminate WSL now? [y/N] " -n 1 -r
  echo
  if [[ ${REPLY,,} == @(y|yes) ]]; then
    wsl.exe --terminate "$WSL_DISTRO_NAME"
  fi
fi

#!/bin/bash

# when `kubectl krew` not exist, skip install krew plugins
[[ ! $(kubectl krew version 2>/dev/null) ]] && exit 0

function add_index() {
    # index_name index_url
    kubectl krew index add "$1" "$2" || true
}

add_index netshoot https://github.com/nilic/kubectl-netshoot.it

kubectl krew install --no-update-index <<EOF
oidc-login
modify-secret
resource-capacity
access-matrix
whoami
tree
netshoot/netshoot

EOF

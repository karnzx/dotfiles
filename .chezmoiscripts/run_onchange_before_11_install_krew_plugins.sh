#!/bin/bash

# when `kubectl krew` not exist, skip install krew plugins
[[ ! $(kubectl krew version 2>/dev/null) ]] && exit 0

function add_index() {
    # index_name index_url
    kubectl krew index add "$1" "$2" || true
}

add_index default https://github.com/kubernetes-sigs/krew-index.git
add_index netshoot https://github.com/nilic/kubectl-netshoot.git

KREW_NO_UPGRADE_CHECK=1

kubectl krew install <<EOF
oidc-login
modify-secret
resource-capacity
access-matrix
whoami
tree
netshoot/netshoot

EOF

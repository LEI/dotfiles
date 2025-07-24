export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

# export KREW_ROOT="$HOME/.local/share/krew" # /usr/local/krew
pathmunge "${KREW_ROOT:-$HOME/.krew}/bin" after

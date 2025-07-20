export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

# export KREW_ROOT="$HOME/.local/share/krew" # /usr/local/krew
pathmunge "${KREW_ROOT:-$HOME/.krew}/bin" after

# https://kubernetes.io/docs/reference/kubectl/cheatsheet/#bash
if hash k 2>/dev/null && [ -f /usr/share/bash-completion/completions/kubectl ]; then
  source /usr/share/bash-completion/completions/kubectl
  complete -o default -F __start_kubectl k
fi

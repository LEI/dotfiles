export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

# export KREW_ROOT="$HOME/.local/share/krew" # /usr/local/krew
pathmunge "${KREW_ROOT:-$HOME/.krew}/bin" after

if hash k 2>/dev/null; then
  return
fi

k() {
  if [ $# -eq 0 ]; then
    if command -v k9s >/dev/null; then
      k9s --all-namespaces # --command=context
    else
      kubectl config get-contexts
    fi
  else
    kubectl "$@"
  fi
}

# https://kubernetes.io/docs/reference/kubectl/cheatsheet/#bash
if [ -f /usr/share/bash-completion/completions/kubectl ]; then
  source /usr/share/bash-completion/completions/kubectl
  complete -o default -F __start_kubectl k
fi

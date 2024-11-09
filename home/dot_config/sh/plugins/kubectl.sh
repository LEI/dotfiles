export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

if hash k 2>/dev/null; then
  return
fi

k() {
  if [ $# -eq 0 ]; then
    kubectl config get-contexts
  else
    kubectl "$@"
  fi
}

# https://kubernetes.io/docs/reference/kubectl/cheatsheet/#bash
if [ -f /usr/share/bash-completion/completions/kubectl ]; then
  source /usr/share/bash-completion/completions/kubectl
  complete -o default -F __start_kubectl k
fi

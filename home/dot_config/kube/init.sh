if command -v k9s >/dev/null; then
  alias K="k9s --all-namespaces"
fi

if command -v kubecolor >/dev/null; then
  alias kubectl=kubecolor
fi

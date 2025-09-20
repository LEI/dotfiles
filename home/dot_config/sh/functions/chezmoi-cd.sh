# Change directory of the current shell instead of spawning a new one
chezmoi-cd() {
  source_path="$(chezmoi source-path)"
  cd "$source_path" || exit 1
}

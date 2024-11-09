# FIXME: aliases and nushell are not available with sudo
# https://github.com/nushell/nushell/issues/8099#issuecomment-1952583562
# export def --wrapped sudo [...rest] {
#   let escaped_args = $rest
#     | range 1..
#     | each { || to nuon }
#     | str join ' '
#   ^sudo env XDG_RUNTIME_DIR=/run/user/0 nu --login --commands $'($rest.0) ($escaped_args)'
# }

# TODO: replace with native nushell commands where possible

# Confirm before overwriting
export alias cp = cp --interactive

# Print sizes in powers of 1024
export alias df = df --human-readable

# Show with human-readable units
export alias free = free --human

# Color matches
export alias grep = grep --color=auto

# List all files with colors, human-readable sizes and long format
export alias la = ls --all --long

# Print each PATH entry on a separate line
export alias path = echo $env.PATH

# Reload the configuration
export alias reload = exec nu

# TODO: check if command exists
export alias cat = bat
export alias e = editor
export alias o = open

# TODO: default arguments
export alias c = chezmoi
export alias d = docker
export alias k = kubectl
export alias t = tmux

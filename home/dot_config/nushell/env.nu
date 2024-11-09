use std/log
use std/util "path add"

const config_dir = $nu.default-config-dir | path expand

# FIXME: "value not representable as a string"
# $env.path ++= ["~/bin"]
# $env.path ++= ["~/.local/bin"]
path add "~/.local/bin"

# path add ($env.CARGO_HOME | path join "bin")
const cargo_path = "~/.cargo/env.nu" | path expand
# const cargo_path = ($nu.home-path | path join .cargo/env.nu)
source (if ($cargo_path | path exists) { $cargo_path } else { null })

if (which hx) != [] {
    $env.EDITOR = "hx"
} else if (which nvim) != [] {
    $env.EDITOR = "nvim"
} else if (which vim) != [] {
    $env.EDITOR = "vim"
} else if (which code) != [] {
    $env.EDITOR = "code"
} else if "EDITOR" not-in $env or $env.EDITOR == "" {
    log warning "EDITOR not found"
    $env.EDITOR = "vi"
}

if "VISUAL" not-in $env or $env.VISUAL == "" {
    $env.VISUAL = $env.EDITOR
}

# mkdir ~/.local/share/atuin/ # init.nu
if (which atuin) != [] {
    atuin init --disable-up-arrow nu | save ($config_dir | path join atuin.nu) --force
}

if (which zoxide) != [] {
    zoxide init nushell | save -f ($config_dir | path join zoxide.nu) --force
}

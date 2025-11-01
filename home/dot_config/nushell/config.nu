# Configuration

use std/log

# NOTE: nushell setup differs from the one documented here:
# https://carapace-sh.github.io/carapace-bin/setup.html#nushell

# https://www.nushell.sh/book/custom_completions.html#external-completions
let carapace_completer = {|spans: list<string>|
    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}

# https://www.nushell.sh/cookbook/external_completers.html#zoxide-completer
let zoxide_completer = {|spans|
    $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
}

# let external_completer = {|spans|
#     # https://github.com/nushell/nushell/issues/8483
#     let expanded_alias = scope aliases
#     | where name == $spans.0
#     | get -i 0.expansion

#     let spans = if $expanded_alias != null {
#         $spans
#         | skip 1
#         | prepend ($expanded_alias | split row ' ' | take 1)
#     } else {
#         $spans
#     }

#     match $spans.0 {
#         # carapace completions are incorrect for nu
#         # nu => $fish_completer
#         # fish completes commits and branch names in a nicer way
#         # git => $fish_completer
#         # carapace doesn't have completions for asdf
#         # asdf => $fish_completer
#         # FIXME: use zoxide completions for zoxide commands
#         __zoxide_z | __zoxide_zi => $zoxide_completer
#         _ => $carapace_completer
#     } | do $in $spans
# }

$env.config.completions.external = {
    enable: true
    max_results: 100
    # completer: $external_completer
}

$env.config.buffer_editor = $env.EDITOR? | default "vi"
$env.config.edit_mode = "vi" # or "emacs"
$env.config.history.max_size = 5_000_000
$env.config.show_banner = false
$env.config.table.mode = "none"

# # Define module and source search path
# const NU_LIB_DIRS = [
#   "~/.config/nushell/scripts"
# ]
# source myscript.nu

use modules *

# Direnv
# https://direnv.net/docs/hook.html#nushell
# $env.config.hooks.env_change.PWD = (
#     $env.config.hooks.env_change.PWD | append (source nu-hooks/nu-hooks/direnv/config.nu)
# )

const config_dir = $nu.default-config-dir | path expand

# Mise
# https://mise.jdx.dev/installing-mise.html#nushell
use ($config_dir | path join mise.nu)

# Atuin
# source ~/.local/share/atuin/init.nu
if (which atuin) == [] {
    log warning "Command 'atuin' not found"
}
const atuin_path = $config_dir | path join atuin.nu
source (if ($atuin_path | path exists) { $atuin_path } else { null })

# https://carapace-sh.github.io/carapace-bin/setup.html#nushell
source ~/.cache/carapace/init.nu

# Starship
# https://starship.rs/#nushell
# https://github.com/nushell/nu_scripts/blob/main/modules/prompt/starship.nu
if (which starship) == [] {
    log warning "Command 'starship' not found"
}
mkdir ($nu.data-dir | path join vendor/autoload)
starship init nu | save -f ($nu.data-dir | path join vendor/autoload/starship.nu)

# Zoxide
# https://github.com/ajeetdsouza/zoxide#installation
if (which zoxide) == [] {
    log warning "Command 'zoxide' not found"
}
const zoxide_path = $config_dir | path join zoxide.nu
source (if ($zoxide_path | path exists) { $zoxide_path } else { null })

# source ~/nu_scripts/themes/nu-themes/tokyo-storm.nu
const theme_path = $config_dir | path join themes/tokyo-storm.nu
source (if ($theme_path | path exists) { $theme_path } else { null })

# https://github.com/nushell/nu_scripts/tree/main/modules/docker
# https://github.com/nushell/nu_scripts/tree/main/modules/kubernetes

const local_path = $config_dir | path join local.nu
source (if ($local_path | path exists) { $local_path } else { null })

# export alias g = git

# def git_args [] {
#     {
#         # options: {
#         #     case_sensitive: false,
#         #     completion_algorithm: prefix,
#         #     positional: false,
#         #     sort: false,
#         # },
#         # completions: [cat, rat, bat]
#         completer: $completer
#     }
# }

# export def --wrapped g [...args: string@git_args] {
#     if $args != [] {
#         git ($args | str join " ")
#     } else {
#         git status --short
#     }
# }

# # https://github.com/nushell/nushell/issues/14504
# export def --wrapped g [...args] {
#     if $args != [] {
#         git ...$args
#     } else {
#         git status --short
#     }
# }

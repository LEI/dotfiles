#
# OS X completion
#

# Add tab completion for 'defaults read|write NSGlobalDomain' (or '-g')
complete -W "NSGlobalDomain" defaults

# Add 'killall' tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall

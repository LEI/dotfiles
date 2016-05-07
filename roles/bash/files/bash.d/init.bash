#
# Bash init
#

# https://github.com/mathiasbynens/dotfiles/blob/master/.bash_profile
# https://github.com/mathiasbynens/dotfiles/blob/master/.functions
# https://github.com/Bash-it/bash-it/blob/master/lib/helpers.bash
# https://github.com/Bash-it/bash-it/blob/master/plugins/available/base.plugin.bash

export DOT_BASH="$HOME/.bash.d"

source ~/.bash.d/loader.bash
source ~/.bash.d/theme/colors.bash

bash_load aliases
bash_load library
bash_load plugins

# for file in $DOT_BASH/{aliases,completion,library,plugins}/*.bash; do
#   if [[ -r "$file" ]] && [[ -f "$file" ]]; then
#     source "$file"
#   fi
# done

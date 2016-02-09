#!/usr/bin/env bash

# dot

# set -o xtrace
set -o nounset
set -o errexit
set -o pipefail

# Extend matching operators
shopt -s extglob
# Loop on dotfiles
shopt -s dotglob
# # Do not loop on empty directory
# shopt -s nullglob
# # Recursive globbing (bash 4)
# shopt -s globstar

boot() {
  unset -f boot

  check_env

  # Paths
  # export DOT_ROOT=$HOME/.dotfiles
  # cd $(dirname "${BASH_SOURCE[0]}")/..
  # cd $(dirname "$(readlink "${BASH_SOURCE[0]}")")/..
  # DOT_ROOT=$(pwd -P)
  DOT_TARGET=$HOME
  DOT_SCRIPT="$DOT_ROOT/script"
  DOT_RC_TEMPLATE="$DOT_SCRIPT/config/.dotrc.template"
  DOT_RC="$DOT_ROOT/.dotrc"

  source $DOT_SCRIPT/lib/import.sh # TODO import->load?
  # Load libraries
  import "lib/log"
  import "lib/usage"
  import "lib/utils"
  import "lib/prompt"
  import "lib/config"

  # Parse command options
  DOT_CMD=
  parse_arguments "$@"

  # Read config file and set config variables -> ${!DOT_CONFIG_SECTION_*}
  config "$DOT_RC" "$DOT_RC_TEMPLATE" || die "$DOT_RC"
  # var_dump "DOT_CONFIG_"

  # Set global script variables
  DEBUG="${DEBUG-${DOT_CONFIG_DEBUG-false}}"
  DRY_RUN="${DRY_RUN-${DOT_CONFIG_DRY_RUN-false}}"
  FORCE="${FORCE-${DOT_CONFIG_FORCE-false}}"
  TIMESTAMPS="${TIMESTAMPS-${DOT_CONFIG_TIMESTAMPS-false}}"

  # Platform specific
  UNAME=$(uname -s) # Darwin|Linux

  # Git config credential helper
  if [[ "$UNAME" = "darwin" ]]; then
    DOT_USER_GIT_CREDENTIAL="osxkeychain"
  else
    DOT_USER_GIT_CREDENTIAL="cache"
  fi

  # Greeting
  log_info "Hello, $DOT_USER_NICK" "$DOT_USER_NAME <$DOT_USER_EMAIL>"
  log_debug "Debug mode enabled" "$BASH_VERSION"
  log_debug "DRY RUN" "$DRY_RUN"

  # Start script
  dot "$DOT_CMD"
}

dot() {
  local cmd=$1

  case $cmd in
    install)
      dot_install
      ;;
    git)
      dot_git
      ;;
    list)
      dot_list
      ;;
    link)
      dot_bootstrap
      ;;
    defaults)
      dot_defaults
      ;;
    '') # Default to all
      confirm "Update git submodules" "" Y && dot_git
      confirm "**Homebrew install" "" Y && dot_install
      confirm "**Symlink files to $DOT_TARGET" "" Y && dot_bootstrap
      confirm "**Setup $UNAME specific defaults" "" Y && dot_defaults
      ;;
    *)
      log_error "Unsupported command" "$cmd"
      die "$cmd"
      ;;
  esac

  if [[ $? -eq 0 ]]; then
    log_success "Done" "= $?"
  else
    log_error "Error" "= $?"
    return $?
  fi
}

dot_install() {
  import "install/brew"
  import "install/cask"

  # Install dependencies
  install_brew && \
    install_cask || \
    log_warn "Install aborted" "= $?"
}

dot_git() {
  import "lib/git"
  git_submodule
}

dot_bootstrap() {
  import "bootstrap/templates"
  import "bootstrap/symlinks"

  # Bootstrap dotfiles
  bootstrap_templates && \
    bootstrap_symlinks build || \
    log_warn "Bootstrap aborted" "= $?"
}

dot_list() {
  import "bootstrap/symlinks"
  bootstrap_symlinks list
}

dot_defaults() {
  import "platform/defaults"

  # Set platform defaults
  platform_defaults || \
    log_warn "Defaults aborted" "= $?"
}

parse_arguments() {
  while [[ $# -gt 0 ]]; do
    local key=$1
    local val=${2-}
    # echo "Parsing $1 (#$#)"
    case $key in
      git|list|install|uninstall|link|unlink|defaults)
        # Check if a command is already defined
        [[ -n "${DOT_CMD-}" ]] && usage 1 "Too many arguments: $key"
        # Register main action
        DOT_CMD="$key"
        shift
        ;;
      -v|--verbose|--debug)
        DEBUG=true
        shift
        ;;
      -d|--dry-run)
        DRY_RUN=true
        shift
        ;;
      # -t|--target)
      # 	shift
      #
      # 	# Loop until next '-', cannot handle ' -' without quotes
      # 	# while [[ $# -gt 0 ]] && [[ $1 != -* ]]; do
      # 	# 	DOT_TARGET+=" $1"
      # 	# 	shift
      # 	# done
      #
      # 	# Check value until the delimiter '-' is found or end of args
      # 	if [[ $# -gt 0 ]] && [[ ! -z "$val" ]] && [[ $val != -* ]]; then
      # 		shift
      # 	else
      #         # Ask for the missing value
      #         local prompt="Please specify a target path (default: $HOME): "
      #         read -e -r -p "$prompt" val # -i "$HOME"
      #         # Use default
      #         [[ -z "$val" ]] && break
      # 	fi
      # 	# Check destination path
      # 	[[ -d "$val" ]] || usage 1 "Not a directory: $key $val"
      # 	DOT_TARGET="$val"
      # 	;;
      # --uninstall)
      #   UNINSTALL=true
      #   shift
      #   ;;
      -h|--help)
        usage
        ;;
      *)
        usage 1 "Unknown option: $key"
        ;;
    esac
  done
}

check_env() {
  MIN_BASH_VERSION=3
  ENV_BASH_VERSION=${BASH_VERSION%%[^0-9]*}

	if [[ $ENV_BASH_VERSION -lt $MIN_BASH_VERSION ]]; then
		die "This script requires bash > ${MIN_BASH_VERSION}"
	fi

  # Check files?
  if [[ ! -d "${DOT_ROOT-}" ]]; then
    die "${DOT_ROOT-undefined}: '\$DOT_ROOT' is not a directory"
  fi
}

die() {
  local message=${1:-Died}
  printf "%s\r\n" "${BASH_SOURCE[1]}: line ${BASH_LINENO[0]}: ${FUNCNAME[1]}: $message" >&2
  exit 1
}

[[ "$0" == "$BASH_SOURCE" ]] && boot "$@"

#!/bin/sh

run_single_task_main() (
  [ -z "$PARENT_FILENAME" ] && gen_inline_script "$0" && exit 0

  [ -n "$NO_RUN_SINGLE_TASK" ] && exit 0

  . "${REPO_ROOT}/lib/task_runner.sh"

  import_task_runner "${PARENT_FILENAME}"
  [ $# -ne 0 ] || set -- "${DEFAULT_TASK:-}"
  _run "$@"
)

run_task_main() (
  . "${REPO_ROOT}/lib/task_runner.sh"

  import_task_runner "${REPO_ROOT}/lib/bootstrap_script.sh"

  for f in "${REPO_ROOT}"/task/*.sh; do
    NO_RUN_SINGLE_TASK=1 TASK_DIR="${REPO_ROOT}/task" _import "${f}"
  done

  REPO_ROOT="${REPO_ROOT}" _run "$@"
)

# This function is copied from
# https://github.com/ko1nksm/readlinkf/blob/a1112ce3ff6be50da8f45abe6667e0e4be7d9bb8/readlinkf.sh#L40
readlinkf_readlink() {
  [ -n "${1:-}" ] || return 1
  max_symlinks=40
  CDPATH='' # to avoid changing to an unexpected directory

  target=$1
  [ -e "${target%/}" ] || target=${1%"${1##*[!/]}"} # trim trailing slashes
  [ -d "${target:-/}" ] && target="$target/"

  cd -P . 2>/dev/null || return 1
  while [ "$max_symlinks" -ge 0 ] && max_symlinks=$((max_symlinks - 1)); do
    if [ ! "$target" = "${target%/*}" ]; then
      case $target in
        /*) cd -P "${target%/*}/" 2>/dev/null || break ;;
        *) cd -P "./${target%/*}" 2>/dev/null || break ;;
      esac
      target=${target##*/}
    fi

    if [ ! -L "$target" ]; then
      target="${PWD%/}${target:+/}${target}"
      printf '%s\n' "${target:-/}"
      return 0
    fi

    target=$(readlink -- "$target" 2>/dev/null) || break
  done
  return 1
}

repo_root() (
  bootstrap_link_script_filename="$1"
  bootstrap_filename="$(readlinkf_readlink "$bootstrap_link_script_filename")"
  safe_cd "${bootstrap_filename%/*}/.."
  echo "${PWD}"
)

safe_cd() {
  #dir=$1
  cd "$1" >/dev/null \
    || {
      echo "'cd $1' failed, exiting." >&2
      exit "${HELPERS_ERROR:-2}"
    }
}

gen_inline_script() (
  bootstrap_link_name="$1"
  inline_script="eval BOOTSTRAP_LINK_NAME='${bootstrap_link_name}';
    eval PARENT_FILENAME=\"\$0\";
    export BOOTSTRAP_LINK_NAME;
    export PARENT_FILENAME;
    . '${bootstrap_link_name}'"

  echo "${inline_script}"
)

# Entry point

: "${BOOTSTRAP_LINK_NAME:=$0}"
: "${REPO_ROOT:=$(repo_root "${BOOTSTRAP_LINK_NAME}")}"

. "${REPO_ROOT}/lib/helpers.sh"


exit_if_invalid_repo_root "${REPO_ROOT}"

# Run the requested main "variant" based upon the name of the script link
script_should_import_only || "${BOOTSTRAP_LINK_NAME##*/}_main" "$@"

# FIXME: Need to return correct exist status from main method
#status=$?

unset BOOTSTRAP_LINK_NAME

# FIXME
#exit "${status}"

#!/bin/sh

. "${0%/*}/helpers.sh"

# Only need to run this test once when testing multiple shells, so exit for
# any shell that's NOT /bin/sh
current_shell_is_sh || exit "${HELPERS_SUCCESS:-}"

oneTimeSetUp() {
  shellcheck=$(command -v 'shellcheck')
  if [ -z "$shellcheck" ]; then
    shellcheck="shellcheck_missing"
  fi

  suite_addTest "run_shellcheck"
}

run_shellcheck() {(
  safe_cd "${_REPO_ROOT_DIR_:-}"
  : "${shellcheck_files:=$(get_modified_files_from_git)}"

  if [ ${#shellcheck_files} -eq 0 ]; then
    echo "no files to check"
    return "$HELPERS_SUCCESS"
  fi

  # shellcheck disable=SC2086  # Intentional, want word-splitting to occur
  shellcheck_files="$(get_valid_files_to_shellcheck $shellcheck_files)"

  echo "Running shellcheck ${shellcheck_files}"
  # shellcheck disable=SC2086  # Intentional, want word-splitting to occur
  $shellcheck ${shellcheck_files}
  assertTrue "ShellCheck exited with failure status" $?
)}

get_modified_files_from_git() {
  # filter 'dx' means exclude deleted and unknown files
  git diff --name-only --diff-filter=dx HEAD
}

get_valid_files_to_shellcheck() {
  while [ $# -gt 0 ]; do
    filename=$(echo "${1%[\n]}" | grep -E "(\.[b]?[az]?sh$|/bin/|bashrc$|rcrc|[^.]profile)") \
        && printf '%s ' "$filename"
    shift
  done
}

shellcheck_missing() {
  startSkipping
  _shunit_warn "ShellCheck not found, please install it."
}

if [ "$#" -gt 0 ] && [ "$1" = "--shellcheck-files" ]; then
  shift
  shellcheck_files="$*"
  shift $#
fi

SHUNIT_PARENT="$0" . shunit2

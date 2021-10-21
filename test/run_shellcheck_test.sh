#!/bin/sh

. "${0%/*}/lib/test_helpers.sh"

# Only need to run this test once when testing multiple shells, so exit for
# any shell that's NOT /bin/sh
current_shell_is_sh || exit "${HELPERS_SUCCESS:-}"

import_repo_script test/lib/run_shellcheck_helpers.sh

oneTimeSetUp() {
  shellcheck_runner="run_shellcheck_found"
  shellcheck=$(command -v 'shellcheck')

  if [ -z "$shellcheck" ]; then
    shellcheck_runner="run_shellcheck_missing"
  fi

  suite_addTest "run_shellcheck"
}

run_shellcheck() {
  $shellcheck_runner
  assertTrue "ShellCheck exited with failure status" $?
}

run_shellcheck_missing() {
  _shunit_warn "ShellCheck not found, please install it."
  startSkipping
}

run_shellcheck_found() {(
  safe_cd "${_REPO_ROOT_DIR_:-}"
  : "${shellcheck_files:=$(get_modified_files_from_git)}"

  shellcheck_files="$(get_valid_files_to_shellcheck "$shellcheck_files")"

  if [ ${#shellcheck_files} -eq 0 ]; then
    echo "No files to check"
    return "$HELPERS_SUCCESS"
  fi

  echo "Running $shellcheck $shellcheck_files"
  # shellcheck disable=SC2086  # Intentional, want word-splitting to occur
  $shellcheck $shellcheck_files
)}

### Main

if [ "$#" -gt 0 ] && [ "$1" = "--shellcheck-files" ]; then
  shift
  shellcheck_files="$*"
  shift $#
fi

SHUNIT_PARENT="$0" . shunit2

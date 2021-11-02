# shellcheck shell=sh

HELPERS_TRUE=0
# These variables are used in scripts that source this helper file
# shellcheck disable=SC2034  # https://github.com/koalaman/shellcheck/wiki/SC2034
HELPERS_FALSE=1
# shellcheck disable=SC2034
HELPERS_SUCCESS=$HELPERS_TRUE
# shellcheck disable=SC2034
HELPERS_ERROR=2

script_main_should_run() {
  # Run the script if it's not a unit test
  [ -z "${SHUNIT_VERSION:-}" ]
}

script_should_import_only() {
  ! script_main_should_run
}

exit_if_invalid_repo_root() {
  repo_dir_to_test="$1"
  echo "Checking repo root $repo_dir_to_test" >&2

  if [ -z "$repo_dir_to_test" ] || [ ! -d "$repo_dir_to_test" ]; then
    echo "Failed to find repo root" >&2
    exit 1
  fi
}

# TODO: Move to bootstrap script
safe_cd() {
  #dir=$1
  cd "$1" >/dev/null || { echo "'cd $1' failed, exiting." >&2; exit "${HELPERS_ERROR}"; }
}

is_set_e_enabled() { (
  set_e_state=$( (
    false
    echo 'disabled'
  ) | cat)
  [ "${set_e_state}" != 'disabled' ]
) }

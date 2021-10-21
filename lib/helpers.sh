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

safe_cd() {
  #dir=$1
  cd "$1" >/dev/null || { echo "'cd $1' failed" >&2; exit "${HELPERS_ERROR}"; }
}

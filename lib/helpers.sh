#!/bin/sh

HELPERS_TRUE=0
HELPERS_FALSE=1
HELPERS_ERROR=2

script_main_should_run() {
  # Run the script if it's not a unit test
  [ -z "${SHUNIT_VERSION:-}" ]
}

safe_cd() {
  #dir=$1
  cd "$1" >/dev/null || (echo "'cd $1' failed" >&2; exit 1)
}

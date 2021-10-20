#!/bin/sh

. "${0%/*}/test/lib/test_helpers.sh"

SHUNIT2_VERSION=2.1.8
SHUNIT2_TEST_RUNNER_SCRIPT_NAME='test_runner'
RUN_TEST_SCRIPT_ARGS="$*"
WORKING_DIR=$(pwd)

main() {
  repo_root="${_REPO_ROOT_DIR_:-}"

  exit_if_invalid_repo_root "$repo_root"

  out_bin_dir="${_OUT_DIR_:-}/bin"

  if [ ! -x "$out_bin_dir/$SHUNIT2_TEST_RUNNER_SCRIPT_NAME" ]; then
    download_shunit2_scripts "$out_bin_dir"
  fi

  PATH="$out_bin_dir:$PATH"
  run_tests "$out_bin_dir"
}

exit_if_invalid_repo_root() {
  repo_dir_to_test="$1"
  echo "Checking repo root $repo_dir_to_test"

  if [ -z "$repo_dir_to_test" ] || [ ! -d "$repo_dir_to_test" ]; then
    echo "Failed to find repo root"
    exit 1
  fi
}

download_shunit2_scripts() {
  destination_dir="$1"
  mkdir -p "$destination_dir"
  safe_cd "$destination_dir"

  curl -k -L "https://github.com/kward/shunit2/archive/v${SHUNIT2_VERSION}.tar.gz" | \
      tar --strip-components=1 -zxv '**/shunit2' '**/test_runner' '**/lib'

  safe_cd "$WORKING_DIR"
}

run_tests() {(
  shunit2_bin_dir="$1"
  safe_cd "$_REPO_ROOT_DIR_/test"

  source_test_runner "$shunit2_bin_dir"

  _lib_dir="$shunit2_bin_dir/lib"
  # NOTE: Setting tests='' to avoid unbound variable error in main caused by using set -e
  LIB_DIR=$_lib_dir tests='' main "$RUN_TEST_SCRIPT_ARGS"
)}

source_test_runner() {
  # Arg $1 - the dir where the shunit2 scripts are
  _orig_shunit_version="${SHUNIT_VERSION:-}"

  # Pull in the shunit2 test_runner, but set SHUNIT_VERSION so it doesn't run yet
  SHUNIT_VERSION="DoNotRun" . "$1/test_runner"

  if [ -n "$_orig_shunit_version" ]; then
    SHUNIT_VERSION="$_orig_shunit_version"
  else
    unset SHUNIT_VERSION
  fi
}

script_main_should_run && main

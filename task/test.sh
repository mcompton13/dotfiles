#!/bin/sh

task_test() { # Run all of the tests under 'test/*', call with '-h' flag to see usage.
  . "${REPO_ROOT:-}/test/lib/test_helpers.sh"

  SHUNIT2_VERSION=2.1.8
  SHUNIT2_TEST_RUNNER_SCRIPT_NAME='test_runner'
  RUN_TEST_SCRIPT_ARGS="$*"
  WORKING_DIR=$(pwd)

  out_bin_dir="${REPO_ROOT:-}/out/bin"

  if [ ! -x "$out_bin_dir/$SHUNIT2_TEST_RUNNER_SCRIPT_NAME" ]; then
    download_shunit2_scripts "$out_bin_dir"
  fi

  PATH="$out_bin_dir:$PATH"
  run_tests "$out_bin_dir"
}

download_shunit2_scripts() {
  destination_dir="$1"
  mkdir -p "$destination_dir"
  safe_cd "$destination_dir"

  curl -k -L "https://github.com/kward/shunit2/archive/v${SHUNIT2_VERSION}.tar.gz" \
      | tar --strip-components=1 -zxv '**/shunit2' '**/test_runner' '**/lib'

  safe_cd "$WORKING_DIR"
}

run_tests() {(
  shunit2_bin_dir="$1"
  safe_cd "${REPO_ROOT:-}/test"

  source_test_runner "$shunit2_bin_dir"

  _lib_dir="$shunit2_bin_dir/lib"
  # NOTE: Setting tests='' to avoid unbound variable error in main caused by using set -u
  LIB_DIR=$_lib_dir tests='' main "$RUN_TEST_SCRIPT_ARGS"
)}



source_test_runner() {
  # Arg $1 - the dir where the shunit2 scripts are
  _orig_shunit_version="${SHUNIT_VERSION:-}"

  # Test runner script does not work with set -e enabled so disable it
  set +e

  # Pull in the shunit2 test_runner, but set SHUNIT_VERSION so it doesn't run yet
  SHUNIT_VERSION="DoNotRun" . "$1/test_runner"

  if [ -n "$_orig_shunit_version" ]; then
    SHUNIT_VERSION="$_orig_shunit_version"
  else
    unset SHUNIT_VERSION
  fi
}

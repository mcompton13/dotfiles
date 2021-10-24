#!/bin/sh

. "${0%/*}/lib/test_helpers.sh"

# Pull in script to test
import_repo_script lib/helpers.sh

test_HELPERS_TRUE_equals_true() {
  assertTrue "${HELPERS_TRUE:-}"
}

test_HELPERS_FALSE_equals_false() {
  assertFalse "${HELPERS_FALSE:-}"
}

test_HELPERS_ERROR_equals_two() {
  assertEquals 2 "${HELPERS_ERROR-}"
}

test_script_main_should_run_returns_true_when_unit_tests_NOT_running() {
  assertTrue "$(SHUNIT_VERSION="" echo_return_value script_main_should_run)"
  assertTrue "$(
    unset SHUNIT_VERSION
    echo_return_value script_main_should_run
  )"
}

test_script_main_should_run_returns_false_when_unit_tests_running() {
  assertFalse "$(SHUNIT_VERSION="setToValue" echo_return_value script_main_should_run)"
}

test_script_should_import_only_returns_false_when_unit_tests_NOT_running() {
  assertFalse "$(SHUNIT_VERSION="" echo_return_value  script_should_import_only)"
  assertFalse "$(
    unset SHUNIT_VERSION
    echo_return_value script_should_import_only
  )"
}

test_script_should_import_only_returns_true_when_unit_tests_running() {
  assertTrue "$(SHUNIT_VERSION="setToValue" echo_return_value script_should_import_only)"
}

test_script_should_import_only_with_OR_returns_success_exit_if_disabled() {
  assertEquals "${HELPERS_SUCCESS:-}" "$(
    ( SHUNIT_VERSION='set' script_should_import_only || exit "${HELPERS_ERROR:-}" )
    echo $?
  )"
}

test_script_should_import_only_with_OR_returns_exit_code_of_RHS() {
  verify_script_should_import_only_with_OR_returns_exit_code_of_RHS 0
  verify_script_should_import_only_with_OR_returns_exit_code_of_RHS 37
}

verify_script_should_import_only_with_OR_returns_exit_code_of_RHS() {
  exit_code="$1"
  assertEquals "${exit_code}" "$(
    (
      unset SHUNIT_VERSION
      script_should_import_only || exit "${exit_code}"
    )
    echo $?
  )"
}

test_safe_cd_exits_if_fails() {
  result="$(
    BAD_DIR='../foo512/../../bar3123/gah'
    safe_cd "${BAD_DIR}" 2>/dev/null || echo 'SHOULD NOT GET HERE'
    echo 'ALSO SHOULD NOT GET HERE'
  )"
  assertNull "Expect result to be empty, but got '${result}'" "${result}"
}

SHUNIT_PARENT="$0" . shunit2

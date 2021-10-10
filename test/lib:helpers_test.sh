#!/bin/sh

. "${0%/*}/helpers.sh"

# Pull in script to test
import_repo_script lib/helpers.sh

test_HELPERS_TRUE_equals_true() {
  assertTrue "$HELPERS_TRUE"
}

test_HELPERS_FALSE_equals_false() {
  assertFalse "$HELPERS_FALSE"
}

test_HELPERS_ERROR_equals_two() {
  assertEquals 2 "$HELPERS_ERROR"
}

test_script_main_should_run_returns_true_when_unit_tests_NOT_running() {
  assertTrue "$(SHUNIT_VERSION="" echo_return_value  script_main_should_run)"
  assertTrue "$(unset SHUNIT_VERSION; echo_return_value  script_main_should_run)"
}

test_script_main_should_run_returns_false_when_unit_tests_running() {
  assertFalse "$(SHUNIT_VERSION="setToValue" echo_return_value  script_main_should_run)"
}

SHUNIT_PARENT="$0" . shunit2

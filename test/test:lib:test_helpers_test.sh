#!/bin/sh

. "${0%/*}/lib/test_helpers.sh"

test_current_shell_is_bash_returns_false_when_BASH_VERSION_missing() {
  assertFalse "$(BASH_VERSION='' echo_return_value current_shell_is_bash)"
  assertFalse "$(unset BASH_VERSION
    echo_return_value current_shell_is_bash)"
}

test_current_shell_is_bash_returns_true_when_BASH_VERSION_is_set() {
  assertTrue "$(BASH_VERSION='SomeValue' echo_return_value current_shell_is_bash)"
}

test_current_shell_is_ksh_returns_false_when_KSH_VERSION_missing() {
  assertFalse "$(KSH_VERSION='' echo_return_value current_shell_is_ksh)"
  assertFalse "$(unset KSH_VERSION
    echo_return_value current_shell_is_ksh)"
}

test_current_shell_is_ksh_returns_true_when_KSH_VERSION_is_set() {
  assertTrue "$(KSH_VERSION='SomeValue' echo_return_value current_shell_is_ksh)"
}

test_current_shell_is_zsh_returns_false_when_ZSH_VERSION_missing() {
  assertFalse "$(ZSH_VERSION='' echo_return_value current_shell_is_zsh)"
  assertFalse "$(unset ZSH_VERSION
    echo_return_value current_shell_is_zsh)"
}

test_current_shell_is_zsh_returns_true_when_ZSH_VERSION_is_set() {
  assertTrue "$(ZSH_VERSION='SomeValue' echo_return_value current_shell_is_zsh)"
}

test_current_shell_is_sh_returns_false_when_current_shell_is_bash() {
  assertFalse "Bash running in bash mode should not be detected as POSIX sh" "$(
    unset ZSH_VERSION
    unset KSH_VERSION
    BASH_VERSION='SomeValue'
    BASH='bash'
    echo_return_value current_shell_is_sh
  )"
  assertFalse "Bash running in bash mode should not be detected as POSIX sh" "$(
    unset ZSH_VERSION
    unset KSH_VERSION
    BASH_VERSION='SomeValue'
    unset BASH
    echo_return_value current_shell_is_sh
  )"
}

test_current_shell_is_sh_returns_false_when_current_shell_is_ksh() {
  assertFalse "KSH running in ksh mode should not be detected as POSIX sh" "$(
    unset BASH_VERSION
    unset ZSH_VERSION
    # shellcheck disable=SC2034 # Not unused, current_shell_is_sh checks it
    KSH_VERSION='SomeValue'
    echo_return_value current_shell_is_sh
  )"
}

test_current_shell_is_sh_returns_false_when_current_shell_is_zsh() {
  assertFalse "ZSH running in zsh mode should not be detected as POSIX sh" "$(
    unset BASH_VERSION
    unset KSH_VERSION
    ZSH_VERSION='SomeValue'
    # shellcheck disable=SC2034 # Not unused, current_shell_is_sh checks it
    ZSH_NAME='zsh'
    echo_return_value current_shell_is_sh
  )"
  assertFalse "ZSH running in zsh mode should not be detected as POSIX sh" "$(
    unset BASH_VERSION
    unset KSH_VERSION
    # shellcheck disable=SC2034 # Not unused, current_shell_is_sh checks it
    ZSH_VERSION='SomeValue'
    unset ZSH_NAME
    echo_return_value current_shell_is_sh
  )"
}

test_current_shell_is_sh_returns_true_when_current_shell_is_bash_in_sh_mode() {
  assertTrue "Bash running in sh mode should be detected as POSIX sh" "$(
    unset ZSH_VERSION
    unset KSH_VERSION
    BASH_VERSION='SomeValue'
    BASH='/bin/sh'
    echo_return_value current_shell_is_sh
  )"
}

test_current_shell_is_sh_returns_true_when_current_shell_is_zsh_in_sh_mode() {
  assertTrue "ZSH running in sh mode should be detected as POSIX sh" "$(
    unset BASH_VERSION
    unset KSH_VERSION
    # shellcheck disable=SC2034 # Not unused, current_shell_is_sh checks it
    ZSH_VERSION='SomeValue'
    # shellcheck disable=SC2034 # Not unused, current_shell_is_sh checks it
    ZSH_NAME='sh'
    echo_return_value current_shell_is_sh
  )"
}

test_current_shell_is_sh_returns_true_when_current_shell_is_unknown_but_command_is_sh() {
  # Test with the COMMAND ps heading
  assertTrue "Unknown shell with command /bin/sh should be detected as POSIX sh" "$(
    ps() {
      PS_HEADING='COMMAND' mock_ps
    }
    set_unknown_shell
    echo_return_value current_shell_is_sh
  )"

  # Test with the command return by ps being just sh instead of /bin/sh
  assertTrue "Unknown shell with command sh should be detected as POSIX sh" "$(
    ps() {
      PS_COMMAND='sh' mock_ps
    }
    set_unknown_shell
    echo_return_value current_shell_is_sh
  )"
}

test_current_shell_is_sh_returns_false_when_current_shell_is_unknown_and_command_is_not_sh() {
  # Test with the command return by ps being rsh instead of /bin/sh
  assertFalse "Unknown shell with command rsh should NOT be detected as POSIX sh" "$(
    ps() {
      PS_COMMAND='rsh' mock_ps
    }
    set_unknown_shell
    echo_return_value current_shell_is_sh
  )"

  # Test with the command return by ps being /foo/sh instead of /bin/sh
  assertFalse "Unknown shell with command /foo/sh should NOT be detected as POSIX sh" "$(
    ps() {
      PS_COMMAND='/foo/sh' mock_ps
    }
    set_unknown_shell
    echo_return_value current_shell_is_sh
  )"
}

set_unknown_shell() {
  unset ZSH_VERSION
  unset BASH_VERSION
  unset KSH_VERSION
}

mock_ps() {(
  : "${PS_HEADING:=COMM}"
  : "${PS_COMMAND:=/bin/sh}"

  cat << EOF
${PS_HEADING}
${PS_COMMAND}
EOF
)}


test_echo_return_value_prints_false_value_for_failure_functions() {
  assertFalse "$(echo_return_value false)"
}

test_echo_return_value_prints_true_value_for_successful_functions() {
  assertTrue "$(echo_return_value true)"
}

test_echo_return_value_prints_error_code_for_failure_functions() {
  _error_code=47
  _test_function() { return "$1"; }
  assertEquals "$_error_code" "$(echo_return_value _test_function "$_error_code")"
}

test_remove_start_chars_removes_three_chars_from_start_of_string() {
  assertEquals "Bar" "$(remove_start_chars "FooBar" 3)"
}

test_remove_start_chars_removes_two_chars_from_number() {
  assertEquals 34 "$(remove_start_chars 1234 2)"
}

test_remove_start_chars_removes_one_char_when_called_with_one_arg() {
  assertEquals "FooBar" "$(remove_start_chars "qFooBar")"
}

test_remove_start_chars_returns_error_when_called_with_zero_args() {
  _test_remove_start_chars_returns_error_with_args
}

test_remove_start_chars_returns_error_when_called_with_three_args() {
  _test_remove_start_chars_returns_error_with_args "Testing" 3 "bad3rdArg"
}

_test_remove_start_chars_returns_error_with_args() {
  if [ $# -eq 0 ]; then
    _test_command_returns_error_with_args remove_start_chars
    return
  fi
  _test_command_returns_error_with_args remove_start_chars "$@"
}

test_remove_end_chars_removes_three_chars_from_end_of_string() {
  assertEquals "Foo" "$(remove_end_chars "FooBar" 3)"
}

test_remove_end_chars_removes_two_chars_from_number() {
  assertEquals 12 "$(remove_end_chars 1234 2)"
}

test_remove_end_chars_removes_one_char_when_called_with_one_arg() {
  assertEquals "FooBar" "$(remove_end_chars "FooBar9")"
}

test_remove_end_chars_returns_error_when_called_with_zero_args() {
  _test_remove_end_chars_returns_error_with_args
}

test_remove_end_chars_returns_error_when_called_with_three_args() {
  _test_remove_end_chars_returns_error_with_args "Testing" 3 "badArg"
}

_test_remove_end_chars_returns_error_with_args() {
  if [ $# -eq 0 ]; then
    _test_command_returns_error_with_args remove_end_chars
    return
  fi
  _test_command_returns_error_with_args remove_end_chars "$@"
}

test_repeat_chars_repeats_single_char_one_time() {
  repeated=$(repeat_chars "once" 1)
  assertEquals "once" "$repeated"
}

test_repeat_chars_repeats_single_char_five_times() {
  repeated=$(repeat_chars "?" 5)
  assertEquals "?????" "$repeated"
}

test_repeat_chars_repeats_string_three_times() {
  str_to_repeat="SomeLongString "
  repeated=$(repeat_chars "$str_to_repeat" 3)
  assertEquals "$str_to_repeat$str_to_repeat$str_to_repeat" "$repeated"
}

test_repeat_chars_repeats_numbers() {
  repeated=$(repeat_chars 42 3)
  assertEquals 424242 "$repeated"
}

test_repeat_chars_defaults_to_two_times_when_called_with_one_arg() {
  repeated=$(repeat_chars "Twice")
  assertEquals "TwiceTwice" "$repeated"
}

test_repeat_chars_returns_error_with_zero_args() {
  _test_repeat_chars_returns_error_with_args
}

test_repeat_chars_returns_error_with_three_args() {
  _test_repeat_chars_returns_error_with_args 44 45 46
}

test_repeat_chars_returns_error_with_four_args() {
  _test_repeat_chars_returns_error_with_args "foo" 7 "bar" 8
}

test_repeat_chars_returns_error_if_second_arg_is_string() {
  _test_repeat_chars_returns_error_with_args "boo" "zoo"
}

_test_repeat_chars_returns_error_with_args() {
  if [ $# -eq 0 ]; then
    _test_command_returns_error_with_args repeat_chars
  else
    _test_command_returns_error_with_args repeat_chars "$@"
  fi
}

_test_command_returns_error_with_args() {
  _error_code=$(echo_return_value "$@")

  if [ "$_error_code" -eq 0 ]; then
    _command="$1"
    shift # Need to shift so error message contain expected args
    fail "Called $_command with $# args ($*), expected failure error code"
  else
    assertFalse "Expect non-zero error code" "$_error_code"
  fi
}

SHUNIT_PARENT="$0" . shunit2

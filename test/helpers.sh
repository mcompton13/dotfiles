#!/bin/sh

# Treat unset variables as an error when performing parameter expansion.
set -u

# Set shwordsplit for zsh.
[ -n "${ZSH_VERSION:-}" ] && setopt shwordsplit

_get_repo_root() {
  git rev-parse --show-toplevel
}

_REPO_ROOT_DIR_=$(_get_repo_root)
_TEST_DIR_="$_REPO_ROOT_DIR_/test"
_LIB_DIR_="$_REPO_ROOT_DIR_/lib"
_OUT_DIR_="$_REPO_ROOT_DIR_/out"

if [ ! -x "$(command -v shunit2)" ]; then
  PATH="$PATH:$_OUT_DIR_/bin"
fi

. "$_LIB_DIR_/helpers.sh"

import_repo_script() {
  # This is used to source lots of different scripts, shellcheck won't be able to figure it out
  # shellcheck disable=SC1090
  . "$_REPO_ROOT_DIR_/$*"
}

echo_return_value() {(
  "$@" >/dev/null 2>&1
  echo "$?"
)}

assertStartsWith() {(
  _description=$1
  shift
  _expect=$1
  _expect_len=${#_expect}
  shift
  _num_to_remove_from_end=$(( ${#1} - _expect_len ))
  _result=$(remove_end_chars "$1" $_num_to_remove_from_end)
  shift
  assertEquals "$_description" "$_expect" "$_result" "$@"
)}

remove_start_chars() {(
  _str=$1
  _num_to_remove=${2:-1}
  _match_str=$(_create_remove_chars_match_str "$@") || return $?

  if [ -n "${ZSH_VERSION:-}" ]; then
    # A special case for zsh that's non-POSIX, the "standard" way in else below does not work
    # shellcheck disable=SC2039
    echo "${_str:$_num_to_remove}"
  else
    echo "${1#$_match_str}"
  fi
)}

remove_end_chars() {(
  _str=$1
  [ $# -gt 0 ] && shift
  _num_to_remove=${1:-1}
  [ $# -gt 0 ] && shift

  _num_to_remove_start=$((${#_str} - _num_to_remove))
  _end_chars_to_remove="$(remove_start_chars "$_str" $_num_to_remove_start "$@")" || return $?

  echo "${_str%$_end_chars_to_remove}"
)}

_create_remove_chars_match_str() {
  if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "remove_*_chars() requires one or two arguments; $# given"
    return "$HELPERS_ERROR"
  fi

  _num_chars="${2:-1}"
  if (is_int "$_num_chars"); then
    repeat_chars "?" "$_num_chars"
  else
    echo "repeat_chars() requires arg2 to be an int; $_times_to_repeat given"
    return "$HELPERS_ERROR"
  fi
}

repeat_chars() {(
  if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "repeat_chars() requires one or two arguments; $# given"
    return "$HELPERS_ERROR"
  fi

  _str_to_repeat="$1"
  _times_to_repeat="${2:-2}"

  if (is_int "$_times_to_repeat"); then
    result=""
    i=0

    while [ "$i" -lt "$_times_to_repeat" ]; do
      result="$result$_str_to_repeat"
      i=$((i+1))
    done

    echo "$result"
  else
    echo "repeat_chars() requires arg2 to be an int; $_times_to_repeat given"
    return "$HELPERS_ERROR"
  fi
)}

is_int() {(
  # See https://stackoverflow.com/a/3951175
  case $1 in
    ''|*[!0-9]*) false ;;
    *) true ;;
  esac
)}

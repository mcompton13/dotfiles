#!/bin/sh

. "${0%/*}/lib/test_helpers.sh"

import_repo_script test/lib/run_shellcheck_helpers.sh

test_get_valid_files_to_shellcheck_returns_empty_string_when_passed_no_args() {
  assertEquals '' "$(get_valid_files_to_shellcheck)"
}

test_get_valid_files_to_shellcheck_includes_sh_files() {
  included_files="foo/bar.sh /bin/script.sh out/lib/random-script.sh"

  assertEquals "$included_files" "$(get_valid_files_to_shellcheck "$included_files")"
}

test_get_valid_files_to_shellcheck_includes_bash_files() {
  included_files="a.bash x/y.z/r-s.bash no-include.bad-ext ./../../testing.bash"
  expected_files="a.bash x/y.z/r-s.bash ./../../testing.bash"

  assertEquals "$expected_files" "$(get_valid_files_to_shellcheck "$included_files")"
}

test_get_valid_files_to_shellcheck_includes_zsh_files() {
  included_files=$(cat <<EOF
/abc.zsh
../nope/no.qsh
../yup/yes.zsh
abcde.zsh
EOF
  )
  expected_files="/abc.zsh ../yup/yes.zsh abcde.zsh"

  assertEquals "$expected_files" "$(get_valid_files_to_shellcheck "$included_files")"
}

test_get_valid_files_to_shellcheck_includes_profile_files() {
  included_files="config/compiz-ubuntu.profile dotfiles/bash/bash_profile dotfiles/profile-common tag-linux/profile"
  expected_files="dotfiles/bash/bash_profile tag-linux/profile"

  assertEquals "$expected_files" "$(get_valid_files_to_shellcheck "$included_files")"
}

test_get_valid_files_to_shellcheck_includes_rc_files() {
  included_files="rcrc dotfiles/bash/bashrc dotfiles/bash/bashrc.d/do-not-include bash/bashrc.d/include.bash ../zshrc"
  expected_files="rcrc dotfiles/bash/bashrc bash/bashrc.d/include.bash ../zshrc"

  assertEquals "$expected_files" "$(get_valid_files_to_shellcheck "$included_files")"
}

test_get_modified_files_from_git_includes_expected_files() {
  assertNotNull "SHUNIT_TMPDIR should be non-empty" "${SHUNIT_TMPDIR:-}"
  test_git_dir="${SHUNIT_TMPDIR:-}/run_shellcheck_helpers_test.git"

  git() {
    git_instrumented "$@"
  }

  mkdir -p "$test_git_dir" && safe_cd "$test_git_dir"
  assertEquals "$test_git_dir" "${PWD:-}"

  git init >/dev/null
  git config user.email "git@test.com"
  git config user.name "Git Test"

  touch first_file
  git add . >/dev/null
  git commit -m 'Initial commit' >/dev/null

  output=$(get_modified_files_from_git)
  assertNull "Expect get_modified_files_from_git to be empty.\n\n$(dump_git_log)" \
      "$output"

  mkdir original-files
  echo "copied" >original-files/copied
  echo "deleted" >original-files/deleted
  echo "moved" >original-files/moved

  mkdir expected-files
  echo "modified" >expected-files/modified

  output=$(get_modified_files_from_git)
  assertNull "Expect get_modified_files_from_git to be empty.\n\n$(dump_git_log)" \
      "$output"

  git add expected-files original-files >/dev/null

  output=$(get_modified_files_from_git)

  failure_message="Expected file '%s' in get_modified_files output:\n%s\n\n$(dump_git_log)\n"
  assertContainsInOutput "$failure_message" "$output" 'original-files/copied'
  assertContainsInOutput "$failure_message" "$output" 'original-files/deleted'
  assertContainsInOutput "$failure_message" "$output" 'original-files/moved'
  assertContainsInOutput "$failure_message" "$output" 'expected-files/modified'

  git commit -m "Original files" >/dev/null

  output=$(get_modified_files_from_git)
  assertNull "Expect get_modified_files_from_git to be empty.\n\n$(dump_git_log)\n" \
      "$output"

  echo "modified again" >expected-files/modified
  echo "added" >expected-files/added
  cp original-files/copied expected-files/copied
  git rm original-files/deleted >/dev/null
  git mv original-files/moved expected-files/moved >/dev/null

  output=$(get_modified_files_from_git)
  failure_message="Expected file '%s' in get_modified_files output:\n%s\n\n$(dump_git_log)\n"
  assertContainsInOutput "$failure_message" "$output" 'expected-files/modified'
  assertContainsInOutput "$failure_message" "$output" 'expected-files/moved'

  failure_message="Unexpected folder '%s' in get_modified_files output:\n%s\n\n$(dump_git_log)\n"
  assertNotContainsInOutput "$failure_message" "$output" 'original-files/'

  git add . >/dev/null

  output=$(get_modified_files_from_git)
  failure_message="Expected file '%s' in get_modified_files output:\n%s\n\n$(dump_git_log)\n"
  assertContainsInOutput "$failure_message" "$output" 'expected-files/added'
  assertContainsInOutput "$failure_message" "$output" 'expected-files/modified'
  assertContainsInOutput "$failure_message" "$output" 'expected-files/moved'
  assertContainsInOutput "$failure_message" "$output" 'expected-files/copied'

  failure_message="Unexpected folder '%s' in get_modified_files output:\n%s\n\n$(dump_git_log)\n"
  assertNotContainsInOutput "$failure_message" "$output" 'original-files/'
}

## Helpers

assertContainsInOutput() {
  # message_format="$1" output="$2" match="$3"
  assertContains "$(gen_assert_contains_failure_message "$1" "$2" "$3")" "$2" "$3"
}

assertNotContainsInOutput() {
  # message_format="$1" output="$2" match="$3"
  assertNotContains "$(gen_assert_contains_failure_message "$1" "$2" "$3")" "$2" "$3"
}

gen_assert_contains_failure_message() {(
  message_format="$1" output="$2" match="$3"
  # shellcheck disable=SC2059  # Passing in an externally defined prtinf format
  printf "$message_format" "$match" "$output"
)}

GIT_OUTPUT_ID=0
git_instrumented() {
  if [ "$1" = "init" ]; then
    GIT_OUTPUT_ID=$((GIT_OUTPUT_ID + 1))
  fi

  exec_and_log_git "$@"
}

exec_and_log_git() {(
  current_git_output_log="$(get_git_output_log)"

  output="$(command git "${@}" 2>&1)"
  return_status="$?"

  cat <<EOF >>"${current_git_output_log}"
________________________________________________________________________________
Cmd | git $@
Ret | $return_status
Out | $(format_messages '    | ' "$output")
EOF

  echo "$output"
  return "$return_status"
)}


format_messages() {(
  indent="$1"; message="$2"

  if [ -n "$message" ]; then
    indented_message=$(echo "$message" | sed "s/^/${indent}/")
    echo "${indented_message#${indent}}"
  else
    echo "<none>"
  fi
)}

dump_git_log() {
  echo "#### START GIT LOG DUMP ####"
  echo "Log | $(get_git_output_log)"
  echo

  git status --untracked-files --ignored --renames >/dev/null
  cat "$(get_git_output_log)"
  echo "#### END GIT LOG DUMP ####"
}

get_git_output_log() {(
  git_out_log_dir="${SHUNIT_TMPDIR:-}/git_debug"
  git_out_log="${git_out_log_dir:-}/git${GIT_OUTPUT_ID}.log"
  [ ! -d "$git_out_log_dir" ] && mkdir -p "$git_out_log_dir"
  [ ! -f "$git_out_log" ] && touch "$git_out_log"

  echo "$git_out_log"
)}

SHUNIT_PARENT="$0" . shunit2

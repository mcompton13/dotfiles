# shellcheck shell=sh

get_modified_files_from_git() {
  # Returning file names Added (A), Copied (C), Modified (M), Renamed (R), are Unmerged (U), or
  # have had their pairing Broken (B)
  git diff --name-only --diff-filter=ACMRUB HEAD
}

get_valid_files_to_shellcheck() {(
  inner_get_valid_files() {
    files=''
    while [ $# -gt 0 ]; do
      filename=$(echo "$1" | grep -E "(\.[b]?[az]?sh$|/bin/|bashrc$|rcrc|zshrc|[^.]profile$)") \
          && files="$files$filename "
      shift
    done
    echo "${files%% }"
  }

  # Intentionally want splitting so we can iterate in function above
  # shellcheck disable=SC2086,SC2048
  inner_get_valid_files $*
)}

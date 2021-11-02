# shellcheck shell=sh

import_task_runner() {
  # shellcheck disable=SC2034  # This is used internally by the task runner
  __source="$(cat "${1}")"

  task_runner_script="${REPO_ROOT:-}/out/bin/task_runner.sh"
  if [ ! -f "${task_runner_script}" ]; then
    download_script "${task_runner_script}"
  fi

  . "${task_runner_script}"

  # The script sets an exit trap, disable it
  trap - EXIT

  _box() (
    text=""
    while [ -n "$1" ]; do
      case "$1" in
        --p=* | --padding=* | --m=* | --margin=* | --nl | --new-line) : ;;
        -p | --padding | -m | --margin) shift ;;
        --*) : ;;
        *) text="$text$1" ;;
      esac
      shift
    done

    printf "%s\\n\\n" "$(_ansi --red "${text}")"
  )

  #TODO: Set/override app name?
}

download_script() (
  url='https://raw.githubusercontent.com/webuni/shell-task-runner/master/runner'
  download "${url}" >"$1"
)

download() (
  if [ -n "$(command -v 'wget')" ]; then
    wget -qO- "$1"
  else
    curl -s "$1"
  fi
)

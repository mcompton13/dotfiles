#!/bin/sh

task_hello() { ## Print Hello, World!
  printf "%s\\n" "$(_ansi --green --bold "Hello, World! $(_ansi --bg-blue "$1")")"
}

task_goodbye() { ## Print Goodbye, World!
  printf "%s\\n" "$(_ansi --green --bold "Good Bye, Cruel World! $(_ansi --bg-blue "$1")")"
}

#echo  "*** Sourcing $("${0%/*}/bar/bar_script")" >&2


#echo "HERE 0=$0  =>  ${TASK_DIR:=${0%/*}}" >&2

# shellcheck disable=SC2091  # Intentionally executing output of run_single_task
DEFAULT_TASK=task_hello $( "${TASK_DIR:=${0%/*}}/run_single_task" )

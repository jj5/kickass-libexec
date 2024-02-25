#!/bin/bash

lx_assert_var() {

  local var_name="$1";
  local var_value="$2";

  [ -n "${!var_name:-}" ] || lx_fail "missing variable '$var_name'.";

  [ "$var_value" == "${!var_name}" ] || lx_fail "variable '$var_name' has unexpected value '${!var_name}'.";

  #lx_report "variable '$var_name' is set to '${!var_name}'.";

}

lx_run_tests() {

  lx_run_scripts test "$@";

}

lx_run_scripts() {

  # 2021-02-24 jj5 - supported $things are 'test' and 'example'... they are similar but different.
  #
  local thing="$1";

  shift;

  # 2021-02-24 jj5 - the $pattern is for files which we will process for this type of $thing.
  #
  local pattern="*_$thing.*";

  # 2021-02-24 jj5 - NOTE: we are verbose by default, use --quiet to silence...
  #
  local verbose=1;

  # 2021-02-24 jj5 - parse any command-line options here...
  #
  while [[ "$#" > 0 ]]; do
    case "$1" in
    --verbose) verbose=1; shift;;
    --quiet) verbose=0; shift;;
    --) break;;
    *) break;;
    esac;
  done;

  local error=1;

  if [[ "$#" > 0 ]]; then

    # 2021-03-29 jj5 - we have a list of processes to run from the command-line, so rather than
    # running all test processes only run the ones specified...
    #
    for script in "${@}"; do

      lx_run_script "$thing" "$script";

    done;

  else

    # 2021-02-24 jj5 - find all matching scripts for this type of $thing...
    #
    for script in $( find -name "$pattern" | sort ); do

      lx_run_script "$thing" "$script";

    done;

  fi;

}

lx_run_script() {

  local thing="$1";
  local script="$2";

  [ ! -x "$script" ] && {
    
    lx_warn "script '$script' is not executable.";

    return 0;

  }

  # 2021-02-24 jj5 - run the script once to get a list of supported processes, then iterate
  # through those processes...
  #
  for process in $( "$script" ); do

    lx_run_process "$thing" "$script" "$process";

  done;

}

lx_run_process() {

  local thing="$1";
  local script="$2";
  local process="$3";

  local error=1;

  local extension="${script##*.}";

  local test="${process%%:*}"   # extracts the part before the first colon
  local expect="${process#*:}"  # extracts the part after the first colon, if there is one

  # 2024-02-25 jj5 - if there is no colon (as indicated by $test == $expect) then we assume that the process is expected
  # to succeed with error level '0'...
  #
  [ "$test" == "$expect" ] && expect='0';

  # 2024-02-25 jj5 - in the following code we run the script in an if-clause so that we don't automatically exit on error.

  # 2021-02-24 jj5 - if we're in verbose mode tell the user what we're about to do... then
  # run the script with appropriate output redirection.
  #
  if [ "$verbose" == '1' ]; then

    lx_report
    lx_report "$thing $script: ${LX_ORANGE}$process${LX_END}: processing...";

    if time "$script" "$test"; then

      error='0';

    else

      error="$?";
    
    fi;

  else

    if time "$script" "$test" >/dev/null 2>&1; then

      error='0';

    else

      error="$?";

    fi;

  fi;

  if [ "$error" == "$expect" ]; then

    # 2021-02-24 jj5 - the process was successful, we can continue to the next one...

    if [ "$verbose" == '1' ]; then

      lx_report "$thing $script: $process: ${LX_GREEN}success${LX_END}!";

    fi;

    true;

  else

    # 2021-02-24 jj5 - the process failed. That's okay for examples, but for tests we need
    # to indicate failure by returning the error level.

    lx_report "$thing $script: $process: ${LX_RED}failed${LX_END} with error level '$error'; expected '$expect'.";

    if [ "$thing" == 'test' ]; then

      return "$error";

    else

      true;

    fi;

  fi;

}

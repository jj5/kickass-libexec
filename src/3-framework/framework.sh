#!/bin/bash

# 2024-02-18 jj5 - this is a framework for running bash scripts.

# 2017-05-17 jj5 - the bootstrapper configures the environment, calls main,
# and manages the log file. The bootstrapper exits, it does not return.
lx_bootstrap() {

  # 2017-05-17 jj5 - DONE: configure the environment...
  lx_set_env "$@"; shift;

  # 2017-07-19 jj5 - cycle through command-line args and look for --help.
  # If found call a show_help() function (if defined) or else show generic
  # help, then exit $ERR_HELP...

  for arg in "$@"; do

    if [ "$arg" != '--help' ]; then continue; fi;

    if [ "$( type -t show_help )" == 'function' ]; then

      show_help "$@";

      local error="$?";

      if [ "$error" == '0' ]; then exit $ERR_HELP; fi;

    fi

    lx_show_default_help "$@";

    exit "$LX_EXIT_HELP";

  done;

  local arg_list=();

  # 2024-07-06 jj5 - look for arguments we support and process them, otherwise build $arg_list...
  #
  while [[ "$#" > 0 ]]; do
    case "$1" in
      # 2018-03-05 jj5 - we use '--' to signal end of global flags...
      --)
        shift;
        break;;
      --debug)
        LX_STD_DEBUG=1;
        LX_STD_DEBUG_OVERRIDE=1;
        shift;;
      --no-debug)
        LX_STD_DEBUG=0;
        LX_STD_DEBUG_OVERRIDE=1;
        shift;;
      --mail)
        LX_STD_MAIL=1;
        LX_STD_MAIL_OVERRIDE=1;
        shift;;
      --no-mail)
        LX_STD_MAIL=0;
        LX_STD_MAIL_OVERRIDE=1;
        shift;;
      --status)
        LX_STD_STATUS=1;
        LX_STD_STATUS_OVERRIDE=1;
        shift;;
      --no-status)
        LX_STD_STATUS=0;
        LX_STD_STATUS_OVERRIDE=1;
        shift;;
      --interactive)
        LX_STD_INTERACTIVE=1;
        LX_STD_INTERACTIVE_OVERRIDE=1;
        shift;;
      --noninteractive)
        LX_STD_INTERACTIVE=0;
        LX_STD_INTERACTIVE_OVERRIDE=1;
        shift;;
      --quick)
        LX_STD_QUICK=1;
        LX_STD_QUICK_OVERRIDE=1;
         shift;;
      --delay)
        LX_STD_QUICK=0;
        LX_STD_QUICK_OVERRIDE=1;
        shift;;
      *)
        arg_list+=( "$1" );
        shift;;
    esac;
  done;

  # 2024-07-06 jj5 - pull in any remaining arguments...
  #
  while [[ "$#" > 0 ]]; do

    arg_list+=( "$1" );

    shift;

  done;

  # 2017-05-17 jj5 - DONE: call main (in subshell) and log output...
  lx_main "${arg_list[@]}" 2>&1 | tee "$LX_SCRIPT_LOG";

  # 2017-05-19 jj5 - DONE: read $PIPESTATUS for error level of call to main()
  # which gets invoked in a subshell due to the piping to tee.
  local error="${PIPESTATUS[0]}";

  # 2017-05-17 jj5 - DONE: clear log file if main returns. Note: if exit
  # is called prior then the log file will be left behind, which is OK.
  rm -f "$LX_SCRIPT_LOG";

  # 2017-05-17 jj5 - DONE: exit with the error level returned from main()...
  exit "$error";

}

# 2017-05-17 jj5 - configure default environment stuff (init all globals)...
lx_set_env() {

  # 2017-07-20 jj5 - the first thing we do is fix-up our environment if
  # necessary...
  [ -z "${USER:-}" ] && {

    # 2017-07-20 jj5 - if there's no $USER set then assume we are root...
    # 2017-07-20 jj5 - TODO: check if $UID is useful in this case..?
    USER="root";

  };

  # 2017-07-20 jj5 - make sure $HOME is sensible if we're root...
  [ "$USER" == 'root' ] && {

    HOME="/root";

  };

  LX_STD_INFAIL=0;
  LX_STD_INNEED=0;

  # 2017-05-17 jj5 - DONE: initialize script vars...
  LX_SCRIPT="$( basename "$1" )";
  # 2017-06-23 jj5 - DONE: now we record the full path to the script...
  LX_SCRIPT_CMD="$1";
  LX_SCRIPT_SUBSHELL='0';
  LX_SCRIPT_CWD="$PWD";
  LX_SCRIPT_DIR='<INIT>';
  LX_SCRIPT_PATH='<INIT>';
  LX_SCRIPT_ARGS=();
  LX_SCRIPT_INITIATED_DATETIME="$( date )";
  LX_SCRIPT_INITIATED_TIMESTAMP="$( date +%s )";

  # 2017-05-19 jj5 - we use the namespace '_std' for globals in this library.
  # Except for the _script* vars, which are managed separately.
  LX_STD_DEBUG=0; LX_STD_DEBUG_OVERRIDE=0;
  LX_STD_MAIL=1; LX_STD_MAIL_OVERRIDE=0;
  LX_STD_STATUS=1; LX_STD_STATUS_OVERRIDE=0;
  LX_STD_INTERACTIVE=1; LX_STD_INTERACTIVE_OVERRIDE=0;
  LX_STD_QUICK=0; LX_STD_QUICK_OVERRIDE=0;
  LX_STD_DEFAULT='';
  LX_STD_DELAY=10;
  LX_STD_TEMPLIST=();

  # 2017-05-17 jj5 - DONE: prep the log file...
  LX_SCRIPT_LOG="/tmp/$LX_SCRIPT.$$.log";
  lx_silent touch "$LX_SCRIPT_LOG";
  lx_silent chmod 600 "$LX_SCRIPT_LOG";

  # 2017-05-17 jj5 - DONE: find the directory the script is in...
  lx_silent pushd "$( dirname "$1" )";
  LX_SCRIPT_DIR="$PWD";
  lx_silent popd;

  # 2017-05-19 jj5 - DONE: record script path, handy for later on...
  LX_SCRIPT_PATH="$LX_SCRIPT_DIR/$LX_SCRIPT";

  # 2017-05-17 jj5 - DONE: drop the command arg...
  shift;

  # 2017-05-17 jj5 - DONE: remember the original script args...
  LX_SCRIPT_ARGS=( "$@" );

  LX_WORKSPACE=$( mktemp -d "${TMPDIR:-/tmp/}$LX_SCRIPT.$$.XXXXXXXXXXXX" );

  lx_add_tmp "$LX_WORKSPACE";

}

lx_show_default_help() {

  cat << EOF
Help for this script has not been provided.
EOF

}

lx_print_env() {

  local var_list=(

    LX_SCRIPT
    LX_SCRIPT_CMD
    LX_SCRIPT_CWD
    LX_SCRIPT_DIR
    LX_SCRIPT_PATH
    LX_SCRIPT_ARGS
    
    LX_SCRIPT_INITIATED_DATETIME
    LX_SCRIPT_INITIATED_TIMESTAMP

    LX_STD_DEBUG
    LX_STD_DEBUG_OVERRIDE
    LX_STD_MAIL
    LX_STD_MAIL_OVERRIDE
    LX_STD_STATUS
    LX_STD_STATUS_OVERRIDE
    LX_STD_INTERACTIVE
    LX_STD_INTERACTIVE_OVERRIDE
    LX_STD_QUICK
    LX_STD_QUICK_OVERRIDE
    LX_STD_DEFAULT
    LX_STD_DELAY

    LX_SCRIPT_LOG
    LX_WORKSPACE
    LX_STD_TEMPLIST

    LX_STD_INFAIL
    LX_STD_INNEED
    LX_SCRIPT_SUBSHELL

  );

  local var='';
  local i='';

  for var in "${var_list[@]}"; do

    if [ -z "${!var:-}" ]; then

      echo "$var is not set.";

    else

      if declare -p "$var" 2> /dev/null | grep -q '^declare \-a'; then

        # 2024-02-18 jj5 - variable is an array

        echo "$var=";

        declare -n ref="$var";

        for i in "${ref[@]}"; do

          echo "  $i";

        done;

      else

        # 2024-02-18 jj5 - variable is not an array

        echo "$var=${!var}";

      fi

    fi;

  done;

}

lx_drop_lock() {

  local lockfile="$LX_LOCK_FILE";

  [ -e "$lockfile" ] || return 0;

  if sudo -v 2>/dev/null; then

    sudo rm -f "$lockfile";

  else

    rm -f "$lockfile";

  fi;

}

# 2017-05-20 jj5 - this wrapper around the user's main() is invoked
# in a subshell... _cleanup() has to be done in this subshell so that
# we have access to the _std_tempfile array.
lx_main() {

  local lockfile="$LX_LOCK_FILE";

  #[ -e "$lockfile" ] && {
  #  lx_err "lockfile '$lockfile' already exists.";
  #  ls -alh "$lockfile";
  #  echo "USER: $USER";
  #  exit 44;
  #};

  (

    #echo LX_LOCK_FILE: $LX_LOCK_FILE;

    flock -n 9 || {

      lx_err "failed to acquire lockfile '$lockfile'.";

      exit 44;

    };

    set -euo pipefail;

    # 2024-07-17 jj5 - NEW: gonna try EXIT, the others didn't seem to do it...
    trap lx_drop_lock EXIT
    # 2024-07-17 jj5 - OLD:
    #trap lx_drop_lock SIGINT SIGTERM

    lx_daylight;

    main "$@";

    local error="$?";

    exit "$error";

  ) 9>"$lockfile";

  local error="$?";

  if [ "$error" != 44 ]; then

    lx_drop_lock || true;

  fi;

  lx_exit "$error";

}

lx_exit() {

  local error="${1:-0}";

  # 2024-06-14 jj5 - disable status reporting if no error...
  #
  [ "$error" == '0' ] && LX_STD_STATUS=0;

  lx_run_job "cleaning up" lx_cleanup;

  lx_report_finished "$error";

  exit "$error";

}

# 2017-05-19 jj5 - get rid of temporary stuff...
lx_cleanup() {

  # 2017-06-27 jj5 - change to /tmp dir, because $PWD might be
  # temporary and removed below...
  #need pushd /tmp;
  lx_need cd /tmp;

  if [ "$( type -t exit_handler )" = 'function' ]; then

    lx_report 'running exit handler...';

    lx_need exit_handler;

  fi

  lx_need lx_del_tmp;

  #need popd;

}

lx_report_finished() {

  local error="$1";

  lx_newline;

  [ "$LX_SCRIPT_SUBSHELL" == '0' ] || {

    lx_report "subshell exited with error level '$error'.";

    return "$error";

  };

  lx_report "${LX_WHITE}main() exited with error level '$error'.${LX_END}";

  LX_SCRIPT_COMPLETED_DATETIME="$( date )";
  LX_SCRIPT_COMPLETED_TIMESTAMP="$( date +%s )";

  LX_SCRIPT_PROCESSED_IN=$(( LX_SCRIPT_COMPLETED_TIMESTAMP - LX_SCRIPT_INITIATED_TIMESTAMP ));
  LX_SCRIPT_PROCESSED_IN_FORMATTED=$( lx_format_duration $LX_SCRIPT_PROCESSED_IN );
  lx_report "script initiated at: $LX_SCRIPT_INITIATED_DATETIME";
  lx_report "script completed at: $LX_SCRIPT_COMPLETED_DATETIME";
  lx_report "script processed in: $LX_SCRIPT_PROCESSED_IN_FORMATTED";

  if [ "$error" = "0" ]; then

    [ "$LX_STD_STATUS" = "0" ] && return 0;

    lx_log_color "${LX_GREEN}success!${LX_END}";

  else

    if [ "$error" == "$LX_EXIT_HELP" ]; then

      # 2017-07-19 jj5 - just be quiet if the "error" is that help was
      # displayed...

      return 0;

    else

      lx_log_color "${LX_RED}error!${LX_END}";

    fi

  fi

  return "$error";

}

lx_del_tmp() {

  # 2017-06-27 jj5 - change to /tmp dir, because $PWD might be
  # temporary and removed below...
  lx_need pushd /tmp;

  for tmp in "${LX_STD_TEMPLIST[@]}"; do

    lx_report "removing temp item '$tmp'..."

    [ -d "$tmp" ] && lx_wrap rm -rf "$tmp" && lx_report "removed directory.";

    [ -f "$tmp" ] && lx_wrap rm -f "$tmp" && lx_report "removed file.";

  done

  LX_STD_TEMPLIST=();

  lx_need popd;

}

# 2017-05-17 jj5 - call the bootstrapper, pass in script name and args.
# 2017-05-17 jj5 - NOTE: 'exit 82' should not be called, bootstrapper exits.
lx_bootstrap "$0" "$@"; exit 82;

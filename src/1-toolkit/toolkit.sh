#!/bin/bash

# 2024-02-18 jj5 - these are some helper functions for use in bash scripts.

lx_timestamp() { date +%Y-%m-%d-%H%M%S; }

lx_load_modules() {

  local dir="${1:-$LX_DIR_SRC/2-module}";

  local file='';

  for file in $( ls "$dir" ); do

    local path="$dir/$file/$file.sh";

    if [ -f "$path" ]; then

      source "$path" || lx_fail "error loading module file: $path";

    else

      # >&2 echo -e "${LX_RED}missing module file: $path${LX_END}";

      lx_fail "missing module file: $path"

    fi;

  done;

}

# 2024-02-18 jj5 - set an option if it hasn't been overridden on the command-line...
#
lx_default() {

  local option="$1";
  local setting="$2";

  case "$option" in

    debug)
      [ "$LX_STD_DEBUG_OVERRIDE"        == '0' ] && lx_opt "$option" "$setting";;

    mail)
      [ "$LX_STD_MAIL_OVERRIDE"         == '0' ] && lx_opt "$option" "$setting";;

    status)
      [ "$LX_STD_STATUS_OVERRIDE"       == '0' ] && lx_opt "$option" "$setting";;

    interactive)
      [ "$LX_STD_INTERACTIVE_OVERRIDE"  == '0' ] && lx_opt "$option" "$setting";;

    quick)
      [ "$LX_STD_QUICK_OVERRIDE"        == '0' ] && lx_opt "$option" "$setting";;

    *)

      lx_fail "unsupported option '$option'.";;

  esac

}

# 2024-02-18 jj5 - set an option, overriding options from lx_default() and the command-line.
#
lx_opt() {

  local option="$1";
  local setting="$2";

  case "$option" in

    debug)

      local setting=$( lx_read_bool "$setting" );

      if [ "$setting" == '0' ]; then

        LX_STD_DEBUG=0;

      else

        LX_STD_DEBUG=1;

      fi;

      ;;

    mail)

      local setting=$( lx_read_bool "$setting" );

      if [ "$setting" = '0' ]; then

        LX_STD_MAIL=0;

      else

        LX_STD_MAIL=1;

      fi;

      ;;

    status)

      local setting=$( lx_read_bool "$setting" );

      if [ "$setting" = '0' ]; then

        LX_STD_STATUS=0;

      else

        LX_STD_STATUS=1;

      fi;

      ;;

    interactive)

      LX_STD_INTERACTIVE=$( lx_read_bool "$setting" );

      ;;

    quick)

      LX_STD_QUICK=$( lx_read_bool "$setting" );

      ;;

    default)

      LX_STD_DEFAULT="$setting";

      ;;

    delay)

      lx_require positive "$setting";

      LX_STD_DELAY="$setting";

      ;;

    *)

      lx_fail "unsupported option '$option'.";

      ;;

  esac;

}

lx_read_bool() {

  local value="$1";

  [ "$value" = '' ] && echo '0' && return 0;

  local value=$( echo "$value" | tr '[:upper:]' '[:lower:]' );

  case "$value" in

    0) echo '0';;
    no) echo '0';;
    off) echo '0';;
    false) echo '0';;
    *) echo '1';;

  esac;

}

# 2017-05-19 jj5 - enable debugging (prints extra info)...
lx_set_debug() {

  LX_STD_DEBUG=1;

}

# 2017-05-17 jj5 - disable email notifications...
lx_set_nomail() {

  LX_STD_MAIL=0;

}

# 2017-05-19 jj5 - disable status and output on stdout...
lx_set_nostatus() {

  LX_STD_STATUS=0;

}

lx_is_interactive() {

  [ "$LX_STD_INTERACTIVE" == '0' ] || return 0;

  return 1;

}

lx_is_noninteractive() {

  lx_is_interactive && return 1;

  return 0;

}

lx_is_quick() {

  [ "$LX_STD_QUICK" == '0' ] || return 0;

  return 1;

}

# 2017-05-19 jj5 - cd to directory script is in...
lx_script_dir() {

  local dir="${LX_SCRIPT_DIR:-}";

  test -d "$dir" || lx_fail "script directory '$dir' does not exist.";

  lx_quiet pushd "$LX_SCRIPT_DIR";

}

# 2024-02-18 jj5 - checks that a valid argument is provided.
#
lx_ensure() {

  case "$#" in

    0)

      lx_fail "no arguments provided for lx_ensure().";;

    1)

      local arg_value="$1";
      local function="${FUNCNAME[1]}";

      if [ -z "${arg_value:-}" ]; then

        lx_fail "missing value for argument to $function().";

      fi;

      ;;

    2)

      local arg_name="$1";
      local arg_value="$2";
      local function="${FUNCNAME[1]}";

      if [ -z "${arg_name:-}" ]; then

        lx_fail "missing value for 1st argument 'arg_name' in lx_ensure().";

      fi;

      if [ -z "${arg_value:-}" ]; then

        lx_fail "missing value for argument '$arg_name' in $function().";

      fi;

      ;;

    3)

      local arg_num="$1";
      local arg_name="$2";
      local arg_value="$3";
      local function="${FUNCNAME[1]}";

      if [ -z "${arg_num:-}" ]; then

        lx_fail "missing value for 1st argument 'arg_num' in ensure().";

      fi;

      if [ -z "${arg_name:-}" ]; then

        lx_fail "missing value for 2nd argument 'arg_name' in ensure().";

      fi;

      local arg_place=$( lx_get_place "$arg_num" );

      if [ -z "${arg_value:-}" ]; then

        lx_fail "missing value for $arg_place arg '$arg_name' in $function().";

      fi;

      ;;

    *)

      local arg_num="$1";
      local arg_name="$2";
      local arg_value="$3";
      local function="${FUNCNAME[1]}";

      if [ -z "${arg_num:-}" ]; then

        lx_fail "missing value for 1st argument 'arg_num' in ensure().";

      fi;

      if [ -z "${arg_name:-}" ]; then

        lx_fail "missing value for 2nd argument 'arg_name' in ensure().";

      fi;

      shift; shift; shift;

      while [ "$#" != '0' ]; do

        [ "$1" == "${arg_value:-}" ] && return 0;

        shift;

      done

      local arg_place=$( lx_get_place "$arg_num" );

      lx_fail "invalid value '$arg_value' for $arg_place argument '$arg_name' in $function().";

      ;;

  esac

}

lx_get_setting() {

  local prompt="$1";
  local default="$2";
  local result='';

  if [ -z "${default:-}" ]; then

    default="$LX_STD_DEFAULT";

  fi;

  lx_is_noninteractive && echo "$default" && return 1;

  while [ -z "${result:-}" ]; do

    if [ -z "${default:-}" ]; then

      $( >&2 echo -n "$prompt: " );

    else

      $( >&2 echo -n "$prompt [$default]: " );

    fi;

    read result;

    if [ -z "${result:-}" ]; then

      result="$default";

    fi;

  done;

  echo "$result";

  return 0;

}

lx_get_password() {

  local password='';

  if [ "$1" = "" ]; then

    $( >&2 echo -n "Enter password: " );

  else

    $( >&2 echo -n "Enter password for '$1': " );

  fi;

  stty -echo;

  read password;

  stty echo;

  $( >&2 echo; );

  echo "$password";

}

lx_get_place() {

  [ "$1" == 'global' ] && echo 'global' && return 0;

  # 2017-07-08 jj5 - TODO: support for > 20...

  case "$1" in

    1) echo '1st';;
    2) echo '2nd';;
    3) echo '3rd';;
    *) echo "${1}th";;

  esac

}

lx_get_callstack() {

  #local count=$(( ${#BASH_LINENO[@]} - 5 ));
  local count=$(( ${#BASH_LINENO[@]} ));

  for n in $( seq 2 "$count" ); do

    local i=$(( $count - $n + 1 ));
    local h=$(( $i - 1 ));

    local func="${FUNCNAME[$i]}";
    local line="${BASH_LINENO[$h]}";

    if [ "$func" != 'main' ]; then echo -n ':'; fi

    echo -n "$func[$line]";

  done

}

lx_require() {

  local type="$1";

  lx_ensure 1 'type' "$type";

  shift;

  [ "$#" == '0' ] && lx_fail "missing argument(s) for lx_require().";

  case "$type" in

    user)

      lx_in_list "$USER" "$@" || lx_fail "must run as user: $*.";;

    host)

      lx_in_list "$HOSTNAME" "$@" || lx_fail "must run on host: $*.";;

    item)

      local item="$1"; shift;

      lx_in_list "$item" "$@" || lx_fail "item '$item' must be one of: $*.";;

    exists)

      lx_test_list -e "file" "$@";;

    file)

      lx_test_list -f "regular file" "$@";;

    nofile)

      lx_test_list_not -f "regular file" "$@";;

    dir)

      lx_test_list -d "directory" "$@";;

    nodir)

      lx_test_list_not -d "directory" "$@";;

    subdirs)

      while [ $# -gt 0 ]; do

        lx_require dir "$1";

        lx_has_subdirs "$1" || lx_fail "directory '$1' has no sub-directories.";

        shift;

      done;;

    symlink)

      lx_test_list -L "symbolic link" "$@";;

    positive)

      while [ $# -gt 0 ]; do

        [ "$1" -gt 0 ] || lx_fail "value '$1' is not positive.";

        shift;

      done;;

    nonpositive)

      while [ $# -gt 0 ]; do

        [ "$1" -gt 0 ] && lx_fail "value '$1' is positive.";

        shift;

      done;;

    negative)

      while [ $# -gt 0 ]; do

        [ "$1" -lt 0 ] || lx_fail "value '$1' is not negative.";

        shift;

      done;;

    nonnegative)

      while [ $# -gt 0 ]; do

        [ "$1" -lt 0 ] && lx_fail "value '$1' is negative.";

        shift;

      done;;

    pattern)

      # 2017-08-29 jj5 - TODO: match regular expression for arg list.
      lx_fail "unimplemented";;

    *)

      lx_fail "unsupported type '$type' for require().";;

  esac

  true;

}

lx_require_var() {

  # 2017-08-29 jj5 - TODO: a new version of require() which is similar but
  # takes a variable name as the first agument.

  # 2017-08-29 jj5 - THINK: or maybe extend require() with e.g.:
  # require var $var_name $requirement $value...

  lx_fail "unimplemented";

}

# 2017-07-20 jj5 - lx_in_list() requires the value of the first argument to appear
# in the list of other arguments.
lx_in_list() {

  local value="$1";

  lx_ensure 1 'value' "$value";

  shift;

  while [ "$#" != '0' ]; do

    [ "$value" == "$1" ] && return 0;

    shift;

  done

  return 1;

}

# 2017-07-20 jj5 - test_list() requires all other arguments to pass the test
# specified by the first argument.
lx_test_list() {

  local test="$1";
  local type="$2";

  lx_ensure 1 'test' "$test";
  lx_ensure 2 'type' "$type";

  shift; shift;

  while [ "$#" != '0' ]; do

    test $test "$1" || lx_fail "$type '$1' must exist.";

    shift;

  done

  return 0;

}

# 2019-03-12 jj5 - test_list_not() requires all other arguments to fail the
# test specified by the first argument.
lx_test_list_not() {

  local test="$1";
  local type="$2";

  lx_ensure 1 'test' "$test";
  lx_ensure 2 'type' "$type";

  shift; shift;

  while [ "$#" != '0' ]; do

    test ! $test "$1" || lx_fail "$type '$1' must not exist.";

    shift;

  done

  return 0;

}

lx_has_subdirs() {

  test -d "$1" || return 1;

  [ "$( find "$1" -maxdepth 1 -type d | wc -l )" == '2' ] && return 1;

  return 0;

}

# 2017-06-23 jj5 - get the user to confirm an action...
lx_confirm() {

  lx_is_noninteractive && {

    lx_is_quick || lx_delay;

    return 1;

  };

  local confirm='';

  lx_newline;

  while [ "$confirm" != 'yes' ]; do

    read -p "$1: " confirm;

    >&2 echo "$confirm";

    [ "$confirm" = 'no' ] && exit "$LX_EXIT_USER_CANCEL";

  done;

  return 0;

}

# 2024-02-18 jj5 - add a temp file to the list of files to be cleaned up on exit.
#
lx_add_tmp() {

  while (( "$#" )); do

    LX_STD_TEMPLIST+=( "$1" );

    shift;

  done

}

# 2017-05-19 jj5 - a handy utility to replace owner on current directory and
# make sure permissions are sensible...
lx_own() {

  local user="$LX_DEFAULT_USER";
  local group="$LX_DEFAULT_GROUP";

  if [ "$#" != '0' ]; then

    user="$1";

    shift;

  fi

  if [ "$#" != '0' ]; then

    group="$1";

    shift;

  fi

  lx_run_job "taking ownership" \
    find . \( \( \! -user $user \) -or \( \! -group $group \) \) \
      -execdir chown --no-dereference $user:$group "{}" \;

  lx_run_job "fixing directory permissions" \
    find . -type d \
      -and \( \! -perm /u=r -or \! -perm /u=w -or \! -perm /u=x \) \
      -execdir chmod u+rwx "{}" \;

  lx_run_job "fixing file permissions" \
    find . -type f \
      -and \( \! -perm /u=r -or \! -perm /u=w \) \
      -execdir chmod u+rw "{}" \;

}


# 2017-05-19 jj5 - loop a command until a stop file is created...
lx_loop() {

  local stop_file="$1";

  if [ -z "${stop_file:-}" ]; then

    lx_fail "stop file must be specified.";

  fi;

  local stop_path="/tmp/$stop_file";

  # 2017-05-20 jj5 - THINK: perhaps just return in this case..?
  #
  if [ -f "$stop_path" ]; then

    # 2019-12-23 jj5 - decided to delete the stop file if it already exists...
    #
    lx_run rm -f "$stop_path";

    #fail 2 "stop file '$stop_path' exists!";

  fi;

  # 2017-05-19 jj5 - bump off the stop file spec...
  shift;

  while [ true ]
  do

    lx_daylight;

    # 2019-12-23 jj5 - under this new scheme the only thing that should be
    # able to stop the loop is the stop file, the loop will iterate even if
    # the previous iteration failed.

    # 2019-12-23 jj5 - OLD: we used to 'check' the command...
    #check "$@";
    # 2019-12-23 jj5 - NEW: but now we don't...
    if "$@"; then

      true;

    else

      lx_warn "loop failed.";

    fi;
    # 2019-12-23 jj5 - END

    lx_try lx_del_tmp;

    if [ ! -f "$stop_path" ]; then

      lx_note "will sleep for 1 hour...";

      sleep 3600;

      continue;

    fi;

    # 2017-05-19 jj5 - just try to remove the stop file (we might not
    # have permission)...
    lx_try rm -f "$stop_path";

    return 0;

  done

  # 2017-05-19 jj5 - we should never reach here
  return "$LX_EXIT_NOT_POSSIBLE";

}

lx_try_run() {

  if lx_try "$@"; then

    # 2019-09-12 jj5 - success!

    return;

  fi;

  local message="error running: $*";

  lx_warn "$message";

  lx_notify "$message";

}

lx_run_as() {

  local user="$1";

  shift;

  if [ "$user" == "$( whoami )" ]; then

    lx_run "$@";

  else

    lx_run sudo -u "$user" "$@";

  fi;

}

# 2017-05-19 jj5 - a simple wrapper around run_job() that uses the command
# itself as the job description...
lx_run() {

  lx_run_job "running $*" "$@";

}

# 2017-05-19 jj5 - simple job reporting and checking...
lx_run_job() {

  local description="$1"; shift;

  lx_daylight;

  lx_newline;

  lx_report "${LX_WHITE}job: ${description}...${LX_END}";

  if [ "$LX_STD_STATUS" = "1" ]; then

    lx_wrap "$@";

    local error="$?";

  else

    # 2017-05-19 jj5 - nostatus is set so be quiet (no stdout)...
    lx_wrap "$@" >/dev/null

    local error="$?";

  fi

  if [ "$error" = '0' ]; then

    lx_report "${LX_GREEN}job: done ${description}.${LX_END}";

  else

    lx_fail "$error" "job: fail $description.";

  fi

}

lx_try_as() {

  local user="$1";

  shift;

  if [ "$user" == "$( whoami )" ]; then

    lx_try "$@";

  else

    lx_try sudo -u "$user" "$@";

  fi;

}

lx_try() {

  local description="running $*";

  lx_daylight;

  lx_newline;

  lx_report "${LX_WHITE}try: ${description}${LX_END}...";

  if command -v lx_del_tmp >/dev/null; then

    (
      LX_STD_TEMPLIST=();
      LX_SCRIPT_SUBSHELL='1';
      "$@";
      LX_ERR="$?";
      lx_del_tmp;
      exit "$LX_ERR";
    );

  else

    (
      LX_STD_TEMPLIST=();
      LX_SCRIPT_SUBSHELL='1';
      "$@";
      LX_ERR="$?";
      exit "$LX_ERR";
    );

  fi

  local error="$?";

  if [ "$error" = '0' ]; then

    lx_report "${LX_GREEN}try: done ${description}.${LX_END}";

  else

    lx_report "${LX_ORANGE}try: fail ${description}; error '$error'.${LX_END}";

  fi

  return "$error";

}

lx_download() {

  local wget=$( which wget );

  if [ -z "${wget:-}" ]; then

    if [ "$USER" = 'root' ]; then

      lx_run lx_install wget;

    else

      lx_fail "wget is not installed.";

    fi

  fi

  lx_retry 60 5 wget "$@";

  local error="$?";

  [ "$error" = "0" ] || lx_fail "could not download '$@'.";

  return "$error";

}

lx_install() {

  local frontend="$DEBIAN_FRONTEND";

  export DEBIAN_FRONTEND=noninteractive;

  lx_retry 60 5 apt-get update --yes;

  local error="$?";

  if [ "$error" = "0" ]; then

    lx_retry 60 5 apt-get install -o "Dpkg::Options::=--force-confold" -q -y --force-yes "$@";

    local error="$?";

  fi

  if [ -z "${frontend:-}" ]; then

    unset DEBIAN_FRONTEND;

  else

    export DEBIAN_FRONTEND="$frontend";

  fi

  return "$error";

}

lx_by() {

  # 2017-08-31 jj5 - TODO: this function needs to be tested...

  local n="$1"; shift;

  lx_require positive "$n";

  for i in $( seq 1 "$n" ); do

    lx_run "$@";

  done;

}

lx_retry() {

  local retries="$1"; # 2017-07-05 jj5 - number of attempts to make
  local delay="$2";   # 2017-07-05 jj5 - delay in seconds between attempts

  if lx_attempt "$@"; then

    return 0;

  fi;

  local error="$?";

  lx_fail "$error" "could not process command after $retries attempts: $*";

}

lx_attempt() {

  local retries="$1"; # 2017-07-05 jj5 - number of attempts to make
  local delay="$2";   # 2017-07-05 jj5 - delay in seconds between attempts

  shift; shift;

  [ -z "${delay:-}" ] && delay="$LX_STD_DELAY";

  lx_ensure 1 'retries' "$retries";
  lx_ensure 2 'delay' "$delay";

  lx_require positive "$retries";
  lx_require nonnegative "$delay";

  local error="0";

  for n in $( seq 1 "$retries" ); do

    lx_report "attempting command: $@";

    lx_try "$@";

    local error="$?";

    if [ "$error" = "0" ]; then

      lx_report "success.";

      return 0;

    fi

    lx_report "command failed with error level '$error'.";

    [ "$n" == "$retries" ] && break;

    local next=$(( n + 1 ));

    if [ "$delay" = "1" ]; then

      lx_report "retrying $next/$retries in 1 second...";

    else

      lx_report "retrying $next/$retries in $delay seconds...";

    fi

    sleep "$delay";

  done

  lx_warn "could not process command after $retries attempts: $*";

  return "$error";

}

# 2017-05-19 jj5 - just output a new-line (unless disabled)...
lx_newline() {

  [ "$LX_STD_STATUS" = "1" ] || return 0;

  >&2 echo;

  return 0;

}

lx_delay() {

  lx_is_quick && return 1;

  local delay="${1:-}";
  local action="${2:-}";

  [ -z "${delay:-}" ] && delay="$LX_STD_DELAY";
  [ -z "${action:-}" ] && action='process';

  lx_require positive "$delay";

  for i in $( seq 1 "$delay" ); do

    local n=$(( delay - i + 1 ));

    [ "$LX_STD_STATUS" == '1' ] && {

      >&2 echo -ne "\r${LX_CLEAR}${LX_RED}Will $action in $n... (Ctrl+C to cancel)${LX_END}";

    };

    sleep 1;

  done;

  [ "$LX_STD_STATUS" == '1' ] && {

    >&2 echo -e "\n${LX_RED}Will $action now.${LX_END}";

  };

  return 0;

}

lx_notify() {

  lx_warn "$*";

  local mailer="$( command -v mail )";
  local subject="[NOTE] $*";
  local to="${LX_ERROR_EMAIL:-jj5@jj5.net}";

  local timestamp="$( date +%s )";

  if [ -z "$LX_SCRIPT_INITIATED_TIMESTAMP" ]; then

    local runtime="$SECONDS";

  else

    local runtime=$(( $timestamp - $LX_SCRIPT_INITIATED_TIMESTAMP ));

  fi

  local runtime_formatted=$( lx_format_duration $runtime );

  if [ -z "$LX_SCRIPT_CMD" ]; then

    local cmd_val='toolkit';

  else

    local cmd_val="$LX_SCRIPT_CMD$( printf " %q" "${LX_SCRIPT_ARGS[@]}" )";

  fi

  local sub_val="${LX_SCRIPT_SUBSHELL:-0}";
  local dir_val="${LX_SCRIPT_CWD:-$PWD}";
  local usr_val="${USER:-unknown}";
  local sys_val="${HOSTNAME:-unknown}";
  local log_val="${LX_SCRIPT_LOG:-none}";
  local cwd_val="$PWD";
  local lck_val="${LX_LOCK_FILE:-none}";
  local dat_val="${LX_STATE_DIR:-none}";

  local cmd_line=$'\ncmd: '"$cmd_val";
  local sub_line=$'\nsub: '"$sub_val";
  local dir_line=$'\ndir: '"$dir_val";
  local usr_line=$'\nusr: '"$usr_val";
  local sys_line=$'\nsys: '"$sys_val";
  local log_line=$'\nlog: '"$log_val";
  local run_line=$'\nrun: '"$runtime_formatted";
  local cwd_line=$'\ncwd: '"$cwd_val";
  local lck_line=$'\nlck: '"$lck_val";
  local dat_line=$'\ndat: '"$dat_val";

  local report=$'\n'"${cmd_line}${sub_line}${dir_line}${usr_line}${sys_line}";
  local report="Note: $*${report}${log_line}${run_line}${cwd_line}${lck_line}${dat_line}"$'\n\n';

  if [ -x "$mailer" ]; then

    echo "$report" | "$mailer" -s "$subject" "$to";

  else

    lx_fail "invalid mailer '$mailer'.";

  fi;

}

# 2024-07-16 jj5 - the point of this function is to delay for four hours around daylight savings time change. It is
# integrated as part of the framework/toolkit and will be called automatically before main() is called and from time
# to time from some key functions such as lx_run() and lx_try().
#
lx_daylight() {

  # 2024-07-16 jj5 - NOTE: this code hasn't been well tested.

  # 2024-07-16 jj5 - get the current timestamp
  #
  local current_timestamp=$( date +%s );

  # 2024-07-16 jj5 - get the current offset in seconds from UTC
  #
  local current_offset=$( date +%z | awk '{print ($1 / 100) * 3600}' );

  # 2024-07-16 jj5 - calculate the timestamps plus or minus two hours from now
  #
  local two_hours_before=$((  current_timestamp - 2 * 3600 ));
  local two_hours_later=$((   current_timestamp + 2 * 3600 ));

  # 2024-07-16 jj5 - get the offsets in seconds from UTC for plus or minus two hours from now
  #
  local two_hours_before_offset=$(  date -d @${two_hours_before}  +%z | awk '{print ($1 / 100) * 3600}');
  local two_hours_later_offset=$(   date -d @${two_hours_later}   +%z | awk '{print ($1 / 100) * 3600}');

  # 2024-07-16 jj5 - check if the offset changes within two hours either side of the current time
  #
  if [ "$current_offset" -ne "$two_hours_before_offset" ]; then

    lx_newline;

    lx_note "daylight savings just changed, will sleep for 2 hours.";

    sleep 2h;
    sleep 37;

  elif [ "$current_offset" -ne "$two_hours_later_offset" ]; then

    lx_newline;

    lx_note "daylight savings is about to change, will sleep for 4 hours.";

    sleep 4h;
    sleep 37;

  fi

  return 0;

}

lx_note() {

  lx_newline;

  lx_report "${LX_LBLUE}$@${LX_END}";

}

# 2017-05-19 jj5 - tell the user what's going on (unless disabled)...
lx_report() {

  [ "$LX_STD_STATUS" = "1" ] || return 0;

  lx_log_message "$@";

}

lx_debug() {

  [ "$LX_STD_DEBUG" = "1" ] || return 0;

  lx_log_message "${LX_YELLOW}$@${LX_END}";

}

lx_warn() {

  lx_log_message "${LX_ORANGE}$@${LX_END}";

}

lx_err() {

  lx_log_message "${LX_RED}$@${LX_END}";

}

lx_log_message() {

  lx_log_color "$@";

}

lx_log_color() {

  echo -e "$( lx_get_log_label )" "$@" >&2;

}

lx_get_log_label() {

  local time="$( date +'%a %H:%M:%S' )";

  local days=$((SECONDS / 86400))
  local hours=$(((SECONDS % 86400) / 3600))
  local minutes=$(((SECONDS % 3600) / 60))
  local seconds=$((SECONDS % 60))

  local duration="$( printf "%02d:%02d:%02d:%02d" $days $hours $minutes $seconds )";

  local script="${LX_SCRIPT:-toolkit}";

  echo -n -e "${LX_PURPLE}$USER@$HOSTNAME: $script[$$]: $time: $duration:${LX_END}";

}

# 2017-05-17 jj5 - run a command, check its error level, but hide output...
lx_silent() {

  # 2017-05-19 jj5 - remove timer as we're being silent...
  [ "$1" = "time" ] && shift;

  lx_wrap "$@" 1>/dev/null 2>&1;

  local error="$?";

  [ "$error" = 0 ] || lx_fail "$error" "error running: $*";

}

# 2017-05-19 jj5 - run a command, check its error level, but hide stdout...
lx_quiet() {

  # 2017-05-19 jj5 - remove timer as we're being quiet...
  [ "$1" = "time" ] && shift;

  lx_wrap "$@" 1>/dev/null;

  local error="$?";

  [ "$error" = 0 ] || lx_fail "$error" "error running: $*";

}

# 2017-05-17 jj5 - run a command and check its error level...
lx_check() {

  if [ "$LX_STD_STATUS" = "1" ]; then

    lx_wrap "$@";

    local error="$?";

    [ "$error" = 0 ] || lx_fail "$error" "error running: $*";

  else

    # 2017-05-19 jj5 - nostatus is set so use quiet() instead...
    lx_quiet "$@";

  fi

}

# 2017-05-19 jj5 - run a command and return its error level...
lx_wrap() {

  # 2017-05-20 jj5 - if we're debugging tell the user what's going on...
  [ "$LX_STD_DEBUG" = '1' ] && {

    local label=$( lx_get_log_label );
    local timestamp="$( date +%s )";

    if [ -z "$LX_SCRIPT_INITIATED_TIMESTAMP" ]; then

      local runtime="$SECONDS";

    else

      local runtime=$(( $timestamp - $LX_SCRIPT_INITIATED_TIMESTAMP ));

    fi

    local runtime_formatted=$( lx_format_duration $runtime );
    local context=$( lx_get_callstack );
    local message=$'\n'"$label ${LX_YELLOW}cmd: $@${LX_END}\n$label run: $runtime_formatted\n$label cwd: $PWD\n$label lck: $LX_LOCK_FILE\n$label pnt: $PPID\n$label ctx: $context\n";

    >&2 echo -e "$message";

  };

  if [ "$LX_STD_STATUS" = "1" ]; then

    # 2017-05-20 jj5 - the standard wrap() just executes the command...
    "$@";

    return "$?";

  fi

  # 2017-05-19 jj5 - remove the timer because we're being quiet...
  [ "$1" == 'time' ] && shift;

  # 2017-05-20 jj5 - nostatus is enabled so we be quiet... (no stdout)...
  "$@" 1>/dev/null;

  return "$?";

}

# 2017-07-06 jj5 - need() will run a crucial command quietyly and if it fails
# it will abort.
lx_need() {

  LX_STD_INNEED=$(( LX_STD_INNEED + 1 ));

  "$@" >/dev/null

  [ "$?" = '0' ] || exit "$LX_EXIT_ABORT";

  LX_STD_INNEED=$(( LX_STD_INNEED - 1 ));

}

# 2017-05-19 jj5 - sendlog() factored into standalone function so we can send
# log if requested even if no error has occurred...
lx_sendlog() {

  # 2019-06-25 jj5 - I'm not quite sure zero is the right return value here...
  # I guess that's probably okay...
  #
  if [ "$LX_STD_MAIL" == '0' ]; then

    return 0;

  fi;

  # 2017-05-17 jj5 - NOTE: we're racing the log file from 'tee', wait a bit...
  sleep 1;

  local message="$1";
  local error="$2";

  # 2017-05-19 jj5 - DONE: default message if unspecified...
  [ -z "${message:-}" ] && local message="Attached is the log, as requested.";
  [ -z "${error:-}" ] && local error="$LX_EXIT_ABORT";

  local mailer="$( which mail )";

  local timestamp="$( date +%s )";

  if [ -z "$LX_SCRIPT_INITIATED_TIMESTAMP" ]; then

    local runtime="$SECONDS";

  else

    local runtime=$(( $timestamp - $LX_SCRIPT_INITIATED_TIMESTAMP ));

  fi

  local runtime_formatted=$( lx_format_duration $runtime );

  if [ -z "$LX_SCRIPT_CMD" ]; then

    local cmd_val='toolkit';

  else

    local cmd_val="$LX_SCRIPT_CMD$( printf " %q" "${LX_SCRIPT_ARGS[@]}" )";

  fi

  local sub_val="${LX_SCRIPT_SUBSHELL:-0}";
  local dir_val="${LX_SCRIPT_CWD:-$PWD}";
  local usr_val="${USER:-unknown}";
  local sys_val="${HOSTNAME:-unknown}";
  local log_val="${LX_SCRIPT_LOG:-none}";
  local cwd_val="$PWD";
  local lck_val="${LX_LOCK_FILE:-none}";
  local dat_val="${LX_STATE_DIR:-none}";

  local cmd_line=$'\ncmd: '"$cmd_val";
  local sub_line=$'\nsub: '"$sub_val";
  local dir_line=$'\ndir: '"$dir_val";
  local usr_line=$'\nusr: '"$usr_val";
  local sys_line=$'\nsys: '"$sys_val";
  local log_line=$'\nlog: '"$log_val";
  local run_line=$'\nrun: '"$runtime_formatted";
  local cwd_line=$'\ncwd: '"$cwd_val";
  local lck_line=$'\nlck: '"$lck_val";
  local dat_line=$'\ndat: '"$dat_val";

  local report=$'\n'"${cmd_line}${sub_line}${dir_line}${usr_line}${sys_line}";
  local report="${report}${log_line}${run_line}${cwd_line}${lck_line}${dat_line}"$'\n\n';
  local logged='<ERROR>';

  # 2018-02-04 jj5 - SEE: sed commands stolen from StackOverflow:
  # https://stackoverflow.com/a/35582778/868138
  #
  [ -f "${LX_SCRIPT_LOG:-}" ] && local logged="$(
    tail -n 1337 "$LX_SCRIPT_LOG" | \
    sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" | sed "s/\x0f//g"
  )";

  local to="${LX_ERROR_EMAIL:-}";

  # 2017-05-17 jj5 - DONE: default email is to jj5@jj5.net...
  [ -z "${to:-}" ] && local to="jj5@jj5.net";

  if [ "$error" = "0" ]; then

    local subject="[LOG] log file for $USER@$HOSTNAME:${LX_SCRIPT_PATH:-}";

  else

    local subject="[ERROR] error[$error] in $USER@$HOSTNAME:${LX_SCRIPT_PATH:-}";

  fi

  local body="$message$report$logged";

  if [ -x "$mailer" ]; then

    echo "$body" | "$mailer" -s "$subject" "$to";

    local mail_err="$?";

    [ "$mail_err" = "0" ] || {

      lx_report "error '$mail_err' sending diagnostic email.";

      return "$mail_err";

    }

  else

    # 2017-05-19 jj5 - NOTE: don't call fail() here, fail() calls us!
    lx_report "couldn't send diagnostic email.";

    return "$LX_EXIT_BAD_ENVIRONMENT";

  fi

  return 0;

}

lx_format_duration() {

  # 2017-06-23 jj5 - "d" for "duration"...
  local d="$1";

  [ -z "${d:-}" ] && d=$SECONDS;

  echo "$(( $d / 3600 ))h $(( ( $d / 60 ) % 60 ))m $(( $d % 60 ))s."

}

# 2017-07-10 jj5 - offline() returns true if host is not responding to ping...
lx_is_offline() {

  local host="$1";

  lx_ensure 1 'host' "$host";

  if lx_is_online "$host"; then

    return 1;

  fi

  return 0;

}

# 2017-07-10 jj5 - online() returns true if host is responding to ping...
lx_is_online() {

  local host="$1";

  lx_ensure 1 'host' "$host";

  for i in $( seq 1 5 ); do

    if ping -c 1 -W 2 "$host" 1>/dev/null 2>&1; then

      return 0;

    fi

    local known_host=$( ssh-keyscan -t rsa "$host" 2>/dev/null );

    [ -z "${known_host:-}" ] || return 0;

  done

  return 1;

}

# 2017-07-10 jj5 - ip_in_use() returns true if host IP address is in use...
lx_is_ip_in_use() {

  local host="$1";

  lx_ensure 1 'host' "$host";

  if ping -c 1 -W 1 "$host" 1>/dev/null 2>&1; then

    return 0;

  fi

  local known_host=$( ssh-keyscan -t rsa "$host" 2>/dev/null );

  [ -z "${known_host:-}" ] || return 0;

  return 1;

}

# 2017-06-30 jj5 - uses SSH and sudo to shutdown a host. Uses
# ping to determine if host is up.
lx_stop_host() {

  local host="$1";

  ping -c 1 -W 2 "$host" 1>/dev/null 2>&1 || return 0;

  lx_report "shutting down $host...";

  lx_ssh $host sudo halt;

  while ping -c 1 -W 2 "$host" 1>/dev/null 2>&1; do

    lx_report "waiting for '$host' to halt...";

    sleep 1;

  done;

  # 2017-07-01 jj5 - give it some more time to shut down...
  sleep 5;

  true;

}

lx_wait_all() {

  local async_error="0";

  while true; do

    wait -n 1;

    local error="$?";

    if [ "$error" = "0" ]; then

      continue;

    fi;

    if [ "$error" = "127" ]; then

      break;

    fi;

    local async_error="$error";

  done;

  if [ "$async_error" != "0" ]; then

    lx_fail "$async_error" "error '$async_error' in async process.";

  fi;

  true;

}

lx_wait_for_host() {

  local host="$1";

  lx_report "waiting for host '$host'...";

  while ! ping -c 1 -W 2 "$host"; do

    lx_report "waiting for host '$host'...";

    sleep 3;

  done

  lx_report "host '$host' ready.";

}

lx_wait_for_host_offline() {

  local host="$1";

  lx_report "waiting for host '$host' to go offline...";

  while ping -c 1 -W 2 "$host"; do

    lx_report "  waiting...";

    sleep 1;

  done

  lx_report "host '$host' is offline.";

}

lx_remote_copy() {

  local src="$1";
  local tgt="$2";

  lx_ensure 1 'src' "$src";
  lx_ensure 2 'tgt' "$tgt";

  # 2024-02-18 jj5 - TODO: generate a unique temp file and register with lx_add_tmp()

  lx_ensure_workspace;

  local temp="$LX_WORKSPACE/remote-copy.tmp";

  [ -e "$temp" ] && lx_fail "temp file '$temp' already exists!?";

  lx_run scp "$src" "$temp";

  lx_run scp "$temp" "$tgt";

  lx_quiet rm "$temp";

}

# 2017-07-06 jj5 - get_ip() takes a host name and finds and IP address for it
# from DNS using the 'host' command. This function uses the temp $LX_WORKSPACE
# directory provided in the environment by the jj5-bin standard library.
lx_get_ip() {

  local host="$1";

  lx_ensure 1 'host' "$host";

  lx_ensure_workspace;

  local file="$LX_WORKSPACE/$host.host";

  host "$host" > "$file" 2>&1

  if [ "$?" = "0" ]; then

    local ip=$( cat "$file" | tail -n 1 | awk '{print $NF}' );

    lx_report "${LX_LBLUE}host '$host' has IP '$ip'.${LX_END}";

  else

    lx_warn "no IP for host '$host'.";

    # 2017-08-29 jj5 - better to fail this, I think...
    #local ip='127.0.0.1';
    local ip='';

  fi

  echo "$ip";

}

# 2024-02-18 jj5 - log failure, send email (if enabled), and exit with error
# 2024-02-18 jj5 - NOTE: calling idiom is: [ "$a" = "$b" ] || fail "err" "msg";
lx_fail() {

  [ "$LX_STD_INFAIL" = '0' ] || { lx_fatal "$LX_EXIT_NOT_SUPPORTED" "in lx_fail()"; }
  [ "$LX_STD_INNEED" = '0' ] || { lx_fatal "$LX_EXIT_NOT_SUPPORTED" "in lx_need()"; }

  LX_STD_INFAIL=1;

  # 2024-02-18 jj5 - we support one or two args. If two args first arg is error level, 2nd arg is message. Otherwise first
  # arg is message and error level is LX_EXIT_ABORT.

  local error="${1:-}";
  local message="${2:-}";

  if [ "$#" = '1' ]; then

    error="$LX_EXIT_ABORT";
    message="$1";

  fi;

  if [ "${#error}" -gt "${#message}" ]; then

    # 2024-02-18 jj5 - if the error level is longer than the message we probably got them the wrong way around, so
    # make some noise about that (and then exit anyway).

    lx_fatal "$LX_EXIT_BAD_PROGRAM" "error level '$error' is longer than message '$message'.";

  fi

  lx_err "error[$error]: $message";

  lx_run_job "cleaning up" lx_cleanup;

  # 2024-02-18 jj5 - default error level is LX_EXIT_ABORT
  [ -z "${error:-}"   ] && local error="$LX_EXIT_ABORT";
  [ -z "${message:-}" ] && local message="error during processing.";

  [ "$LX_STD_MAIL" = "1" ] && lx_quiet lx_sendlog "Error: $message" "$error";

  lx_report_finished "$error";

  exit "$error";

}

lx_fatal() {

  # 2024-02-18 jj5 - fatal errors are errors that shouldn't happen; if they do happen the program itself is probably
  # wrong. So if there's a fatal error we exit quickly. It should be okay to print the error message as we do with
  # lx_err() but we want to have minimal logic in this function, it should just bail as quickly as possible.

  local error="${1:-}";
  local message="${2:-}";

  [ -z "${error:-}"   ] && local error="$LX_EXIT_ABORT";
  [ -z "${message:-}" ] && local message="details unspecified.";

  lx_err "fatal error[$error]: $message";

  exit "$error";

}

lx_ensure_workspace() {

  [ -d "${LX_WORKSPACE:-}" ] || {

    # 2024-02-27 jj5 - usually the framework will have created a workspace, but if not we create an emergency workspace.

    LX_WORKSPACE=$( mktemp -d "${TMPDIR:-/tmp/}lx-workspace.$$.XXXXXXXXXXXX" );

    trap lx_remove_emergency_workspace EXIT;

  };

}

lx_remove_emergency_workspace() {
  
  [ -d "${LX_WORKSPACE:-}" ] && {

    lx_run rm -rf "$LX_WORKSPACE";

  };

}

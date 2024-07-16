#!/bin/bash

lx_once_per_year() {

  local process_name="$1";
  
  shift;

  lx_once_validate_env;

  local process_slug="$( lx_once_get_slug "$process_name" )";
  local current_time="$( date )";
  local timestamp="$( date -d "$current_time" +"%Y-%m-%d-%H%M%S" )";
  local process_dir="$LX_STATE_DIR/$process_slug";

  [ ! -d "$process_dir" ] && lx_run mkdir -p "$process_dir";

  local process_file="$process_dir/year-$( date -d "$current_time" +"%Y" ).log"
  local process_fail="$process_dir/year-$( date -d "$current_time" +"%Y" )-fail-$timestamp.log"

  lx_run lx_once "$process_name" "$process_slug" "$process_file" "$process_fail" "$@";

}

lx_once_per_month() {

  local process_name="$1";
  
  shift;

  lx_once_validate_env;

  local process_slug="$( lx_once_get_slug "$process_name" )";
  local current_time="$( date )";
  local timestamp="$( date -d "$current_time" +"%Y-%m-%d-%H%M%S" )";
  local process_dir="$LX_STATE_DIR/$process_slug/$( date -d "$current_time" +"%Y" )";

  [ ! -d "$process_dir" ] && lx_run mkdir -p "$process_dir";

  local process_file="$process_dir/month-$( date -d "$current_time" +"%m" ).log"
  local process_fail="$process_dir/month-$( date -d "$current_time" +"%m" )-fail-$timestamp.log"

  lx_run lx_once "$process_name" "$process_slug" "$process_file" "$process_fail" "$@";

}

lx_once_per_week() {

  local process_name="$1";
  
  shift;

  lx_once_validate_env;

  local process_slug="$( lx_once_get_slug "$process_name" )";
  local current_time="$( date )";
  local timestamp="$( date -d "$current_time" +"%Y-%m-%d-%H%M%S" )";
  local process_dir="$LX_STATE_DIR/$process_slug/$( date -d "$current_time" +"%Y/%m" )";

  [ ! -d "$process_dir" ] && lx_run mkdir -p "$process_dir";

  local current_week="$( lx_once_get_week "$current_time" )";

  local process_file="$process_dir/week-$current_week.log"
  local process_fail="$process_dir/week-$current_week-fail-$timestamp.log"

  lx_run lx_once "$process_name" "$process_slug" "$process_file" "$process_fail" "$@";

}

lx_once_per_day() {

  local process_name="$1";
  
  shift;

  lx_once_validate_env;

  local process_slug="$( lx_once_get_slug "$process_name" )";
  local current_time="$( date )";
  local timestamp="$( date -d "$current_time" +"%Y-%m-%d-%H%M%S" )";
  local process_dir="$LX_STATE_DIR/$process_slug/$( date -d "$current_time" +"%Y/%m" )";

  [ ! -d "$process_dir" ] && lx_run mkdir -p "$process_dir";

  local process_file="$process_dir/day-$( date -d "$current_time" +"%d" ).log"
  local process_fail="$process_dir/day-$( date -d "$current_time" +"%d" )-fail-$timestamp.log"

  lx_run lx_once "$process_name" "$process_slug" "$process_file" "$process_fail" "$@";

}

lx_once_per_hour() {

  local process_name="$1";
  
  shift;

  lx_once_validate_env;

  local process_slug="$( lx_once_get_slug "$process_name" )";
  local current_time="$( date )";
  local timestamp="$( date -d "$current_time" +"%Y-%m-%d-%H%M%S" )";
  local process_dir="$LX_STATE_DIR/$process_slug/$( date -d "$current_time" +"%Y/%m/%d" )";

  [ ! -d "$process_dir" ] && lx_run mkdir -p "$process_dir";

  local process_file="$process_dir/hour-$( date -d "$current_time" +"%H" ).log"
  local process_fail="$process_dir/hour-$( date -d "$current_time" +"%H" )-fail-$timestamp.log"

  lx_run lx_once "$process_name" "$process_slug" "$process_file" "$process_fail" "$@";

}

lx_once_validate_env() {

  [ -d "$LX_STATE_DIR" ] || {

    local container="$( dirname "$LX_STATE_DIR" )";

    [ -d "$container" ] || {

      lx_fail "$LX_EXIT_FILE_MISSING" "state directory '$container' missing.";

    };

    lx_run mkdir "$LX_STATE_DIR";

  }

  return 0;

}

lx_once() {

  local process_name="$1";
  local process_slug="$2";
  local process_file="$3";
  local process_fail="$4";

  shift; shift; shift; shift;

  [ -e "$process_file" ] && {

    lx_note "process '$process_name' has already been run for this period as indicated by '$process_file'.";

    return 0;

  }

  [ -e "$process_fail" ] && {

    lx_fail "$LX_EXIT_BAD_ENVIRONMENT" "the failure log file '$process_fail' for process '$process_name' already exists.";

  }

  echo "init.....: $( date )"         >> $process_file;
  echo "host.....: $( hostname -f )"  >> $process_file;
  echo "user.....: $( whoami )"       >> $process_file;
  echo "command..: $@"                >> $process_file;

  local error_level='?';

  if "$@"; then

    error_level="$?";

  else

    error_level="$?";

  fi;

  echo "error....: $error_level"  >> $process_file;
  echo "done.....: $( date )"     >> $process_file;

  [ $error_level != '0' ] && { mv "$process_file" "$process_fail"; }

  return "$error_level";

}

lx_once_get_slug() {

  local slug="$1";

  # 2024-07-15 jj5 - remove forward slashes from variable name, we can probably cope with any other characters in
  # process name (a directory will be created with this name)
  #
  slug="${slug//\//-}1";

  echo "$slug";

}

lx_once_get_week() {

  # 2024-07-15 jj5 - get the specific date from input (format: YYYY-MM-DD)
  #
  local input_date="$1";

  # 2024-07-15 jj5 - get the day of the month (without leading zeros) for the specific date
  #
  local day_of_month=$( date -d "$input_date" +%-d );

  # 2024-07-15 jj5 - get the day of the week for the specific date (1-7, Monday is 1)
  #
  local day_of_week=$( date -d "$input_date" +%u );

  # 2024-07-15 jj5 - calculate the week of the month
  #
  week_of_month=$(( ( day_of_month + 6 - day_of_week ) / 7 + 1 ));

  # 2024-07-15 jj5 - print the week of the month
  #
  echo "$week_of_month";

}

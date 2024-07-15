#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-netstat.lock';

main() {

  local period="$1";

  shift;

  case "$period" in

    year)   lx_run lx_once_per_year   "$@";;
    month)  lx_run lx_once_per_month  "$@";;
    week)   lx_run lx_once_per_week   "$@";;
    day)    lx_run lx_once_per_day    "$@";;
    hour)   lx_run lx_once_per_hour   "$@";;

    *) lx_fail "$LX_EXIT_BAD_VALUE" "unsupported period '$period'.";;

  esac;

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

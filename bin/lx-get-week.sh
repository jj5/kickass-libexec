#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-netstat.lock';

main() {

  local now="$( date +%Y-%m-%d )";

  local time="${1:-$now}";

  echo $( lx_once_get_week "$time" );

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

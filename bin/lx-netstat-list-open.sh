#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-netstat.lock';

main() {

  lx_netstat_list_open "$@";

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

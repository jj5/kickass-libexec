#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-spy.lock';

main() {

  lx_spy "$@";

  lx_watch_logs;

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

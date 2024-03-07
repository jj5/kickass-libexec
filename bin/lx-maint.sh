#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-maint.lock';

main() {

  lx_maint "$@";

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

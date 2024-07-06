#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-update-web.lock';

main() {

  #lx_default status 0;

  lx_update_web "$@";

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

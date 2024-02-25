#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-notify.lock';

main() {

  lx_notify "$@";

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

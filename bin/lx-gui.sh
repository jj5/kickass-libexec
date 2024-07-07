#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-gui.lock';

main() {

  lx_sync "$@";

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

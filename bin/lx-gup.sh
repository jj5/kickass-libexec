#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-gup.lock';

main() {

  lx_vcs_update "$@";

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

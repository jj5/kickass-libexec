#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-project.lock';

main() {

  lx_new_project "$@";

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

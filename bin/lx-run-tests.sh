#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-test.lock';

main() {

  lx_run_tests "$@";

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-version.lock';

main() {

  lx_version_increment_patch;

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

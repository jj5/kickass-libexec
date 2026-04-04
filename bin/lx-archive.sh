#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-archive.lock';

main() {

  lx_default status 0;

  lx_archive remove "$@";

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

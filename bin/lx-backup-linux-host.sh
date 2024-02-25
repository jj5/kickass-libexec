#!/bin/bash

main() {

  lx_require user root;

  for host in "$@"; do

    lx_backup_linux_host "$host";

  done;

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

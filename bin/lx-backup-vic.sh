#!/bin/bash

main() {

  lx_require user root;

  lx_backup_vic;

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

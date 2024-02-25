#!/bin/bash

main() {

  lx_default status 0;

  lx_archive_file copy "$@";

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

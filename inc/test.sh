#!/bin/bash

# 2024-02-18 jj5 - this is a simple test framework...

source "$( dirname "${BASH_SOURCE[0]}" )/lib.sh";

[ -d "$LX_DIR_INC" ] || { echo "error: LX_DIR_INC not found: $LX_DIR_INC"; exit 40; }
[ -d "$LX_DIR_BIN" ] || { echo "error: LX_DIR_BIN not found: $LX_DIR_BIN"; exit 40; }
[ -d "$LX_DIR_SRC" ] || { echo "error: LX_DIR_SRC not found: $LX_DIR_SRC"; exit 40; }

TEST_ARGS=( "$@" );

lx_declare_tests() {

  if [ "${#TEST_ARGS[@]}" != '0' ]; then

    for test in "${TEST_ARGS[@]}"; do

      $test;

      error="$?";

      if [ "$error" != 0 ]; then

        exit "$error";

      fi;

    done;

    exit 0;

  fi;

  echo "$@";

  exit "$LX_EXIT_OPTIONS_LISTED";

}

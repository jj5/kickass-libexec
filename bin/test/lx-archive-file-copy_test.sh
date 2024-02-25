#!/bin/bash

source "$( dirname "${BASH_SOURCE[0]}" )/../../inc/test.sh";

test_lx_archive_file_copy_error_1() {

  local script="$LX_DIR_BIN/lx-archive-file-copy.sh";

  # 2024-02-25 jj5 - this will fail because no files are specified.
  #
  "$script" --no-mail;

  exit "$?";

}

test_lx_archive_file_copy() {

  set -euo pipefail;

  local script="$LX_DIR_BIN/lx-archive-file-copy.sh";

  [ -x "$script" ] || { lx_err "script '$script' not executable."; exit 1; }

  cd /tmp;

  rm -rf lx-archive-file-copy-test;

  mkdir -p lx-archive-file-copy-test;

  cd lx-archive-file-copy-test;

  mkdir -p archive;
  mkdir -p source;

  cd archive;

  export LX_ARCHIVE_DIR="$PWD";

  cd ../source;

  date > file-1.txt
  date > file-2.txt

  cd ..;

  "$script" --no-mail source/*;

  local archive_dir="archive/$( ls archive | tail -n 1 )";

  [ -d "$archive_dir" ] || { lx_err "archive dir '$archive_dir' not found."; exit 1; }

  diff -u 'source/file-1.txt' "$archive_dir/file-1.txt";
  diff -u 'source/file-2.txt' "$archive_dir/file-2.txt";

  rm -rf /tmp/lx-archive-file-copy-test;

}

lx_declare_tests "
test_lx_archive_file_copy_error_1:1
test_lx_archive_file_copy
";

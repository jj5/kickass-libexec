#!/bin/bash

source "$( dirname "${BASH_SOURCE[0]}" )/../../inc/test.sh";

test_lx_archive_error_1() {

  local script="$LX_DIR_BIN/lx-archive.sh";

  # 2024-02-25 jj5 - this will fail because no files are specified.
  #
  "$script" --no-mail;

  exit "$?";

}

test_lx_archive() {

  set -euo pipefail;

  local script="$LX_DIR_BIN/lx-archive.sh";

  [ -x "$script" ] || { lx_err "script '$script' not executable."; exit 1; }

  cd /tmp;

  rm -rf lx-archive-test;

  mkdir -p lx-archive-test;

  cd lx-archive-test;

  mkdir -p archive;
  mkdir -p source;

  cd archive;

  export LX_ARCHIVE_DIR="$PWD";

  cd ../source;

  date > file-1.txt
  date > file-2.txt

  cd ..;

  "$script" --no-mail source;

  local archive_dir="archive/$( ls archive | tail -n 1 )";

  [ -d "$archive_dir" ] || { lx_err "archive dir '$archive_dir' not found."; exit 1; }

  [ -e 'source/file-1.txt' ] && { lx_err "source file-1.txt still exists."; exit 1; }
  [ -e 'source/file-2.txt' ] && { lx_err "source file-2.txt still exists."; exit 1; }

  [ -e "$archive_dir/source/file-1.txt" ] || { lx_err "archive file-1.txt not found."; exit 1; }
  [ -e "$archive_dir/source/file-2.txt" ] || { lx_err "archive file-2.txt not found."; exit 1; }

  rm -rf /tmp/lx-archive-test;

}

lx_declare_tests "
test_lx_archive_error_1:1
test_lx_archive
";

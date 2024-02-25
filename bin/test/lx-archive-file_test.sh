#!/bin/bash

source "$( dirname "${BASH_SOURCE[0]}" )/../../inc/test.sh";

test_lx_archive_file_error_1() {

  local script="$LX_DIR_BIN/lx-archive-file.sh";

  # 2024-02-25 jj5 - this will fail because no files are specified.
  #
  "$script" --no-mail;

  exit "$?";

}

test_lx_archive_file() {

  set -euo pipefail;

  local script="$LX_DIR_BIN/lx-archive-file.sh";

  [ -x "$script" ] || { lx_err "script '$script' not executable."; exit 1; }

  cd /tmp;

  rm -rf lx-archive-file-test;

  mkdir -p lx-archive-file-test;

  cd lx-archive-file-test;

  mkdir -p archive;
  mkdir -p source;

  cd archive;

  export LX_ARCHIVE_DIR="$PWD";

  cd ../source;

  mkdir -p a/b/c;

  cd a/b/c;

  date > file-1.txt
  date > file-2.txt

  cd ../../../../;

  [ -d "source/a/b/c" ] || { lx_err "source/a/b/c not found."; exit 1; }

  "$script" --no-mail source/a/b/c/*;

  local archive_dir="archive/$( ls archive | tail -n 1 )";

  [ -d "$archive_dir" ] || { lx_err "archive dir '$archive_dir' not found."; exit 1; }

  [ -e 'source/a/b/c/file-1.txt' ] && { lx_err "source file-1.txt still exists."; exit 1; }
  [ -e 'source/a/b/c/file-2.txt' ] && { lx_err "source file-2.txt still exists."; exit 1; }

  [ -e "$archive_dir/file-1.txt" ] || { lx_err "archive file-1.txt not found."; exit 1; }
  [ -e "$archive_dir/file-2.txt" ] || { lx_err "archive file-2.txt not found."; exit 1; }

  rm -rf /tmp/lx-archive-file-test;

}

lx_declare_tests "
test_lx_archive_file_error_1:1
test_lx_archive_file
";

#!/bin/bash

source "$( dirname "${BASH_SOURCE[0]}" )/../../inc/test.sh";

test_lx_archive_import() {

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

  mkdir -p empty
  mkdir -p full

  date > full/file-1.txt
  date > full/file-2.txt
  date > full/.hidden-file.txt

  lx_archive_auto empty;
  lx_archive_auto full;

  [ "$( ls -alh | wc -l )" == 6 ] || { ls -alh; lx_err "expected 5 files in source dir."; exit 1; }

  [ "$( ls -alh archive | wc -l )" == 5 ] || { lx_err "expected 4 files in archive dir."; exit 1; }

  [ "$( ls -alh empty | wc -l )" == 3 ] || { lx_err "expected 2 files in empty dir."; exit 1; }

  [ "$( ls -alh full | wc -l )" == 3 ] || { lx_err "expected 2 files in full dir."; exit 1; }

  lx_archive_import "$HOSTNAME" "$LX_ARCHIVE_DIR";

  rm -rf /tmp/lx-archive-test;

}

lx_declare_tests "
test_lx_archive_import
";

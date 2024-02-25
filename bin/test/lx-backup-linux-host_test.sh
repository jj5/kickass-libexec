#!/bin/bash

export LX_ZFS_DATA_HOST='data/temp/host';

source "$( dirname "${BASH_SOURCE[0]}" )/../../inc/test.sh";

test_lx_backup_linux_host() {

  set -euo pipefail;

  local script="$LX_DIR_BIN/lx-backup-linux-host.sh";

  [ -x "$script" ] || { lx_err "script '$script' not executable."; exit 1; }

  time sudo "$script" "$HOSTNAME";

}

lx_declare_tests "
test_lx_backup_linux_host
";

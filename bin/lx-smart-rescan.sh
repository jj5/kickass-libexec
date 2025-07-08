#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-smart-rescan.lock';

main() {

  set -euo pipefail;

  lx_require user root;

  # 2025-07-08 jj5 - SEE: https://chatgpt.com/share/686c8a9f-304c-8006-8de0-51614168f8fe

  # rescan-smart.sh — force kernel and smartd to notice a hotswapped disk

  # 1. kernel rescan

  lx_note "rescanning SCSI hosts for new devices...";

  for host in /sys/class/scsi_host/host*; do

    echo "- - -" > "$host/scan"

  done

  # 2. give it a second
  lx_run sleep 3

  # 3. list new devices
  lx_run smartctl --scan

  # 4. reload smartd
  # 2025-07-08 jj5 - NEW: I think that restart is stronger than reload...
  lx_run systemctl restart smartmontools
  # 2025-07-08 jj5 - OLD:
  #lx_run systemctl reload smartmontools

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

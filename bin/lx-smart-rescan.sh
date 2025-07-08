#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-smart-rescan.lock';

# 2025-07-08 jj5 - rescan-smart.sh — force kernel and smartd to notice a hotswapped disk

main() {

  set -euo pipefail;

  lx_require user root;

  lx_require command hdparm;

  # 2025-07-08 jj5 - SEE: https://chatgpt.com/share/686c8a9f-304c-8006-8de0-51614168f8fe

  # 2025-07-08 jj5 - kernel rescan

  lx_note "rescanning SCSI hosts for new devices...";

  for host in /sys/class/scsi_host/host*; do

    lx_note "rescaning: $host";

    echo "- - -" > "$host/scan"

  done

  lx_note "rescanning ATA devices...";

  for device in /sys/class/block/sd?; do

    lx_note rescaning: "$device";

    echo 1 | sudo tee "$device/device/rescan"

  done;

  lx_note "re-reading partition table for ATA drives...";

  for device in /dev/sd?; do

    lx_note "re-reading partition table for: $device";

    lx_run hdparm -z "$device"

  done;

  # 2025-07-08 jj5 - give it a second
  lx_run sleep 3

  # 2025-07-08 jj5 - list new devices
  lx_run smartctl --scan

  # 2025-07-08 jj5 - reload smartd
  # 2025-07-08 jj5 - NEW: I think that restart is stronger than reload...
  lx_run systemctl restart smartmontools
  # 2025-07-08 jj5 - OLD:
  #lx_run systemctl reload smartmontools

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

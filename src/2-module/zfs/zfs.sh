#!/bin/bash

lx_zfs_snapshot() {

  local zfs_file_system="$1";
  local timestamp="${2:-}";
  local max="${3:-47}";

  [ -z "$timestamp" ] && timestamp=$( date +%Y-%m-%d-%H%M%S );

  lx_run "$LX_DIR_BIN/libexec/hanok.php" --max $max --type zfs "$zfs_file_system";

  lx_run zfs snapshot "$zfs_file_system@$timestamp";

}

lx_zfs_pull_host() {

  local src_host="$1";

  for host in $( lx_ssh "$src_host" ls /data/host ); do

    lx_report "pulling host backups from '$src_host' for host '$host'...";

    if [ -d "/data/host/$host/" ]; then

      # 2023-12-04 jj5 - local ZFS file system already exists...
      true;

    else

      lx_run zfs create "data/host/$host"

    fi

    lx_run lx_zfs_pull "$src_host" "data/host/$host";

  done;

}

lx_zfs_pull() {

  local src_host="$1";
  local zfs_file_system="$2";

  if [ -d "/$zfs_file_system/" ]; then

    # 2023-12-04 jj5 - local ZFS file system already exists...
    true;

  else

    lx_fail "run zfs create $zfs_file_system";

  fi

  for snapshot in $( lx_ssh "$src_host" ls "/$zfs_file_system/.zfs/snapshot" ); do

    if [ -d "/$zfs_file_system/.zfs/snapshot/$snapshot" ]; then

      # 2023-12-04 jj5 - we already have this snapshot...
      continue;

    fi

    lx_run lx_rsync_mirror "$src_host:/$zfs_file_system/.zfs/snapshot/$snapshot/" "/$zfs_file_system/";

    lx_run zfs snapshot "$zfs_file_system@$snapshot";

  done

  for snapshot in $( ls "/$zfs_file_system/.zfs/snapshot" ); do

    if lx_ssh "$src_host" test ! -d "/$zfs_file_system/.zfs/snapshot/$snapshot"; then

      lx_run zfs destroy "$zfs_file_system@$snapshot";

    fi

  done

}

lx_zfs_push_host() {

  local tgt_host="$1";

  for host in $( ls /data/host ); do

    lx_report "pushing host backups to '$tgt_host' for host '$host'...";

    if lx_ssh "$tgt_host" test ! -d "/data/host/$host"; then

      lx_run lx_ssh "$tgt_host" zfs create "data/host/$host"

    fi

    lx_run lx_zfs_push "$tgt_host" "data/host/$host";

  done;

}

lx_zfs_push() {

  local tgt_host="$1";
  local zfs_file_system="$2";

  if lx_ssh "$tgt_host" test -d "/$zfs_file_system/"; then

    # 2023-12-12 jj5 - target exists, that's good

    true;

  else

    # 2023-12-12 jj5 - target doesn't exist or connection error, fail

    lx_fail "run ssh '$tgt_host' zfs create $zfs_file_system";

  fi

  for snapshot in $( ls "/$zfs_file_system/.zfs/snapshot" ); do

    if lx_ssh "$tgt_host" test ! -d "/$zfs_file_system/.zfs/snapshot/$snapshot"; then

      lx_run lx_rsync_mirror "/$zfs_file_system/.zfs/snapshot/$snapshot/" "$tgt_host:/$zfs_file_system/";

      lx_run lx_ssh "$tgt_host" zfs snapshot "$zfs_file_system@$snapshot";

    fi

  done

  for snapshot in $( lx_ssh "$tgt_host" ls "/$zfs_file_system/.zfs/snapshot" ); do

    if test ! -d "/$zfs_file_system/.zfs/snapshot/$snapshot"; then

      lx_run lx_ssh "$tgt_host" zfs destroy "$zfs_file_system@$snapshot";

    fi

  done

}

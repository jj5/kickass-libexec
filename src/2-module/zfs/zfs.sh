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

lx_zfs_pull_host_secure() {

  local src_host="$1";

  for host in $( lx_ssh "$src_host" ls /data/secure/host ); do

    lx_report "pulling secure host backups from '$src_host' for host '$host'...";

    if [ -d "/data/secure/host/$host/" ]; then

      # 2023-12-04 jj5 - local ZFS file system already exists...
      true;

    else

      lx_run zfs create "data/secure/host/$host"

    fi

    lx_run lx_zfs_pull "$src_host" "data/secure/host/$host";

  done;

}

lx_zfs_pull() {

  local src_host="$1";
  local zfs_src="$2";
  local zfs_tgt="$zfs_src";

  if [ -n "${3:-}" ]; then
  
    zfs_tgt="$3";

  fi

  if [ -d "/$zfs_tgt/" ]; then

    # 2023-12-04 jj5 - local ZFS file system already exists...
    true;

  else

    lx_fail "ZFS file system $zfs_tgt is not mounted at /$zfs_tgt.";

  fi

  for snapshot in $( lx_ssh "$src_host" ls "/$zfs_src/.zfs/snapshot" ); do

    if [ -d "/$zfs_tgt/.zfs/snapshot/$snapshot" ]; then

      # 2023-12-04 jj5 - we already have this snapshot...
      continue;

    fi

    lx_run lx_rsync_mirror "$src_host:/$zfs_src/.zfs/snapshot/$snapshot/" "/$zfs_tgt/";

    lx_run zfs snapshot "$zfs_tgt@$snapshot";

  done

  for snapshot in $( ls "/$zfs_tgt/.zfs/snapshot" ); do

    if lx_ssh "$src_host" test ! -d "/$zfs_src/.zfs/snapshot/$snapshot"; then

      lx_run zfs destroy "$zfs_tgt@$snapshot";

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
  local zfs_src="$2";
  local zfs_tgt="$zfs_src";

  if [ -n "${3:-}" ]; then
  
    zfs_tgt="$3";

  fi

  if lx_ssh "$tgt_host" test -d "/$zfs_tgt/"; then

    # 2023-12-12 jj5 - target exists, that's good

    true;

  else

    # 2023-12-12 jj5 - target doesn't exist or connection error, fail

    lx_fail "run ssh '$tgt_host' zfs create $zfs_tgt";

  fi

  for snapshot in $( ls "/$zfs_src/.zfs/snapshot" ); do

    if lx_ssh "$tgt_host" test ! -d "/$zfs_tgt/.zfs/snapshot/$snapshot"; then

      lx_run lx_rsync_mirror "/$zfs_src/.zfs/snapshot/$snapshot/" "$tgt_host:/$zfs_tgt/";

      lx_run lx_ssh "$tgt_host" zfs snapshot "$zfs_tgt@$snapshot";

    fi

  done

  for snapshot in $( lx_ssh "$tgt_host" ls "/$zfs_tgt/.zfs/snapshot" ); do

    if test ! -d "/$zfs_src/.zfs/snapshot/$snapshot"; then

      lx_run lx_ssh "$tgt_host" zfs destroy "$zfs_tgt@$snapshot";

    fi

  done

}

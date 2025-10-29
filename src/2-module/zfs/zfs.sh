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

  lx_note "pulling ZFS file system from $src_host:$zfs_src to $zfs_tgt...";

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

    lx_run lx_zfs_mirror "$src_host:/$zfs_src/.zfs/snapshot/$snapshot/" "/$zfs_tgt/";

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

  lx_note "pushing ZFS file system $zfs_src to $tgt_host:$zfs_tgt...";

  if lx_ssh "$tgt_host" test -d "/$zfs_tgt/"; then

    # 2023-12-12 jj5 - target exists, that's good

    true;

  else

    # 2023-12-12 jj5 - target doesn't exist or connection error, fail

    lx_fail "run ssh '$tgt_host' zfs create $zfs_tgt";

  fi

  for snapshot in $( ls "/$zfs_src/.zfs/snapshot" ); do

    if lx_ssh "$tgt_host" test ! -d "/$zfs_tgt/.zfs/snapshot/$snapshot"; then

      lx_run lx_zfs_mirror "/$zfs_src/.zfs/snapshot/$snapshot/" "$tgt_host:/$zfs_tgt/";

      lx_run lx_ssh "$tgt_host" zfs snapshot "$zfs_tgt@$snapshot";

    fi

  done

  for snapshot in $( lx_ssh "$tgt_host" ls "/$zfs_tgt/.zfs/snapshot" ); do

    if test ! -d "/$zfs_src/.zfs/snapshot/$snapshot"; then

      lx_run lx_ssh "$tgt_host" zfs destroy "$zfs_tgt@$snapshot";

    fi

  done

}

lx_zfs_mirror() {

  # 2025-10-29 jj5 - this will rsync for zfs mirror

  local src="$1";
  local tgt="$2";
  local host_type="${3:-linux}";

  if [ -z "${src:-}" ]; then

    lx_fail "source must be specified.";

  fi;

  if [ -z "${tgt:-}" ]; then

    lx_fail "target must be specified.";

  fi;

  lx_report "ZFS mirroring (w/ rsync): $src to $tgt ($host_type)";

  local args=()

  case "$host_type" in
    "mac")
      # 2023-12-04 jj5 - no ACLs or xattrs for macOS...
      true;;
    "linux")
      # 2023-12-04 jj5 - include ACLs and xattrs for linux...
      args+=( --acls --xattrs );;
    *)
      lx_fail "unsupported host type '$host_type'.";;
  esac

  local progress='0';

  if [ "$progress" != '0' ]; then

    args+=( --progress );

  fi

  # 2023-12-04 jj5 - NOTE: we don't --exclude anything for an exact mirror

  # 2017-05-20 jj5 - the full rsync options are specified over multiple lines
  # to avoid bugs due to wrapping...
  # 2017-05-20 jj5 - SEE: The Horror Story:
  # https://www.progclub.org/blog/2017/05/19/rsync-unexpected-remote-arg/
  args+=( --stats --human-readable );
  args+=( --recursive --del --force --times );

  # 2025-10-29 jj5 - NEW: --hard-links is expensive and we probably don't need...
  args+=( --links --executability --numeric-ids );
  # 2025-10-29 jj5 - OLD:
  #args+=( --links --hard-links --executability --numeric-ids );

  # 2025-10-29 jj5 - NEW: add max-alloc in case more RAM is needed than default (1G)
  args+=( --max-alloc=8G );

  args+=( --owner --group --perms --sparse );
  args+=( --compress-level=0 );

  # 2023-12-04 jj5 - NOTE: we don't include --devices or --specials

  lx_run time rsync "${args[@]}" "$src" "$tgt"

}
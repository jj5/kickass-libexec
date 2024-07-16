#!/bin/bash

lx_backup_linux_host_if_online() {

  local host="$1";

  if lx_is_online "$host"; then

    lx_backup_linux_host "$@";

  fi

}

lx_backup_linux_host() {

  lx_backup_linux_host_internal lx_backup_linux_dir "$@";

}

lx_backup_linux_host_large() {

  lx_backup_linux_host_internal lx_backup_linux_dir_large "$@";

}

lx_backup_linux_host_internal() {

  local backup_function="$1";
  local host="$2";

  local zfs_file_system="$LX_ZFS_DATA_HOST/$host";

  local timecode=$( date +%Y-%m-%d-%H%M%S );

  lx_run zfs create -p "$zfs_file_system";

  lx_debug "zfs_file_system: $zfs_file_system";

  lx_run "$LX_DIR_BIN/libexec/hanok.php" --type zfs "$zfs_file_system";

  [ -e "/$zfs_file_system/.zfs/snapshot/$timecode" ] && { fail "snapshot directory already exists."; }

  lx_run pushd "/$zfs_file_system";

  local dir_list=( bin boot etc home lib opt root sbin srv usr var );

  for dir in "${dir_list[@]}"; do

    lx_report backing up $host:/$dir

    if lx_attempt 5 5 lx_ssh "$host" test -d "/$dir"; then

      if lx_ssh "$host" test -L "/$dir"; then

        lx_report "skipping $host:/$dir, it's a symlink.";

      elif lx_attempt 5 5 lx_ssh "$host" test ! -L "/$dir"; then

        # 2019-05-17 jj5 - this is not a symlink, we can continue...

        lx_run mkdir -p "$dir";

        if lx_attempt 5 5 $backup_function "$host" "$dir"; then

          # 2019-09-12 jj5 - success!

          true;

        else

          lx_fail "'$host:/$dir' backup failed.";

        fi;

      else

        lx_fail "'$host:/$dir' backup failed, is host offline?";

      fi;

    else

      lx_fail "'$host:/$dir' is not a directory or host offline.";

    fi;

  done;

  lx_run zfs snapshot "$zfs_file_system@$timecode";

  lx_run popd;

}

lx_backup_linux_dir() {

  local host="$1";
  local dir="$2";

  [ -d "$dir" ] || { lx_fail "directory '$dir' does not exist."; }

  lx_run lx_rsync_backup "$host:/$dir/" "$dir/" linux;

  return "$?";

}

lx_backup_linux_dir_large() {

  local host="$1";
  local dir="$2";

  [ -d "$dir" ] || { lx_fail "directory '$dir' does not exist."; }

  lx_run lx_rsync_backup_large "$host:/$dir/" "$dir/" linux;

  return "$?";

}

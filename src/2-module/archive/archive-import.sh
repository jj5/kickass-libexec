#!/bin/bash

lx_archive_import_default() {

  local host="$1";

  lx_run lx_archive_import "$host" /home/jj5/archive;
  lx_run lx_archive_import "$host" /root/archive;

}

lx_archive_import() {

  local host="$1";
  local user_archive_dir="$2";
  local data_archive_dir="/$LX_ZFS_DATA_ARCHIVE";

  lx_archive_download "$host" "$user_archive_dir" "$data_archive_dir";

  lx_run "$LX_DIR_BIN/libexec/deepen.php" "$data_archive_dir";

}

lx_archive_download() {

  local host="$1";
  local user_archive_dir="$2";
  local data_archive_dir="$3";
  local remote_user="${4:-root}";

  local data_archive_tmp="$data_archive_dir/temp";

  lx_note "importing $host:$user_archive_dir to $data_archive_dir";

  [ -e "$data_archive_tmp" ] && lx_fail "temp archive dir '$data_archive_tmp' already exists.";

  lx_run mkdir "$data_archive_tmp";

  local src=$remote_user@$host:$user_archive_dir/
  local tgt="$data_archive_tmp";

  [ -d "$tgt" ] || lx_fail "missing target dir '$tgt'.";

  if ssh -o StrictHostKeyChecking=no $remote_user@$host test -d "$user_archive_dir"; then

    # 2024-02-27 jj5 - the user archive directory exists, so we can proceed.

    true;

  else

    lx_warn "archive path $host:$user_archive_dir missing...";

    lx_run rmdir "$data_archive_tmp";

    return 0;

  fi

  lx_attempt 5 5 lx_rsync_mirror "$src" "$tgt";

  lx_quiet pushd "$tgt";

  lx_report "fixing permissions on imported files...";

  lx_run lx_own;

  lx_report "fixed permissions on imported files.";

  lx_quiet popd;

  if [ "$( ls "$tgt" | wc -l )" = 0 ]; then
    
    lx_warn "no files imported.";

    lx_run rmdir "$data_archive_tmp";

    return 0;

  fi;

  for dir in "$tgt"/*; do

    if [ ! -d "$dir" ]; then

      lx_fail "'$dir' is not a directory.";

    fi;

    local filename="$( basename "$dir" )";

    if [[ "$filename" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}$ ]]; then

      lx_note "archiving '$filename'..."

      local archive_path="$data_archive_dir/$filename";

      if [ -d "$archive_path" ]; then

        lx_fail "archive path '$archive_path' already exists...";

      fi

      lx_run mv "$dir" "$archive_path/"

      if ssh $remote_user@$host test -d "$user_archive_dir/$filename"; then

        lx_run ssh $remote_user@$host rm -rf "$user_archive_dir/$filename";
      
      else

        lx_fail "archive $host:$user_archive_dir/$filename missing.";

      fi

    else

      lx_fail "invalid archive name '$dir'."

    fi

  done

  lx_run rmdir "$data_archive_tmp";

}

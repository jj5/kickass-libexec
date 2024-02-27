#!/bin/bash

lx_rsync_backup() {

  # 2023-12-04 jj5 - a backup mirror exludes some files and handles some errors

  local src="$1";
  local tgt="$2";
  local host_type="${3:-linux}";

  if [ -z "${src:-}" ]; then

    lx_fail "source must be specified.";

  fi;

  if [ -z "${tgt:-}" ]; then

    lx_fail "target must be specified.";

  fi;

  lx_report "backup (w/ rsync): $src to $tgt ($host_type)";

  local args=()

  case "$host_type" in
    "mac")
      # 2023-12-04 jj5 - no ACLs or xattrs for macOS...
      true;;
    "linux")
      # 2023-12-04 jj5 - include ACLs and xattrs for linux...
      args+=( --acls --xattrs );
      # 2024-02-28 jj5 - this was removed because it's not supported on 'wit'
      # 2024-02-21 jj5 - this was needed to fix an issue with rsync
      #args+=( --max-alloc=0 );
      ;;
    *)
      lx_fail "unsupported host type '$host_type'.";;
  esac

  local progress='0';

  if [ "$progress" != '0' ]; then

    args+=( --progress );

  fi

  args+=( --exclude /lib/mysql/ );
  args+=( --exclude /lib/lxcfs/ );
  args+=( --exclude '*~'        );
  args+=( --exclude '*.tmp'     );

  # 2023-12-04 jj5 - NOTE: it's possible to delete excluded, but we don't...
  if false; then
    args+=( --delete-excluded );
  fi

  # 2017-05-20 jj5 - the full rsync options are specified over multiple lines
  # to avoid bugs due to wrapping...
  # 2017-05-20 jj5 - SEE: The Horror Story:
  # https://www.progclub.org/blog/2017/05/19/rsync-unexpected-remote-arg/
  args+=( --stats --human-readable );
  args+=( --recursive --del --force --times );
  args+=( --links --hard-links --executability --numeric-ids );
  args+=( --owner --group --perms --sparse );
  args+=( --compress-level=0 );

  # 2023-12-04 jj5 - NOTE: we don't include --devices or --specials

  # 2017-05-20 jj5 - grep filters are for rsync shit we want to hide
  local filter_a='rsync: send_files failed to open';

  # 2017-05-24 jj5 - an extra filter, not interested if non-regular files
  # are skipped, that is to be expected...
  local filter_b='skipping non-regular file';

  lx_report running rsync "${args[@]}" "$src" "$tgt";

  if time rsync "${args[@]}" "$src" "$tgt" 2>&1 | \
    grep --line-buffered -v "$filter_a" | \
    grep --line-buffered -v "$filter_b"; then

    # 2017-05-05 jj5 - no error. That's good!

    return 0;

  else

    local error="${PIPESTATUS[0]}";

  fi

  if [ "$error" = "12" ]; then

    lx_fail "$error" "error in rsync protocol data stream.";

  elif [ "$error" = "23" ]; then

    # 2017-05-05 jj5 - some files failed to transfer, just do our best...
    lx_warn "partial transfer due to error.";

  elif [ "$error" = "24" ]; then

    # 2017-05-05 jj5 - some files vanished before they could be copied, that's ok
    lx_warn "partial transfer due to vanished source files.";

  elif [ "$error" = "20" ]; then

    lx_report "received SIGUSR1 or SIGINT.";

    # 2017-05-05 jj5 - we caught an interrupt (e.g. Ctrl+C), so fail/exit...
    lx_fail "$error" "caught interrupt, will exit.";

  else

    # 2017-05-20 jj5 - fail on any other error...
    lx_fail "$error" "rsync failed with error '$error'.";

  fi

}

lx_rsync_mirror() {

  # 2023-12-04 jj5 - an exact mirror copies all files (no exlusions) and expects success.

  local src="$1";
  local tgt="$2";
  local host_type="${3:-linux}";

  if [ -z "${src:-}" ]; then

    lx_fail "source must be specified.";

  fi;

  if [ -z "${tgt:-}" ]; then

    lx_fail "target must be specified.";

  fi;

  lx_report "mirroring (w/ rsync): $src to $tgt ($host_type)";

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
  args+=( --links --hard-links --executability --numeric-ids );
  args+=( --owner --group --perms --sparse );
  args+=( --compress-level=0 );

  # 2023-12-04 jj5 - NOTE: we don't include --devices or --specials

  lx_run time rsync "${args[@]}" "$src" "$tgt"

}

lx_rsync_download() {

  # 2023-12-04 jj5 - download all files (no exlusions) and expect success, but it doesn't delete files
  # from the client, even if they're missing on the server.

  local src="$1";
  local tgt="$2";
  local host_type="${3:-linux}";

  if [ -z "${src:-}" ]; then

    lx_fail "source must be specified.";

  fi;

  if [ -z "${tgt:-}" ]; then

    lx_fail "target must be specified.";

  fi;

  lx_report "downloading (w/ rsync): $src to $tgt ($host_type)";

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

  args+=( --stats --human-readable );
  args+=( --recursive --force --times );
  args+=( --links --hard-links --executability --numeric-ids );
  args+=( --owner --group --perms --sparse );
  args+=( --compress-level=0 );

  # 2023-12-04 jj5 - NOTE: we don't include --devices or --specials

  lx_run time rsync "${args[@]}" "$src" "$tgt"

}

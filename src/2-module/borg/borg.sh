#!/bin/bash

lx_borg_init() {

  [ -z "$BORG_REPO" ] && lx_fail "BORG_REPO is not set.";
  [ -z "$BORG_PASSPHRASE" ] && lx_fail "BORG_PASSPHRASE is not set.";

  lx_note "initialising borg repository at $BORG_REPO...";

  lx_run borg init --encryption repokey-blake2

}

lx_borg_backup() {

  [ -z "$BORG_REPO" ] && lx_fail "BORG_REPO is not set.";
  [ -z "$BORG_PASSPHRASE" ] && lx_fail "BORG_PASSPHRASE is not set.";

  lx_note "backing up to borg repository at $BORG_REPO...";

  local args=()

  # 2020-10-04 jj5 - SEE: borg compression options:
  # https://borgbackup.readthedocs.io/en/stable/usage/help.html
  #
  #args+=( --compression lzma,6 );
  args+=( --compression zstd,22 );

  # 2020-10-04 jj5 - SEE: borg create:
  # https://borgbackup.readthedocs.io/en/stable/usage/create.html
  #
  args+=( --filter=AMCE );
  args+=( --list --show-rc --verbose );
  #args+=( --progress );
  #args+=( --dry-run );
  args+=( --stats );

  # 2022-01-24 jj5 - NEW: we exclude cache directories marked with a CACHEDIR.TAG file now...
  #
  args+=( --exclude-caches );

  # 2024-03-05 jj5 - we need this for rsync.net compatability...
  args+=( --remote-path borg1 );

  lx_run borg create "${args[@]}" ::'{hostname}-{now}' "$@" || {

    local error="$?";

    lx_fail "$error" "borg create failed with error level '$error'.";

  };

  lx_run borg prune         \
    --list                  \
    --prefix '{hostname}-'  \
    --show-rc               \
    --keep-daily    7       \
    --keep-weekly   4       \
    --keep-monthly  6       ;

}

lx_borg_backup_fast() {

  [ -z "$BORG_REPO" ] && lx_fail "BORG_REPO is not set.";
  [ -z "$BORG_PASSPHRASE" ] && lx_fail "BORG_PASSPHRASE is not set.";

  lx_note "backing up to borg repository at $BORG_REPO...";

  local args=()

  # 2020-10-04 jj5 - SEE: borg compression options:
  # https://borgbackup.readthedocs.io/en/stable/usage/help.html
  #
  #args+=( --compression lzma,6 );

  # 2020-10-04 jj5 - SEE: borg create:
  # https://borgbackup.readthedocs.io/en/stable/usage/create.html
  #
  args+=( --filter=AMCE );
  args+=( --list --show-rc --verbose );
  #args+=( --progress );
  #args+=( --dry-run );
  args+=( --stats );

  # 2022-01-24 jj5 - NEW: we exclude cache directories marked with a CACHEDIR.TAG file now...
  #
  args+=( --exclude-caches );

  # 2024-03-05 jj5 - we need this for rsync.net compatability...
  args+=( --remote-path borg1 );

  lx_run borg create "${args[@]}" ::'{hostname}-{now}' "$@" || {

    local error="$?";

    lx_fail "$error" "borg create failed with error level '$error'.";

  };

  lx_run borg prune         \
    --list                  \
    --prefix '{hostname}-'  \
    --show-rc               \
    --keep-daily    7       \
    --keep-weekly   4       \
    --keep-monthly  6       ;

}

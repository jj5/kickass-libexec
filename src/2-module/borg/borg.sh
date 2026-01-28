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
  #args+=( --compression zstd,22 );
  #args+=( --compression lzma,6 );
  #args+=( --compression zstd,22,threads=auto );
  args+=( --compression auto,lzma,6 );

  # 2020-10-04 jj5 - SEE: borg create:
  # https://borgbackup.readthedocs.io/en/stable/usage/create.html
  #

  # 2024-04-21 jj5 - NEW: only report errors...
  args+=( --filter=CE );
  # 2024-04-21 jj5 - OLD:
  #args+=( --filter=AMCE );

  args+=( --list --show-rc --verbose );
  #args+=( --progress );
  #args+=( --dry-run );
  args+=( --stats );

  # 2022-01-24 jj5 - NEW: we exclude cache directories marked with a CACHEDIR.TAG file now...
  #
  args+=( --exclude-caches );

  # 2024-03-05 jj5 - we need this for rsync.net compatability...
  args+=( --remote-path borg1 );

  lx_note "running borg create for '$BORG_REPO'...";

  lx_run borg create "${args[@]}" ::'{hostname}-{now}' "$@" || {

    local error="$?";

    lx_fail "$error" "borg create failed with error level '$error'.";

  };

  # 2024-05-19 JJ5 - OLD:     --prefix '{hostname}-'  \

  lx_note "running borg prune for '$BORG_REPO'...";

  lx_run borg prune         \
    --remote-path borg1     \
    --list                  \
    --show-rc               \
    --keep-daily    7       \
    --keep-weekly   4       \
    --keep-monthly  6       ;

  lx_note "running borg check for '$BORG_REPO'...";

  # 2024-06-02 jj5 - THINK: remove --verbose from this?
  #
  lx_once_per_month "borg-check-$BORG_REPO" borg check --remote-path borg1 --verbose;

}

lx_borg_backup_zstd() {

  [ -z "$BORG_REPO" ] && lx_fail "BORG_REPO is not set.";
  [ -z "$BORG_PASSPHRASE" ] && lx_fail "BORG_PASSPHRASE is not set.";

  lx_note "backing up to borg repository at $BORG_REPO...";

  local args=()

  # 2020-10-04 jj5 - SEE: borg compression options:
  # https://borgbackup.readthedocs.io/en/stable/usage/help.html
  #
  #args+=( --compression zstd,22 );
  #args+=( --compression lzma,6 );
  #args+=( --compression zstd,22,threads=auto );
  #args+=( --compression auto,lzma,6 );

  # 2026-01-28 jj5 - NEW: removed threads=auto because my version of borg does not support
  args+=( --compression zstd,6 );
  # 2026-01-28 jj5 - OLD: my version of borg doesn't suppport this:
  #args+=( --compression zstd,6,threads=auto );


  # 2020-10-04 jj5 - SEE: borg create:
  # https://borgbackup.readthedocs.io/en/stable/usage/create.html
  #

  # 2024-04-21 jj5 - NEW: only report errors...
  args+=( --filter=CE );
  # 2024-04-21 jj5 - OLD:
  #args+=( --filter=AMCE );

  args+=( --list --show-rc --verbose );
  #args+=( --progress );
  #args+=( --dry-run );
  args+=( --stats );

  # 2022-01-24 jj5 - NEW: we exclude cache directories marked with a CACHEDIR.TAG file now...
  #
  args+=( --exclude-caches );

  # 2024-03-05 jj5 - we need this for rsync.net compatability...
  args+=( --remote-path borg1 );

  lx_note "running borg create for '$BORG_REPO'...";

  lx_run borg create "${args[@]}" ::'{hostname}-{now}' "$@" || {

    local error="$?";

    lx_fail "$error" "borg create failed with error level '$error'.";

  };

  # 2024-05-19 JJ5 - OLD:     --prefix '{hostname}-'  \

  lx_note "running borg prune for '$BORG_REPO'...";

  lx_run borg prune         \
    --remote-path borg1     \
    --list                  \
    --show-rc               \
    --keep-daily    7       \
    --keep-weekly   4       \
    --keep-monthly  6       ;

  lx_note "running borg check for '$BORG_REPO'...";

  # 2024-06-02 jj5 - THINK: remove --verbose from this?
  #
  lx_once_per_month "borg-check-$BORG_REPO" borg check --remote-path borg1 --verbose;

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

  # 2024-04-21 jj5 - NEW: only report errors...
  args+=( --filter=CE );
  # 2024-04-21 jj5 - OLD:
  #args+=( --filter=AMCE );

  args+=( --list --show-rc --verbose );
  #args+=( --progress );
  #args+=( --dry-run );
  args+=( --stats );

  # 2022-01-24 jj5 - NEW: we exclude cache directories marked with a CACHEDIR.TAG file now...
  #
  args+=( --exclude-caches );

  # 2024-03-05 jj5 - we need this for rsync.net compatability...
  args+=( --remote-path borg1 );

  lx_note "running borg create for '$BORG_REPO'...";

  lx_run borg create "${args[@]}" ::'{hostname}-{now}' "$@" || {

    local error="$?";

    lx_fail "$error" "borg create failed with error level '$error'.";

  };

  # 2024-05-17 jj5 - OLD: --prefix '{hostname}-'  \

  lx_note "running borg prune for '$BORG_REPO'...";

  lx_run borg prune         \
    --remote-path borg1     \
    --list                  \
    --show-rc               \
    --keep-daily    7       \
    --keep-weekly   4       \
    --keep-monthly  6       ;

  lx_note "running borg check for '$BORG_REPO'...";

  # 2024-06-02 jj5 - THINK: remove --verbose from this?
  #
  lx_once_per_month "borg-check-$BORG_REPO" borg check --remote-path borg1 --verbose;

}

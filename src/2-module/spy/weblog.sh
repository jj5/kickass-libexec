#!/bin/bash

lx_spy_weblog() {

  local sysid="$1";
  local system="$2";
  local host="$3";

  lx_ensure 1 'sysid' "$sysid";
  lx_ensure 2 'system' "$system";
  lx_ensure 3 'host' "$host";

  mkdir -p "$LX_SPY_DIR";

  cd "$LX_SPY_DIR";

  lx_spy_run lx_weblog_monitor "$sysid" "$system" "$host" access.log &
  lx_spy_run lx_weblog_monitor "$sysid" "$system" "$host" error.log &
  lx_spy_run lx_weblog_monitor "$sysid" "$system" "$host" other_vhosts_access.log &

}

lx_weblog_monitor() {

  local sysid="$1";
  local system="$2";
  local host="$3";
  local log="$4";

  lx_ensure 1 'sysid' "$sysid";
  lx_ensure 2 'system' "$system";
  lx_ensure 3 'host' "$host";
  lx_ensure 4 'log' "$log";

  lx_report "loading '$log' on '$host'...";

  local log_file="/var/log/apache2/$log";
  local out_file="$sysid: $system: $host: $log";

  touch "$out_file";

  while true; do

    lx_ssh "root@$host" test -f "$log_file" 2>/dev/null || {

      lx_warn "couldn't find log '$log_file' on host '$host'; sleeping for 5 minutes.";

      sleep 300;

      continue;

    };

    lx_ssh "root@$host" test -d / 2>/dev/null || {

      lx_warn "couldn't connect to host '$host'; sleeping for 5 minutes.";

      sleep 300;

      continue;

    };

    local timeout='timeout -k 61m 60m';
    local ssh="ssh root@$host tail -f $log_file";
    local cmd="$timeout $ssh";

    $cmd >> "$out_file";

    lx_warn "reloading '$log' on '$host'...";

    sleep 5;

  done

}

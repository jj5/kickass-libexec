#!/bin/bash

lx_spy_syslog() {

  local sysid="$1";
  local system="$2";
  local host="$3";

  lx_ensure 1 'sysid' "$sysid";
  lx_ensure 2 'system' "$system";
  lx_ensure 3 'host' "$host";

  mkdir -p /tmp/lx-spy;

  cd /tmp/lx-spy;

  lx_syslog_monitor "$sysid" "$system" "$host" &

}

lx_syslog_monitor() {

  local sysid="$1";
  local system="$2";
  local host="$3";

  lx_ensure 1 'sysid' "$sysid";
  lx_ensure 2 'system' "$system";
  lx_ensure 3 'host' "$host";

  lx_report "watching journal on '$host'...";

  local out_file="$sysid: $system: $host: journal";

  touch "$out_file";

  while true; do

    lx_ssh "root@$host" test -d / 2>/dev/null || {

      lx_warn "couldn't connect to host '$host'; sleeping for 5 minutes.";

      sleep 300;

      continue;

    };

    local timeout='timeout -k 61m 60m';
    local ssh="ssh root@$host stdbuf -oL journalctl -f";
    local cmd="$timeout $ssh";

    $cmd >> "$out_file";

    lx_warn "reloading syslog on '$host'...";

    sleep 5;

  done

}

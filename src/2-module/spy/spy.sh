#!/bin/bash

LX_SPY_DIR=/dev/shm/lx-spy;

source "$( dirname "${BASH_SOURCE[0]}" )/syslog.sh";
source "$( dirname "${BASH_SOURCE[0]}" )/weblog.sh";

lx_watch_logs() {

  mkdir -p "$LX_SPY_DIR";

  cd "$LX_SPY_DIR";

  sleep 5;

  tail -F * | "$LX_DIR_BIN/libexec/colorize-web-logs.sh";

}

lx_spy() {

  local host="$1";

  local sysid="$( lx_ssh "root@$host" cat /etc/staticmagic/sysid )";
  local system="$( lx_ssh "root@$host" cat /etc/staticmagic/system )";

  lx_note "spying on '$host'...";

  lx_spy_syslog "$sysid" "$system" "$host";
  lx_spy_weblog "$sysid" "$system" "$host";

}

lx_spy_run() {

  local monitor="$1";
  local sysid="$2";
  local system="$3";
  local host="$4";
  local log="${5:-}";

  lx_ensure 1 'monitor' "$monitor";
  lx_ensure 2 'sysid' "$sysid";
  lx_ensure 3 'system' "$system";
  lx_ensure 4 'host' "$host";
  # 2024-08-10 jj5 - $log is optional...

  mkdir -p "$LX_SPY_DIR";

  cd "$LX_SPY_DIR";

  $monitor "$sysid" "$system" "$host" "$log" &

  local pid=$!;

  lx_warn "$monitor('$host') started subprocess with PID $pid";

  while true; do

    if ps -p $pid > /dev/null; then

      # 2024-08-10 jj5 - NOTE: subprocess is still running, that's good.

      sleep 5;

      continue;

    fi

    lx_warn "$monitor('$host') subprocess $pid stopped, will restart.";

    $monitor "$sysid" "$system" "$host" "$log" &

    pid=$!;

    sleep 5;

  done;

}

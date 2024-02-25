#!/bin/bash

source "$( dirname "${BASH_SOURCE[0]}" )/syslog.sh";
source "$( dirname "${BASH_SOURCE[0]}" )/weblog.sh";

lx_watch_logs() {

  mkdir -p /tmp/lx-spy;

  cd /tmp/lx-spy;

  sleep 5;

  tail -F *;

}

lx_spy() {

  local host="$1";

  local sysid="$( lx_ssh "root@$host" cat /etc/staticmagic/sysid )";
  local system="$( lx_ssh "root@$host" cat /etc/staticmagic/system )";

  lx_spy_syslog "$sysid" "$system" "$host";
  lx_spy_weblog "$sysid" "$system" "$host";

}

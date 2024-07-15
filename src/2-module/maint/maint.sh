#!/bin/bash

lx_maint() {

  local svn_wc_list=(
    /home/jj5/bin
    /home/jj5/bin/private
  );

  for path in "${svn_wc_list[@]}"; do

    if [ -d "$path" ]; then

      lx_run sudo -u jj5 svn up "$path";

    fi;

  done;

  local git_wc_list=(
    /srv/libexec
    /srv/admin
    /srv/pillar
    /srv/salt
    /srv/netprov
    /srv/nv3
  );

  for path in "${git_wc_list[@]}"; do

    if [ -d "$path" ]; then

      lx_quiet pushd "$path";

      lx_note "running git pull in '$PWD'...";

      lx_run sudo git pull;

      lx_quiet popd;

    fi;

  done;

  lx_run sudo DEBIAN_FRONTEND=noninteractive apt update;

  lx_run sudo DEBIAN_FRONTEND=noninteractive apt -y dist-upgrade;

  lx_run sudo DEBIAN_FRONTEND=noninteractive apt -y autoremove;

  if command -v snap; then

    lx_run sudo snap refresh;

  fi

  if systemctl is-active --quiet zabbix-agent.service; then

    lx_note "zabbix agent still running, will disable."

    lx_run sudo systemctl disable zabbix-agent.service;

  fi

  if command -v salt-call; then

    # 2022-10-06 jj5 - if you're debugging try:
    # salt-call --state-output=mixed --state-verbose=False --log-file-level=all state.highstate
    # the log file is /var/log/salt/minion

    # 2022-11-28 jj5 - NOTE: some systems have broken salt config and are "snow flakes" until
    # I can manually replace/upgrade them...
    #
    if lx_is_snowflake; then

      lx_note "salt-call disabled as '$HOSTNAME' is a snow-flake.";

      if systemctl is-active --quiet salt-minion.service; then

        lx_note "disabling salt-minion...";

        lx_run sudo systemctl disable salt-minion

      fi

    else

      lx_run sudo salt-call --state-output=mixed --state-verbose=False state.highstate;

    fi

  fi;

  # 2024-03-04 jj5 - THINK: put this back in?
  #disk-usage.sh;

  if command -v zpool >/dev/null; then

    lx_run zpool list;

  fi;

  [ -f /var/run/reboot-required ] && {

    lx_note "reboot required";

    command -v at || {

      lx_note "installing required 'at' command.";
      
      sudo DEBIAN_FRONTEND=noninteractive apt install at;

    };

    lx_note "will reboot in 30 seconds...";

    echo "sleep 30; sudo shutdown -r now" | at now;

  }

  return 0;

}

lx_is_snowflake() {

  # 2024-03-04 jj5 - these are systems which we no longer manage with salt...

  local snowflake=(
    wit
    integrity
    platinum
    curiosity
    charm
    peace
    defiance
    jjdev
    studiousness
    avdev
    cldev
    fbdev
  );

  local host='';

  for host in "${snowflake[@]}"; do

    if [ "$HOSTNAME" = "$host" ]; then return 0; fi

  done;

  return 1;

}

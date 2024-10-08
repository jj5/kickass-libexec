#!/bin/bash

lx_maint() {

  local svn_wc_list=(
    /home/jj5/bin
    /home/jj5/bin/private
  );

  for path in "${svn_wc_list[@]}"; do

    if [ -d "$path" ]; then

      lx_quiet pushd "$path";

        [ -e .svn ] && {

          local user="$( ls -l -d . | awk '{ print $3 }' )";

          lx_note "running svn up in '$PWD' for user '$user'...";

          lx_run_as "$user" svn up;

        }

      lx_quiet popd;

    fi;

  done;

  local check_list=(
    /srv
  );

  for path in "${check_list[@]}"; do

    [ -d "$path" ] || continue;

    lx_quiet pushd "$path";

      for dir in *; do

        [ -d "$dir" ] || continue;

        lx_quiet pushd "$dir";

          if [ -e .git ]; then

            local user="$( ls -l -d . | awk '{ print $3 }' )";

            lx_note "running git pull in '$PWD' for user '$user'...";

            lx_run_as "$user" git pull --recurse-submodules;

          elif [ -e .svn ]; then

            local user="$( ls -l -d . | awk '{ print $3 }' )";

            lx_note "running svn up in '$PWD' for user '$user'...";

            lx_run_as "$user" svn up;

          fi;

        lx_quiet popd;

      done;

    lx_quiet popd;

  done;

  local web_list=(
    /var/www
  );

  for path in "${web_list[@]}"; do

    [ -d "$path" ] || continue;

    lx_quiet pushd "$path";

      for dir in *; do

        [ -d "$dir/.git" ] && lx_update_web "$PWD/$dir";

      done;

    lx_quiet popd;

  done;

  lx_run sudo DEBIAN_FRONTEND=noninteractive apt update;

  test -x /usr/sbin/needrestart || {

    lx_run sudo DEBIAN_FRONTEND=noninteractive apt -y install needrestart;

  }

  lx_run sudo DEBIAN_FRONTEND=noninteractive apt -y upgrade;

  lx_run sudo /usr/sbin/needrestart -r a;

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

  if [ -f /var/run/reboot-required ]; then

    lx_run lx_schedule_reboot;

  elif /usr/sbin/needrestart -b -r l | grep 'NEEDRESTART-SVC:'; then

    lx_run lx_schedule_reboot;

  fi

  return 0;

}

lx_schedule_reboot() {

  lx_note "reboot required";

  case "$HOSTNAME" in

    charisma)

      lx_note "will not automatically reboot this host '$HOSTNAME'.";

      return 0;;

  esac;

  command -v at || {

    lx_note "installing required 'at' command.";
    
    lx_run sudo DEBIAN_FRONTEND=noninteractive apt -y install at;

  };

  lx_note "will reboot in 30 seconds...";

  echo "sleep 30; sudo shutdown -r now" | at now;

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

lx_maint_run_if_online() {

  local host="$1";

  if lx_is_online "$host"; then

    lx_maint_run "$host";

  else

    lx_note "host '$host' is offline.";

  fi;

}

lx_maint_run() {

  local host="$1";

  local user="$( lx_ssh "$host" ls -l -d /srv/libexec | awk '{ print $3 }' )";

  if [ -z "$user" ]; then

    lx_fail "could not find /srv/libexec owner on host '$host'."

  fi;

  lx_run lx_ssh "$host" "cd /srv/libexec && sudo -u "$user" git pull";

  lx_run lx_ssh "$host" /srv/libexec/bin/lx-maint.sh;

  lx_run lx_ssh "$host" sudo /usr/sbin/needrestart -r l;

  lx_run lx_ssh "$host" sudo /usr/sbin/needrestart -b -r l;

  lx_note "maint has completed on '$host', will sleep for two minutes.";

  sleep 120;

}

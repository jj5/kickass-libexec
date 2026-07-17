#!/bin/bash

lx_maint() {

  lx_require user root;

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

  lx_maint_noninteractive apt update;

  test -x /usr/sbin/needrestart || {

    lx_maint_noninteractive apt -y install needrestart;

  }

  lx_maint_noninteractive apt -y upgrade;

  lx_run /usr/sbin/needrestart -r a;

  lx_maint_noninteractive apt -y autoremove;

  if command -v snap; then

    lx_run snap refresh;

  fi

  if systemctl is-active --quiet zabbix-agent.service; then

    lx_note "zabbix agent still running, will disable."

    lx_run systemctl disable zabbix-agent.service;

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

        lx_run systemctl disable salt-minion

      fi

    else

      lx_run salt-call --state-output=mixed --state-verbose=False state.highstate;

    fi

  fi;

  # 2024-03-04 jj5 - THINK: put this back in?
  #disk-usage.sh;

  if command -v zpool >/dev/null; then

    lx_run zpool list;

  fi;

  if [ -f /var/run/reboot-required ]; then

    lx_run lx_schedule_reboot;

    return 0;

  fi

  local status=$( needrestart -b );

  local kernel_status=$( awk '/^NEEDRESTART-KSTA:/ {print $2; exit}' <<<"$status" );
  local service_status=$( awk '/^NEEDRESTART-SVC:/ {print $2; exit}' <<<"$status" );

  local reboot_required=false
  local restart_services=false

  case "$kernel_status" in
    2|3)
      reboot_required=true
      ;;
    1)
      ;;
    0|"")
      lx_warn "warning: unable to determine kernel status."
      ;;
    *)
      lx_warn "warning: unknown kernel status: $kernel_status"
      ;;
  esac

  case "$service_status" in
    1)
      restart_services=true
      ;;
    0|"")
      ;;
    *)
      lx_warn "warning: unknown service status: $service_status"
      ;;
  esac

  if "$reboot_required"; then
    lx_note "a system reboot is required, scheduling reboot."
    lx_schedule_reboot;
    return 0;
  fi

  if "$restart_services"; then
    lx_note "one or more services should be restarted, scheduling reboot."
    lx_schedule_reboot;
    return 0;
  fi

  lx_note "system is up to date."

  return 0;

}

lx_schedule_reboot() {

  lx_note "reboot required";

  case "$HOSTNAME" in

    charisma)

      lx_notify "reboot required for '$HOSTNAME'.";

      return 0;;

  esac;

  command -v at || {

    lx_note "installing required 'at' command.";
    
    lx_maint_noninteractive apt -y install at;

  };

  lx_note "will reboot in 10 seconds...";

  echo "sleep 10; shutdown -r now" | at now;

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

  # 2026-07-17 jj5 - this gives any system that is rebooting from previous maint a chance to boot. this is particularly
  # important when that system is the LAN DNS server.
  #
  lx_note "maint is preparing to run on '$host', will sleep for a minute.";

  sleep 60;

  # 2026-07-17 jj5 - HACK! the computer 'truth' gets backed up after 'understanding' (at the moment, anyway), so we give
  # it some extra time because 'understanding' is the DNS server and we need that to resolve names...
  #
  if [ "$host" = 'truth' ]; then

    lx_note "maint is preparing to run on '$host', will sleep for an extra minute.";

    sleep 60;

  fi

  local user="$( lx_ssh "$host" ls -l -d /srv/libexec | awk '{ print $3 }' )";

  if [ -z "$user" ]; then

    lx_fail "could not find /srv/libexec owner on host '$host'."

  fi;

  lx_run lx_ssh "$host" "cd /srv/libexec && sudo -u "$user" git pull";

  lx_run lx_ssh "$host" /srv/libexec/bin/lx-maint.sh;

  # 2026-07-17 jj5 - OLD: the lx-maint.sh script (above) will reboot after 10 second delay
  #lx_run lx_ssh "$host" sudo /usr/sbin/needrestart -r l;
  #lx_run lx_ssh "$host" sudo /usr/sbin/needrestart -b -r l;

  # 2026-07-17 jj5 - OLD: this sleep wouldn't run if the previous command caused a reboot, so we do it in advance now
  # instead of at the end.
  #lx_note "maint has completed on '$host', will sleep for a minute.";
  #sleep 60;

}

lx_maint_noninteractive() {

  # 2026-07-17 jj5 - we route this through sudo because it can interpret the environment variable specification...

  lx_run sudo DEBIAN_FRONTEND=noninteractive "$@";

}

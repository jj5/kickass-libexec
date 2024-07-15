#!/bin/bash

lx_update_web() {

  local www_path="$1";

  lx_note "path is: $www_path";

  [ -d "$www_path" ] || lx_fail $LX_EXIT_WRONG_FILE "invalid path '$www_path'.";

  local archive_dir="$HOME/archive";

  [ -d "$archive_dir" ] || lx_fail $LX_EXIT_FILE_MISSING "missing archive directory '$archive_dir'.";

  local bin_dir="$LX_DIR_BIN";

  [ -d "$bin_dir" ] || lx_fail $LX_EXIT_FILE_MISSING "missing bin directory '$bin_dir'.";

  local app="$( basename "$www_path" )";
  local www_dir="$( dirname "$www_path" )";

  [ -d "$www_dir" ] || lx_fail $LX_EXIT_FILE_MISSING "missing www directory '$www_dir'.";

  [ "$www_dir" == '/var/www' ] || lx_fail $LX_EXIT_NOT_SUPPORTED "only /var/www is supported for now.";

  lx_note "updating '$app' in '$www_dir'.";

  local output_device=/dev/null;

  # 2024-07-06 jj5 - NOTE: you can use this for testing...
  #
  #local output_device=/dev/stdout;

  pushd "$www_dir" > "$output_device";

    local app_size="$( du -s "$app" | awk '{print $1}' )";
    local free_space="$( df --output=avail -B1 "$app" | tail -n1 )";
    local required_space=$(( app_size * 3 ));

    if [ "$free_space" -le "$required_space" ]; then

      lx_fail $LX_EXIT_EXHAUSTED "there is not enough disk space to conduct this operation.";

    fi;

    local timestamp="$( lx_timestamp )";

    while true; do

      if [[
        -e "$www_dir/$timestamp" ||
        -e "$archive_dir/$timestamp"
      ]]; then

        lx_note "timestamp '$timestamp' is in use, will generate a new one.";

        timestamp="$( lx_timestamp )";

        sleep 1;

      else

        break;

      fi;

    done;

    lx_note "timestamp is: $timestamp";

    local tarball="$LX_WORKSPACE/$app.tar";

    lx_run tar cf "$tarball" "$app";

    lx_run mkdir "$timestamp";

    pushd "$timestamp" > "$output_device";

      cat <<EOF > archive-note.txt
Arch: $archive_dir/$timestamp
Date: `date`
User: $USER
Host: `hostname -f`
Path: $www_dir
File: $app
Type: remove
Mode: lx-update-web
EOF

      lx_run tar xf "$tarball";

      pushd "$app" > "$output_device";

        #lx_run "$bin_dir/lx-gui.sh";

        local user="$( ls -l -d . | awk '{ print $3 }' )";

        lx_note "running git pull in '$PWD' as user '$user'...";

        lx_run_as "$user" git pull --recurse-submodules

        # 2024-07-07 jj5 - OLD: don't do this here in this script
        #lx_run git submodule update --remote;

      popd > "$output_device";

      lx_run mkdir "backup";

      lx_run mv "../$app" "backup/";

      lx_run mv "$app" "../";

    popd > "$output_device";

    lx_run mv "$timestamp" "$archive_dir/";

  popd > "$output_device";

  lx_try sudo apache2ctl graceful;

}

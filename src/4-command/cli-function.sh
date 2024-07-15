#!/bin/bash

cd() {

  builtin pushd "$@" >/dev/null;

}

p() {

  builtin popd >/dev/null;

}

sudo() {

  /usr/bin/sudo "$@"

  local error="$?"

  # 2024-03-04 jj5 - set the window title back to the previous user

  echo -ne "\033]2;$USER@$HOSTNAME\007" >&2

  return "$error";

}

ssh() {

  /usr/bin/ssh "$@"

  local error="$?"

  # 2024-03-04 jj5 - set the window title back to the localhost

  echo -ne "\033]2;$USER@$HOSTNAME\007" >&2

  return "$error";

}

gui() {

  #"$LX_DIR_BIN/lx-gui.sh" "$@" || return $?;

  time "$LX_DIR_BIN/lx-gui.sh" "$@";

  local error="$?"

  return "$error";

}

maint() {

  if [ -d /srv/libexec ]; then

    pushd /srv/libexec 2>/dev/null;

    sudo git pull;

    popd 2>/dev/null;

  else

    sudo git clone https://github.com/jj5/kickass-libexec /srv/libexec;

  fi;

  "$LX_DIR_BIN/lx-maint.sh" "$@";

}

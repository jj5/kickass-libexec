#!/bin/bash

cd() {

  builtin pushd "$@" >/dev/null;

}

p() {

  builtin popd >/dev/null;

}

sudo() {

  /usr/bin/sudo "$@"

  # 2024-03-04 jj5 - set the window title back to the previous user

  echo -ne "\033]2;$USER@$HOSTNAME\007" >&2

}

ssh() {

  /usr/bin/ssh "$@"

  # 2024-03-04 jj5 - set the window title back to the localhost

  echo -ne "\033]2;$USER@$HOSTNAME\007" >&2

}

gui() {

  "$LX_DIR_BIN/lx-gui.sh" "$@" || return $?;

}

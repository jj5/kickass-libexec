#!/bin/bash

lx_ssh() {

  # 2024-02-18 jj5 - this thin wrapper around ssh is here to make sure we avoid any user-defined ssh function.

  [ -x /usr/bin/ssh ] || lx_fail "missing /usr/bin/ssh";

  /usr/bin/ssh "$@";

}

lx_test() {

  builtin test "$@";

}

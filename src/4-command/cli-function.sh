#!/bin/bash

cd() {

  builtin pushd "$@" >/dev/null;

}

p() {

  builtin popd >/dev/null;

}

s() {

  sudo -s "$@"

  # 2024-03-04 jj5 - set the window title back to the localhost

  echo -ne "\033]2;$USER@$HOSTNAME\007" >&2

}

ssh() {

  /usr/bin/ssh "$@"

  # 2024-03-04 jj5 - set the window title back to the localhost

  echo -ne "\033]2;$USER@$HOSTNAME\007" >&2

}

gui() {

  local dirs=( "$@" );

  if [ "${#dirs[@]}" == '0' ]; then

    dirs+=( '.' );

  fi;

  for dir in "${dirs[@]}"; do

    if [ ! -d "$dir" ]; then

      continue;

    fi;

    pushd "$dir" >/dev/null;

    echo -e "$WHITE$PWD:$END";

    if [ -d .git ]; then

      if git status >/dev/null 2>&1; then

        git pull && \
        git add . && \
        git commit -m "Work, work..." && \
        git push && \
        git status;

      else

        # 2019-06-25 jj5 - run git status again so it can output its error msg
        #
        git status;

      fi;

    elif [ -d .svn ]; then

      svn status && svnman sync

    fi;

    echo;

    popd >/dev/null;

  done;

}

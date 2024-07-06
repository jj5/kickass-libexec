#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-gui.lock';

main() {

  local dirs=( "$@" );

  if [ "${#dirs[@]}" == '0' ]; then

    dirs+=( '.' );

  fi;

  for dir in "${dirs[@]}"; do

    if [ ! -d "$dir" ]; then

      continue;

    fi;

    pushd "$dir" >/dev/null;

    #echo -e "$LX_WHITE$PWD:$LX_END";

    # 2024-05-22 jj5 - NOTE: the .git file can be a file (for submodules) or a directory
    #
    if [ -e .git ]; then

      lx_note "processing git: $PWD";

      #git status || true;

      for submodule in $( git submodule | awk '{ print $2 }' ); do

        lx_note "updating submodule: $submodule";

        main $submodule;

      done;

      lx_run git pull --recurse-submodules

      lx_run git add .

      if lx_try git commit -m "Work, work..."; then

        lx_run git push;

      fi;

      #lx_run git submodule update --remote;

      lx_run git status;

      lx_note "done";

    elif [ -d .svn ]; then

      lx_note "processing svn: $PWD";

      lx_run svn status
      lx_run svnman sync

    else

      lx_fail "no version control found.";

    fi;

    echo;

    popd >/dev/null;

  done;

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

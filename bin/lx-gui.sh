#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-gui.lock';

main() {

  echo "temp note";

  local dirs=( "$@" );

  if [ "${#dirs[@]}" == '0' ]; then

    dirs+=( '.' );

  fi;

  for dir in "${dirs[@]}"; do

    if [ ! -d "$dir" ]; then

      continue;

    fi;

    pushd "$dir" >/dev/null;

    echo -e "$LX_WHITE$PWD:$LX_END";

    if [ -d .git ]; then

      if git status >/dev/null 2>&1; then

        git pull    || { echo "git pull failed with error level '$?'."; popd; return 1; }
        git add .   || { echo "git add failed with error level '$?'."; popd; return 1; }
        git commit -m "Work, work..."
        git push    || { echo "git push failed with error level '$?'."; popd; return 1; }
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

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

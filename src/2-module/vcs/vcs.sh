#!/bin/bash

lx_vcs_sync() {

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

        #lx_vcs_sync_git;

      elif [ -d .svn ]; then

        lx_vcs_sync_svn;

      else

        lx_warn "no version control found.";

      fi;

      echo;

    popd >/dev/null;

  done;

}

lx_vcs_sync_svn() {

  local user="$( ls -l -d . | awk '{ print $3 }' )";

  lx_note "processing svn dir '$PWD' as user '$user'...";

  lx_run_as "$user" svn status

  # 2024-07-16 jj5 - NEW: use full path to this...
  lx_run_as "$user" /home/jj5/bin/svnman sync
  # 2024-07-16 jj5 - OLD:
  #lx_run svnman sync

}

lx_vcs_sync_git() {

  # 2024-07-06 jj5 - SEE: https://chatgpt.com/share/0c74a5e2-8d64-48e3-a050-75550d04fa74
  # 2024-07-07 jj5 - SEE: https://chatgpt.com/share/272b8a2d-48ca-4528-a182-2f82c470fd87

  lx_note "processing git: $PWD";

  #lx_run git submodule update --remote;

  lx_note "running git pull in '$PWD'...";

  lx_run git pull --recurse-submodules;

  for submodule in $( git submodule | awk '{ print $2 }' ); do

    lx_note "updating submodule: $submodule";

    pushd "$submodule" >/dev/null;

      # 2024-07-07 jj5 - NEW: maybe this will work...
      #lx_run git pull remote main;
      # 2024-07-07 jj5 - OLD: we might have a problem if there are recursive submodules? there aren't at the moment.
      #lx_run git pull --recurse-submodules
      #lx_run git submodule update --remote;

      lx_run git add .;

      if lx_try git commit -m "Work, work..."; then

        lx_run git push origin main;

        # 2024-07-07 jj5 - NEW:
        lx_run lx-version-increment-patch.sh;
        # 2024-07-07 jj5 - OLD:
        #if [ -x bin/dev/version-increment-patch.sh ]; then
        #  lx_run bin/dev/version-increment-patch.sh;
        #fi;

        lx_run git add .

        lx_try git commit -m "Work, work..." || true;

        lx_run git push origin main;

      fi;

    popd;

  done;

  for submodule in $( git submodule | awk '{ print $2 }' ); do

    lx_run git add $submodule;

  done;

  lx_run git add .

  if lx_try git commit -m "Work, work..."; then

    lx_run git push;

    # 2024-07-07 jj5 - NEW:
    lx_run lx-version-increment-patch.sh;
    # 2024-07-07 jj5 - OLD:
    #if [ -x bin/dev/version-increment-patch.sh ]; then
    #  lx_run bin/dev/version-increment-patch.sh;
    #fi;

    lx_run git add .

    lx_try git commit -m "Work, work..." || true;

    lx_run git push;

  fi;

  lx_note "running git pull in '$PWD'...";

  lx_run git pull --recurse-submodules;

  #lx_run git submodule update --remote;

  lx_run git status;

  lx_note "done: $PWD";

}

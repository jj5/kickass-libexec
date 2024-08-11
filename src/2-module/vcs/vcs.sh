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

      lx_note "updating '$dir'...";

      #echo -e "$LX_WHITE$PWD:$LX_END";

      # 2024-05-22 jj5 - NOTE: the .git file can be a file (for submodules) or a directory
      #
      if [ -e .git ]; then

        lx_vcs_sync_git;

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

  local user="$( ls -l -d . | awk '{ print $3 }' )";

  lx_note "processing git dir '$PWD' as user '$user'...";

  lx_try_as "$user" git submodule update --init --recursive || true;

  lx_run_as "$user" git pull --recurse-submodules || true;

  for submodule in $( sudo -u "$user" git submodule | awk '{ print $2 }' ); do

    lx_note "updating git submodule: $submodule";

    pushd "$submodule" >/dev/null;

      if false; then

        # 2024-08-07 jj5 - get the remote URL...
        #
        local remote_url=$( git remote get-url origin );

        # 2024-08-07 jj5 - extract the bit we're interested in using awk. This isn't always the remote hostname, but it
        # will be for git.overlead.com which is our only use case at the moment.
        #
        local remote_host=$( echo "$remote_url" | awk -F'[@:/]' '{print $(NF-1)}' );

        local branch="main";

        # 2024-08-07 jj5 - HACK! I am sure there is a better way to do this...
        #
        case "$remote_host" in
          git.overleaf.com)
            branch="master";;
        esac

        lx_run_as "$user" git add .;

        if lx_try_as "$user" git commit -m "Work, work..."; then

          lx_run_as "$user" git push origin $branch;

          lx_run_as "$user" "$LX_SCRIPT_DIR/lx-version-increment-patch.sh";

          lx_run_as "$user" git add .

          lx_run_as "$user" git commit -m "Work, work...";

          lx_run_as "$user" git push origin $branch;

        fi;

      fi;

      lx_vcs_sync_git;

    popd;

  done;

  for submodule in $( sudo -u "$user" git submodule | awk '{ print $2 }' ); do

    lx_run_as "$user" git add $submodule;

  done;

  lx_run_as "$user" git add .

  if lx_try_as "$user" git commit -m "Work, work..."; then

    lx_run_as "$user" git push;

    lx_run_as "$user" "$LX_SCRIPT_DIR/lx-version-increment-patch.sh";

    lx_run_as "$user" git add .

    lx_run_as "$user" git commit -m "Work, work...";

    lx_run_as "$user" git push;

  fi;

  lx_note "running git pull in '$PWD'...";

  lx_try_as "$user" git pull --recurse-submodules || true;

  lx_note "running git push in '$PWD'...";

  lx_run_as "$user" git push;

  lx_run_as "$user" git status;

}

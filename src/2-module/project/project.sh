#!/bin/bash

source "$( dirname "${BASH_SOURCE[0]}" )/mudball.sh";

lx_new_project() {

  local vcs="${1:-}";
  local server="${2:-}";
  local project="${3:-}";

  lx_ensure 1 'vcs' "$vcs";
  lx_ensure 2 'server' "$server";
  lx_ensure 3 'project' "$project";

  [ -z "${LX_VCS_USER:-}" ] && {

    LX_VCS_USER="$USER";

  };

  case "$vcs" in
    git)
      lx_new_project_git "$server" "$project";
      ;;
    *)
      lx_fail "VCS not supported: $vcs";
      ;;
  esac

}

lx_new_project_git() {

  local server="${1:-}";
  local project="${2:-}";

  lx_ensure 1 'server' "$server";
  lx_ensure 2 'project' "$project";

  case "$server" in
    github)
      LX_VCS_DIR="$HOME/repo/git/github/$LX_VCS_USER";
      lx_new_project_git_github "$project";
      ;;
    *)
      lx_fail "server not supported: $vcs";
      ;;
  esac

}

lx_new_project_git_github() {

  local project="${1:-}";

  lx_ensure 1 'project' "$project";

  lx_check_and_install_package gh;

  lx_note "LX_VCS_DIR: $LX_VCS_DIR";

  [ -d "$LX_VCS_DIR" ] || { lx_fail "directory '$LX_VCS_DIR' does not exist."; }

  lx_run gh auth status || {

    lx_run gh auth login;

  };

  pushd "$LX_VCS_DIR" >/dev/null;

    [ -d "$project" ] && { lx_fail "directory '$project' already exists."; }

    lx_run mkdir "$project";

    pushd "$project" >/dev/null;

      lx_run gh repo create "$project" --public;

      lx_run git init;
      lx_run git remote add origin "git@github.com:$LX_VCS_USER/$project.git";
      lx_run git branch -M main;

      cat <<EOF > README.md
# $project

Project created on $( date ) by $LX_VCS_USER.

EOF

      lx_run git add README.md;
      lx_run git commit -m 'Work, work...';
      lx_run git push --set-upstream origin main;

      lx_new_project_git_mudball "$project";

      lx_run git pull --recurse-submodules;

      lx_note "project '$project' created in: $PWD";

      echo $PWD;

    popd >/dev/null;

  popd >/dev/null;

}

lx_new_project_git_mudball() {

  local project="${1:-}";

  lx_ensure 1 'project' "$project";

  export LX_DATE_USER="$( date +"%Y-%m-%d" ) $LX_VCS_USER";

  lx_run mkdir -p 'ext';
  lx_run git submodule add git@github.com:jj5/mudball.git ext/mudball;
  lx_run git commit -m "Work, work...";
  lx_run git push origin main;

  lx_gen_mudball "$project";
  lx_run git add .;
  lx_run git commit -m "Work, work...";
  lx_run git push origin main;

}

#!/bin/bash

source "$( dirname "${BASH_SOURCE[0]}" )/config/standard.sh";
source "$( dirname "${BASH_SOURCE[0]}" )/config/mudball.sh";

lx_new_project() {

  local vcs="${1:-}";
  local server="${2:-}";
  local project="${3:-}";
  local version="${4:-}";
  local mudball="${5:-1}";

  lx_ensure 1 'vcs' "$vcs";
  lx_ensure 2 'server' "$server";
  lx_ensure 3 'project' "$project";
  lx_ensure 4 'version' "$version";
  lx_ensure 5 'mudball' "$mudball";

  [ -z "${LX_VCS_USER:-}" ] && {

    export LX_VCS_USER="$USER";

  };

  export LX_DATE_USER="$( date +"%Y-%m-%d" ) $LX_VCS_USER";

  case "$vcs" in
    git)
      lx_new_project_git "$server" "$project" "$version" "$mudball";
      ;;
    *)
      lx_fail "VCS not supported: $vcs";
      ;;
  esac

}

lx_new_project_git() {

  local server="${1:-}";
  local project="${2:-}";
  local version="${3:-}";
  local mudball="${4:-1}";

  lx_ensure 1 'server' "$server";
  lx_ensure 2 'project' "$project";
  lx_ensure 3 'version' "$version";
  lx_ensure 4 'mudball' "$mudball";

  case "$server" in
    github)
      LX_VCS_DIR="$HOME/repo/git/github/$LX_VCS_USER";
      lx_new_project_git_github "$project" "$version" "$mudball";
      ;;
    *)
      lx_fail "server not supported: $vcs";
      ;;
  esac

}

lx_new_project_git_github() {

  local project="${1:-}";
  local version="${2:-}";
  local mudball="${3:-1}";

  lx_ensure 1 'project' "$project";
  lx_ensure 2 'version' "$version";
  lx_ensure 3 'mudball' "$mudball";

  lx_check_and_install_package gh;

  lx_note "LX_VCS_DIR: $LX_VCS_DIR";

  [ -d "$LX_VCS_DIR" ] || { lx_fail "directory '$LX_VCS_DIR' does not exist."; }

  lx_run gh auth status || {

    lx_run gh auth login;

  };

  pushd "$LX_VCS_DIR" >/dev/null;

    local project_dir="$project-$version";

    [ -d "$project_dir" ] && { lx_fail "directory '$project_dir' already exists."; }

    lx_run mkdir "$project_dir";

    pushd "$project_dir" >/dev/null;

      lx_run gh repo create "$project-$version" --public;

      lx_run git init;
      lx_run git remote add origin "git@github.com:$LX_VCS_USER/$project-$version.git";
      lx_run git branch -M main;

      cat <<EOF > README.md
# $project v$version

Project created on $( date ) by $LX_VCS_USER.

EOF

      lx_run git add README.md;
      lx_run git commit -m 'Work, work...';
      lx_run git push --set-upstream origin main;

      lx_new_project_git_standard "$project" "$version";

      [ "$mudball" = 0 ] || {

        lx_new_project_git_mudball "$project" "$version";

      };

      lx_run git pull --recurse-submodules;

      lx_note "project '$project' created in: $PWD";

      echo $PWD;

    popd >/dev/null;

  popd >/dev/null;

}

lx_new_project_git_standard() {

  local project="${1:-}";
  local version="${2:-}";

  lx_ensure 1 'project' "$project";
  lx_ensure 2 'version' "$version";

  lx_gen_standard "$project" "$version";

  lx_run git add .;
  lx_run git commit -m "Work, work...";
  lx_run git push origin main;

}


lx_new_project_git_mudball() {

  local project="${1:-}";
  local version="${2:-}";

  lx_ensure 1 'project' "$project";
  lx_ensure 2 'version' "$version";

  lx_run mkdir -p 'ext';
  lx_run git submodule add git@github.com:jj5/mudball-$LX_MUDBALL_VERSION.git ext/mudball-$LX_MUDBALL_VERSION;
  lx_run git commit -m "Work, work...";
  lx_run git push origin main;

  lx_gen_mudball "$project" "$version";

  lx_run git add .;
  lx_run git commit -m "Work, work...";
  lx_run git push origin main;

}

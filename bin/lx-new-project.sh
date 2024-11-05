#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-project.lock';

main() {

  local vcs="${1:-}";
  local server="${2:-}";
  local project="${3:-}";
  local version="${4:-}";

  lx_ensure 1 'vcs' "$vcs";
  lx_ensure 2 'server' "$server";
  lx_ensure 3 'project' "$project";
  lx_ensure 4 'version' "$version";

  shift 4;

  # 2024-11-05 jj5 - by default we use mudball, except if it's the mudball project itself. This can be overridden with
  # --mudball or --no-mudball.

  local mudball=1;

  case "$project" in
    mudball)
      mudball=0;
      ;;
    *)
      ;;
  esac

  while [ $# -gt 0 ]; do

    local arg="$1";

    shift;

    case "$arg" in
      --mudball)
        mudball=1;
        ;;
      --no-mudball)
        mudball=0;
        ;;
      *)
        lx_fail "Unknown argument: $arg";
        ;;
    esac

  done

  [ -z "${LX_VCS_USER:-}" ] && {

    LX_VCS_USER="$USER";

  };

  lx_new_project "$vcs" "$server" "$project" "$version" "$mudball";

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

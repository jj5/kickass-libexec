#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-project.lock';

main() {

  export LX_VCS_USER="${LX_VCS_USER:-$USER}";

  local project_dir="$( basename "$( pwd )" )";

  local project="${project_dir%-*}";
  local version="${project_dir##*-}";

  echo lx_gen_standard "$project" "$version";

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-project.lock';

main() {

  export LX_VCS_USER="${LX_VCS_USER:-$USER}";

  local project_dir="$( basename "$( pwd )" )";

  local project="${project_dir%-*}";
  local version="${project_dir##*-}";

  local version_major="${version%.*}";
  local version_minor="${version##*.}";

  echo "project: $project";
  echo "version: $version";
  echo "version_major: $version_major";
  echo "version_minor: $version_minor";

  lx_gen_mudball "$project" "$version";

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

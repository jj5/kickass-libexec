#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-project.lock';

main() {

  export LX_VCS_USER="${LX_VCS_USER:-$USER}";

  local project_dir="$( basename "$( pwd )" )";

  IFS='-' read -ra project_parts <<< "$project_dir";

  local project="${project_parts[0]}";
  local version="${project_parts[1]}";

  IFS='.' read -ra version_parts <<< "$version";

  local version_major="${version_parts[0]}";
  local version_minor="${version_parts[1]}";

  lx_gen_mudball "$project" "$version";

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

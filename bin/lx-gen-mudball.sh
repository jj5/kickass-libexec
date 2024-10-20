#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-project.lock';

main() {

  export LX_VCS_USER="${LX_VCS_USER:-$USER}";

  local project_name="$( basename "$( pwd )" )";

  lx_gen_mudball "$project_name";

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

#!/bin/bash

lx_gen_standard() {

  local project="${1:-}";
  local version="${2:-}";

  lx_ensure 1 'project' "$project";
  lx_ensure 2 'version' "$version";

  lx_run lx_gen_standard_gitignore;

}

lx_gen_standard_gitignore() {

  cat <<EOF > .gitignore
vendor
config.php
debug.php
.vscode
EOF

}

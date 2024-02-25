#!/bin/bash

# 2024-02-18 jj5 - this is a framework for running bash scripts. Declare main() then source this include.

source "$( dirname "${BASH_SOURCE[0]}" )/lib.sh";

[ -d "$LX_DIR_INC" ] || { echo "error: LX_DIR_INC not found: $LX_DIR_INC"; exit 40; }
[ -d "$LX_DIR_BIN" ] || { echo "error: LX_DIR_BIN not found: $LX_DIR_BIN"; exit 40; }
[ -d "$LX_DIR_SRC" ] || { echo "error: LX_DIR_SRC not found: $LX_DIR_SRC"; exit 40; }

source "$LX_DIR_SRC/3-framework/framework.sh";

lx_bootstrap "$0" "$@"; exit 82;

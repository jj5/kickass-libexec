#!/bin/bash

# 2024-02-18 jj5 - source this file from your bashrc script to get the interactive environment.

LX_DIR_INC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && realpath . )";
LX_DIR_BIN="$( realpath "$LX_DIR_INC/../bin" )";
LX_DIR_SRC="$( realpath "$LX_DIR_INC/../src" )";

[ -d "$LX_DIR_INC" ] || { echo "error: LX_DIR_INC not found: $LX_DIR_INC"; exit 40; }
[ -d "$LX_DIR_BIN" ] || { echo "error: LX_DIR_BIN not found: $LX_DIR_BIN"; exit 40; }
[ -d "$LX_DIR_SRC" ] || { echo "error: LX_DIR_SRC not found: $LX_DIR_SRC"; exit 40; }

source "$LX_DIR_INC/lib.sh";
source "$LX_DIR_SRC/4-command/cli-function.sh";
source "$LX_DIR_SRC/4-command/cli-alias.sh";

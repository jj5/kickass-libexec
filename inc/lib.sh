#!/bin/bash

# 2024-02-18 jj5 - this is the include file for the library/toolkit functions.

echo '1...'

LX_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && realpath . )";
LX_DIR_BIN="$LX_DIR/bin";
LX_DIR_ETC="$LX_DIR/etc";
LX_DIR_INC="$LX_DIR/inc";
LX_DIR_SRC="$LX_DIR/src";

echo '2...'

[ -d "$LX_DIR_BIN" ] || { echo "error: LX_DIR_BIN not found: $LX_DIR_BIN"; exit 40; }
[ -d "$LX_DIR_ETC" ] || { echo "error: LX_DIR_ETC not found: $LX_DIR_ETC"; exit 40; }
[ -d "$LX_DIR_INC" ] || { echo "error: LX_DIR_INC not found: $LX_DIR_INC"; exit 40; }
[ -d "$LX_DIR_SRC" ] || { echo "error: LX_DIR_SRC not found: $LX_DIR_SRC"; exit 40; }

echo '3...'

source "$LX_DIR_SRC/1-toolkit/const/color.sh";

echo '4...'

source "$LX_DIR_SRC/1-toolkit/const/error.sh";

echo '5...'

source "$LX_DIR_SRC/1-toolkit/env.sh";

echo '6...'

source "$LX_DIR_SRC/1-toolkit/toolkit.sh";

echo '7...'

lx_load_modules;

echo '8...'

source "$LX_DIR_ETC/env.sh";

echo '9...'

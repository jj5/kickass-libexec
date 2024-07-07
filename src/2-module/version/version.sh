#!/bin/bash

lx_version_increment_patch() {

  lx_run php "$LX_DIR_BIN/libexec/version-increment-patch.php" "$@";

}

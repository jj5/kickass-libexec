#!/bin/bash

if [ -z "$LX_DEFAULT_USER" ]; then

  LX_DEFAULT_USER=jj5;

fi;

if [ -z "$LX_DEFAULT_GROUP" ]; then

  if [ "$( uname )" == "Darwin" ]; then

    LX_DEFAULT_GROUP=staff;

  else

    LX_DEFAULT_GROUP=jj5;

  fi;

fi;

if [ -z "$LX_ERROR_EMAIL" ]; then

  LX_ERROR_EMAIL="jj5@jj5.net";

fi;

LX_STD_DEBUG=0;
LX_STD_DEBUG_OVERRIDE=0;
LX_STD_MAIL=1;
LX_STD_MAIL_OVERRIDE=0;
LX_STD_STATUS=1;
LX_STD_STATUS_OVERRIDE=0;
LX_STD_INTERACTIVE=1;
LX_STD_INTERACTIVE_OVERRIDE=0;
LX_STD_QUICK=0;
LX_STD_QUICK_OVERRIDE=0;
LX_STD_DELAY=10;

LX_STD_TEMPLIST=();

LX_STD_INFAIL=0;
LX_STD_INNEED=0;

if [ -z "$LX_ARCHIVE_DIR" ]; then

  LX_ARCHIVE_DIR="$HOME/archive";

fi;

if [ -z "$LX_LOCK_FILE" ]; then

  LX_LOCK_FILE="/var/lock/lx.lock";

fi;

if [ -z "$LX_ZFS_DATA_HOST" ]; then

  case "$( hostname )" in

    commitment)
      LX_ZFS_DATA_HOST='data/secure/host';
      ;;

    charisma)
      LX_ZFS_DATA_HOST='data/temp/host';
      ;;

    *)
      LX_ZFS_DATA_HOST='data/host';
      ;;

  esac;

fi;

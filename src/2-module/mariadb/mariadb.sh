#!/bin/bash

lx_get_db_name() {

  local result=$( lx_get_db_string '__' "$@" );

  result="${result//\//__}";

  echo "$result";

}

lx_get_db_path() {

  local result=$( lx_get_db_string '/' "$@" );

  result="${result//__/\/}";

  # 2017-12-04 jj5 - it probably would have been better to do this, but we've
  # got too much legacy shit in the old format at this point to change...
  #result="${result//_/-}";

  echo "$result";

}

lx_get_db_string() {

  local separator="$1"; shift;

  local result='';

  while (( "$#" )); do

    [ -z "${result:-}" ] || result="${result}${separator}";

    local part=$( lx_get_db_part "$1" "$result" );

    shift;

    result="${result}${part}";

  done;

  echo "$result";

}

lx_get_db_part() {

  local input="$1";
  local result="$2";

  local part="${input//-/_}";

  # 2020-06-10 jj5 - this was reimplemented not to use ';&' fallthrough syntax because that is not
  # supported on bash (v3.2.57) on Mac OS X, and we do run this script on that platform...
  #
  case "$part" in

    test)   part='dbt';;

    prod)   part='dbp';;

    global) part='dbg';;
    home)   part='dbg';;
    vbox)   part='dbg';;
    ware)   part='dbg';;
    temp)   part='dbg';;
    gen1)   part='dbg';;

  esac;

  echo "$part";

}

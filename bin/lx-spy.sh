#!/bin/bash

LX_LOCK_FILE='/var/lock/lx-spy.lock';

main() {

  local default_list=(
    desire
    understanding
    truth
    benevolence
    sincerity
    trust
    loyalty
    bravery
    fortitude
    cooperation
    forbearance
    idealism
    wit
    grace
    generosity
    integrity
    curiosity
  );

  local host_list=();

  if [ $# -eq 0 ]; then
  
    host_list+=( "${default_list[@]}" );
    
  else
  
    host_list+=( "$@" );
    
  fi

  for host in "${host_list[@]}"; do

    lx_spy "$host";

  done;

  lx_watch_logs;

}

source "$( dirname "${BASH_SOURCE[0]}" )/../inc/run.sh";

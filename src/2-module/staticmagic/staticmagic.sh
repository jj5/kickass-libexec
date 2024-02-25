#!/bin/bash

sm_is_temp_env() {

  sm_is_env temp;

}

sm_is_test_env() {

  sm_is_env test;

}

sm_is_prod_env() {

  sm_is_env prod;

}

sm_is_env() {

  local check="$1";

  # 2017-08-02 jj5 - WARNING: not all environments are currenly supported here
  ensure 1 'check' "$check" temp test prod;

  [ "$( sm_get_env )" == "$check" ] && return 0;

  return 1;

}

sm_get_host() {

  sm_get_var host;

}

sm_get_host_test() {

  sm_get_var host-test;

}

sm_get_host_prod() {

  sm_get_var host-prod;

}

sm_get_environment() {

  sm_get_var environment;

}

sm_get_env() {

  sm_get_var environment;

}

# 2017-08-26 jj5 - should be 'prod' or 'test'...
sm_get_netenv() {

  sm_get_var netenv;

}

sm_get_system() {

  sm_get_var system;

}

sm_get_domain() {

  sm_get_var domain;

}

sm_get_fqdn() {

  sm_get_var fqdn;

}

sm_get_sysid() {

  sm_get_var sysid;

}

sm_get_realm() {

  sm_get_var realm;

}

sm_get_class() {

  sm_get_var class;

}

sm_get_typenum() {

  sm_get_var typenum;

}

sm_get_instance_type() {

  sm_get_var instance-type;

}

sm_get_root_volume_type() {

  sm_get_var root-volume-type;

}

sm_get_root_volume_size() {

  sm_get_var root-volume-size;

}

# 2017-08-26 jj5 - 'role' is an alias for 'salt' for legacy reasons...
sm_get_role() {

  sm_get_salt;

}

# 2017-08-26 jj5 - returns 'master', 'minion', or 'snowflake'...
sm_get_salt() {

  sm_get_var salt;

}

sm_get_created() {

  sm_get_var created;

}

sm_get_created_iso() {

  sm_get_var created-iso;

}

sm_get_created_iso_utc() {

  sm_get_var created-iso-utc;

}

sm_get_created_timestamp() {

  sm_get_var created-timestamp;

}

sm_get_var() {

  local variable="$1";

  echo "$( cat /etc/staticmagic/$variable 2>/dev/null )";

}

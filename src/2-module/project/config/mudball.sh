#!/bin/bash

export LX_MUDBALL_VERSION="${LX_MUDBALL_VERSION:-0.6}";

lx_gen_mudball() {

  local project="${1:-}";
  local version="${2:-}";

  lx_ensure 1 'project' "$project";
  lx_ensure 2 'version' "$version";

  local uppercase_project="${project^^}";

  local version_major="${version%.*}";
  local version_minor="${version##*.}";

  export LX_PROJECT_CODE="${uppercase_project//-/_}";

  [ -d "ext/mudball-$LX_MUDBALL_VERSION" ] || {

    # 2024-10-21 jj5 - NOTE: we have this check just to be sure that we're in the correct directory...

    lx_fail 'mudball framework not found...';

  };

  lx_run lx_gen_standard "$project" "$version";

  lx_run mkdir -p 'bin';
  lx_run mkdir -p 'dat';
  lx_run mkdir -p 'etc';
  lx_run mkdir -p 'inc';
  lx_run mkdir -p 'run';
  lx_run mkdir -p 'src/code/1-bootstrap';
  lx_run mkdir -p 'src/code/3-lookup/enum';
  lx_run mkdir -p 'src/code/3-lookup/flags';
  lx_run mkdir -p 'src/code/5-module';
  lx_run mkdir -p 'src/code/6-schema';
  lx_run mkdir -p 'src/gen';
  lx_run mkdir -p 'web/res';
  lx_run mkdir -p 'web/root';

  lx_run lx_gen_mudball_inc_framework_php;

  lx_run lx_gen_mudball_run_cli_php;
  lx_run lx_gen_mudball_run_web_php;

  lx_run lx_gen_mudball_src_code_bootstrap_library;
  lx_run lx_gen_mudball_src_code_bootstrap_constant;
  lx_run lx_gen_mudball_src_code_bootstrap_enum;
  lx_run lx_gen_mudball_src_code_bootstrap_flags;
  lx_run lx_gen_mudball_src_code_bootstrap_config;
  lx_run lx_gen_mudball_src_code_bootstrap_module;
  lx_run lx_gen_mudball_src_code_bootstrap_keystone;

}

lx_gen_mudball_inc_framework_php() {

  local file='inc/framework.php';

  [ -f "$file" ] && { return; }

  cat <<EOF > $file
<?php

require_once __DIR__ . '/../src/code/1-bootstrap/9-keystone.php';

EOF

}

lx_gen_mudball_run_cli_php() {

  local file='run/run-cli.php';

  [ -f "$file" ] && { return; }

  cat <<EOF > $file
<?php

require_once __DIR__ . '/../ext/mudball/run/run-cli.php';

EOF

}

lx_gen_mudball_run_web_php() {

  local file='run/run-web.php';

  [ -f "$file" ] && { return; }

  cat <<EOF > $file
<?php

require_once __DIR__ . '/../ext/mudball/run/run-web.php';

EOF

}

lx_gen_mudball_src_code_bootstrap_library() {

  local file='src/code/1-bootstrap/1-library.php';

  [ -f "$file" ] && { return; }

  cat <<EOF > $file
<?php


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - trace load if enabled...
//

if ( defined( 'APP_TRACE_LOAD' ) && APP_TRACE_LOAD ) {

  error_log( "loading: " . __FILE__ );

}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - load libraries...
//

require_once __DIR__ . '/../../../ext/mudball-$LX_MUDBALL_VERSION/inc/module.php';

EOF

}

lx_gen_mudball_src_code_bootstrap_constant() {

  local file='src/code/1-bootstrap/2-constant.php';

  [ -f "$file" ] && { return; }

  cat <<EOF > $file
<?php


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - trace load if enabled...
//

if ( defined( 'APP_TRACE_LOAD' ) && APP_TRACE_LOAD ) {

  error_log( "loading: " . __FILE__ );

}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - load dependencies...
//

require_once __DIR__ . '/1-library.php';


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - define version constants...
//

require_once __DIR__ . '/../../../inc/version.php';


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - path info...
//

define( '${LX_PROJECT_CODE}_PATH', realpath( __DIR__ . '/../../../' ) );
define( '${LX_PROJECT_CODE}_CONFIG_FILE', 'config.php' );
define( '${LX_PROJECT_CODE}_CONFIG_PATH', ${LX_PROJECT_CODE}_PATH . '/' . ${LX_PROJECT_CODE}_CONFIG_FILE );


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - maintainer info...
//

define( '${LX_PROJECT_CODE}_MAINTAINER_USERNAME',  '${LX_VCS_USER}' );
define( '${LX_PROJECT_CODE}_MAINTAINER_EMAIL',     '${LX_VCS_EMAIL}' );
define( '${LX_PROJECT_CODE}_MAINTAINER_NAME',      '${LX_VCS_NAME}');
define(
  '${LX_PROJECT_CODE}_MAINTAINER',
  ${LX_PROJECT_CODE}_MAINTAINER_NAME . ' <' . ${LX_PROJECT_CODE}_MAINTAINER_EMAIL . '>'
);

define(
  '${LX_PROJECT_CODE}_PLEASE_INFORM',
  'please let the maintainer know: ' . ${LX_PROJECT_CODE}_MAINTAINER
);

EOF

}

lx_gen_mudball_src_code_bootstrap_enum() {

  local file='src/code/1-bootstrap/3-enum.php';

  [ -f "$file" ] && { return; }

  cat <<EOF > $file
<?php


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - trace load if enabled...
//

if ( defined( 'APP_TRACE_LOAD' ) && APP_TRACE_LOAD ) {

  error_log( "loading: " . __FILE__ );

}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - load dependencies...
//

require_once __DIR__ . '/2-constant.php';


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - define enums...
//

mud_load_enums( __DIR__ . '/../3-lookup/enum' );

EOF

}

lx_gen_mudball_src_code_bootstrap_flags() {

  local file='src/code/1-bootstrap/3-flags.php';

  [ -f "$file" ] && { return; }

  cat <<EOF > $file
<?php


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - trace load if enabled...
//

if ( defined( 'APP_TRACE_LOAD' ) && APP_TRACE_LOAD ) {

  error_log( "loading: " . __FILE__ );

}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - load dependencies...
//

require_once __DIR__ . '/3-enum.php';


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - define flags...
//

mud_load_enums( __DIR__ . '/../3-lookup/flags' );

EOF

}

lx_gen_mudball_src_code_bootstrap_config() {

  local file='src/code/1-bootstrap/4-config.php';

  [ -f "$file" ] && { return; }

  cat <<EOF > $file
<?php


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - trace load if enabled...
//

if ( defined( 'APP_TRACE_LOAD' ) && APP_TRACE_LOAD ) {

  error_log( "loading: " . __FILE__ );

}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - load dependencies...
//

require_once __DIR__ . '/3-flags.php';


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - include config file...
//

global \$config;

if ( file_exists( ${LX_PROJECT_CODE}_CONFIG_PATH ) ) {

  require_once ${LX_PROJECT_CODE}_CONFIG_PATH;

}

mud_define_version( '${LX_PROJECT_CODE}' );

EOF

}

lx_gen_mudball_src_code_bootstrap_module() {

  local file='src/code/1-bootstrap/5-module.php';

  [ -f "$file" ] && { return; }

  cat <<EOF > $file
<?php


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - trace load if enabled...
//

if ( defined( 'APP_TRACE_LOAD' ) && APP_TRACE_LOAD ) {

  error_log( "loading: " . __FILE__ );

}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - load dependencies...
//

require_once __DIR__ . '/4-config.php';


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - load modules...
//

mud_load_modules( __DIR__ . '/../5-module', 'app' );


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - load generated code...
//

//require_once __DIR__ . '/../../gen/dal/include.php';

EOF

}

lx_gen_mudball_src_code_bootstrap_keystone() {

  local file='src/code/1-bootstrap/9-keystone.php';

  [ -f "$file" ] && { return; }

  cat <<EOF > $file
<?php


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - trace load if enabled...
//

if ( defined( 'APP_TRACE_LOAD' ) && APP_TRACE_LOAD ) {

  error_log( "loading: " . __FILE__ );

}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - load dependencies...
//

require_once __DIR__ . '/5-module.php';


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - define application...
//

mud_define_app( '${LX_PROJECT_CODE}' );


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// $LX_DATE_USER - define service locators...
//

//function app_raw( \$set = false ) : AppRaw { return mud_raw( \$set ); }

EOF

}

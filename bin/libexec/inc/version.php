<?php

define( 'APP_VERSION_FILE_PHP', 'inc/version.php' );
define( 'APP_VERSION_FILE_BASH', 'inc/version.sh' );

define( 'APP_VERSION_FILE_COMMENT', 'this file is automatically generated by kickass-libexec scripts...' );
define( 'APP_VERSION_NAME_COMMENT', 'you can change the name but not the code...' );

function get_version_info(
  &$const_prefix,
  &$version_major,
  &$version_minor,
  &$version_patch,
  &$date,
  &$svn_date,
  &$svn_revision,
  &$svn_author,
  &$name,
  &$code
) {

  $const_prefix_regex = '/\'([^_]+)_VERSION_MAJOR\', ([0-9]+)/';

  $name_regex = '/_NAME\', ([\'"][^\'"]+[\'"])/';
  $code_regex = '/_CODE\', ([\'"][^\'"]+[\'"])/';

  $version_major_regex = '/_VERSION_MAJOR\', ([0-9]+)/';
  $version_minor_regex = '/_VERSION_MINOR\', ([0-9]+)/';
  $version_patch_regex = '/_VERSION_PATCH\', ([0-9]+)/';

  // 2024-07-07 jj5 - OLD: we don't need these anymore...
  /*
  $date_regex = '/Date: ([^ ]+) ([^ ]+) ([^ ]+) ([^)]+\))/';
  $revision_regex = '/Revision: ([^ ]+)/';
  $author_regex = '/Author: ([^ ]+)/';
  $git_date_regex = '/_GIT_DATE\', \'([^\']+)\'/';
  */

  $const_prefix = null;

  $version_major = null;
  $version_minor = null;
  $version_patch = null;

  $name = "''";
  $code = "''";

  //$commit_hash = trim( `git rev-parse HEAD` );
  $commit_hash_short = trim( `git rev-parse --short HEAD` );

  $date = date( 'Y-m-d H:i:s O (D, d M Y)' );

  $svn_date = 'Date: ' . $date;

  // 2024-07-06 jj5 - this essentially writes a random number into the revision, which is fine for now...
  //
  $svn_revision = 'Revision: ' . hexdec( $commit_hash_short );

  $svn_author = 'Author: ' . get_current_user();

  $lines = file( APP_VERSION_FILE_PHP );

  for ( $i = 0; $i < count( $lines ); $i++ ) {

    $line = $lines[ $i ];

    if ( preg_match( $const_prefix_regex, $line, $matches ) ) {

      $const_prefix = $matches[ 1 ];

    }

    if ( preg_match( $code_regex, $line, $matches ) ) {

      $code = $matches[ 1 ];

    }
    elseif ( preg_match( $name_regex, $line, $matches ) ) {

      $name = $matches[ 1 ];

    }
    elseif ( preg_match( $version_major_regex, $line, $matches ) ) {

      $version_major = intval( $matches[ 1 ] );

    }
    elseif ( preg_match( $version_minor_regex, $line, $matches ) ) {

      $version_minor = intval( $matches[ 1 ] );

    }
    elseif ( preg_match( $version_patch_regex, $line, $matches ) ) {

      $version_patch = intval( $matches[ 1 ] );

    }
  }
}

function write_version_files(
  $const_prefix,
  $version_major,
  $version_minor,
  $version_patch,
  $date,
  $svn_date,
  $svn_revision,
  $svn_author,
  $name,
  $code
) {

  write_version_file_php(
    $const_prefix,
    $version_major,
    $version_minor,
    $version_patch,
    $date,
    $svn_date,
    $svn_revision,
    $svn_author,
    $name,
    $code
  );

  write_version_file_bash(
    $const_prefix,
    $version_major,
    $version_minor,
    $version_patch,
    $date,
    $svn_date,
    $svn_revision,
    $svn_author,
    $name,
    $code
  );

}

function write_version_file_php(
  $const_prefix,
  $version_major,
  $version_minor,
  $version_patch,
  $date,
  $svn_date,
  $svn_revision,
  $svn_author,
  $name,
  $code
) {

  $version = $version_major . '.' . $version_minor . '.' . $version_patch;

  $file = [];

  $file[] = "<?php";
  $file[] = '';
  $file[] = '// ' . APP_VERSION_FILE_COMMENT;
  $file[] = '';
  $file[] = '// ' . APP_VERSION_NAME_COMMENT;
  $file[] = "define( '{$const_prefix}_NAME', {$name} );";
  $file[] = "define( '{$const_prefix}_CODE', {$code} );";
  $file[] = '';
  $file[] = "define( '{$const_prefix}_VERSION', '{$version}' );";
  $file[] = "define( '{$const_prefix}_VERSION_MAJOR', {$version_major} );";
  $file[] = "define( '{$const_prefix}_VERSION_MINOR', {$version_minor} );";
  $file[] = "define( '{$const_prefix}_VERSION_PATCH', {$version_patch} );";
  $file[] = '';
  $file[] = "define(";
  $file[] = "  '{$const_prefix}_SVN_DATE',";
  $file[] = "  '\${$svn_date} $'";
  $file[] = ");";
  $file[] = "define( '{$const_prefix}_SVN_REVISION', '\${$svn_revision} $' );";
  $file[] = "define( '{$const_prefix}_SVN_AUTHOR', '\${$svn_author} $' );";
  $file[] = '';
  $file[] = "define( '{$const_prefix}_GIT_DATE', '{$date}' );";

  write_version_file( APP_VERSION_FILE_PHP, $file );

}

function write_version_file_bash(
  $const_prefix,
  $version_major,
  $version_minor,
  $version_patch,
  $date,
  $svn_date,
  $svn_revision,
  $svn_author,
  $name,
  $code
) {

  $version = $version_major . '.' . $version_minor . '.' . $version_patch;

  $file = [];

  $file[] = "#!/bin/bash";
  $file[] = '';
  $file[] = "# " . APP_VERSION_FILE_COMMENT;
  $file[] = '';
  $file[] = "export {$const_prefix}_NAME='{$name}';";
  $file[] = "export {$const_prefix}_CODE='{$code}';";
  $file[] = '';
  $file[] = "export {$const_prefix}_VERSION='{$version}';";
  $file[] = "export {$const_prefix}_VERSION_MAJOR='{$version_major}';";
  $file[] = "export {$const_prefix}_VERSION_MINOR='{$version_minor}';";
  $file[] = "export {$const_prefix}_VERSION_PATCH='{$version_patch}';";
  $file[] = '';
  $file[] = "export {$const_prefix}_SVN_DATE='{$svn_date}';";
  $file[] = "export {$const_prefix}_SVN_REVISION='{$svn_revision}';";
  $file[] = "export {$const_prefix}_SVN_AUTHOR='{$svn_author}';";
  $file[] = '';
  $file[] = "export {$const_prefix}_GIT_DATE='{$date}';";

  write_version_file( APP_VERSION_FILE_BASH, $file );

}

function write_version_file( string $path, array $lines ) {

  $lines[] = '';

  $text = implode( "\n", $lines );

  file_put_contents( $path, $text );

}

main( $argv );

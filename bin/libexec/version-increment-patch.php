<?php

require_once( __DIR__ . '/inc/version.php' );

// 2024-07-06 jj5 - the important thing that happens in this script is that the _PATCH number is incremented by 2,
// the rest of it doesn't matter much...

// 2024-07-06 jj5 - NOTE: odd PATCH numbers indicate development versions, even PATCH numbers indicate release versions...
// This script just increments by two, keeping the PATCH number odd... a release script will increment by one before
// release and then by one after release.

function main( $argv ) {

  get_version_info(
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

  $version_patch += 2;

  write_version_files(
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

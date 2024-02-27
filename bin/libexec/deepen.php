#!/usr/bin/env php
<?php

if ( count( $argv ) !== 2 ) {
  echo "Invalid arguments.\n";
  exit( 1 );
}

$path = $argv[ 1 ];

main( $path );

function main( $path ) {
  if ( ! is_dir( $path ) ) {
    echo "Path '$path' is not a directory.\n";
    exit( 1 );
  }
  if ( $handle = opendir( $path ) ) {
    while ( false !== ( $entry = readdir( $handle ) ) ) {
      if ( preg_match( '/^\d\d\d\d\-\d\d\-\d\d-\d\d\d\d\d\d$/', $entry ) ) {
        $dir = explode( '-', $entry );
        $to = $path . '/' . implode( '/', $dir );
        unset( $dir[ 3 ] );
        $dir = $path . '/' . implode( '/', $dir );
        $from = $path . '/' . $entry;
        if ( ! is_dir( $dir ) ) {
          mkdir( $dir, 0777, true );
        }
        //if ( file_exists( $to ) ) {
          //echo "Path '$to' exists!\n";
        //}
        $base = $to;
        $i = 2;
        while ( file_exists( $to ) ) {
          echo "Path '$to' exists!\n";
          $to = $base . '-' . $i++;
        }
        rename( $from, $to );
      }
    }
    closedir( $handle );
  }
}

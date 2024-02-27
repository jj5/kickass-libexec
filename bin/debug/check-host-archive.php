#!/usr/bin/env php
<?php

function main( $argv ) {

  chdir( '/file/archive' );

  foreach ( glob( '*' ) as $year ) {

    if ( ! preg_match( '/^\d{4}$/', $year ) ) { note( "irregular year: $year" ); }

    check_year( $year );

  }
}

function check_year( $year ) {

  chdir( $year );

  foreach ( glob( '*' ) as $month ) {

    if ( ! preg_match( '/^\d{2}$/', $month ) ) { note( "irregular month: $year/$month" ); }

    check_month( $year, $month );

  }

  chdir( '..' );

}

function check_month( $year, $month ) {

  chdir( $month );

  foreach ( glob( '*' ) as $day ) {

    if ( ! preg_match( '/^\d{2}$/', $day ) ) { note( "irregular day: $year/$month/$day" ); }

    check_day( $year, $month, $day );

  }

  chdir( '..' );

}

function check_day( $year, $month, $day ) {

  chdir( $day );

  //echo getcwd() . "\n";

  foreach ( glob( '*' ) as $time ) {

    if ( ! preg_match( '/^\d{6}$/', $time ) ) { note( "irregular time: $year/$month/$day/$time" ); }

  }

  chdir( '..' );

}

function note( $message ) {

  echo "$message\n";

}

main( $argv );

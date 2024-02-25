#!/usr/bin/env php
<?php

/******************************************************************************
 * hanok.php by jj5@progclub.org
 * =============================
 *
 * This program deletes old backups/snapshots to make room for new ones.
 *
 * The backups must be in directories in the format YYYY-MM-DD or
 * YYYY-MM-DD-HHNNSS. Empty backup directories are automatically removed.
 *
 * The program tries to strike a balance between freshness and age. To do this
 * it picks a backup to delete based on the interval between backups. The most
 * recent backup from the pair with the shortest backup interval will be the
 * victim.
 *
 * The program always keeps a number of the most recent backups, if possible.
 *
 * Program managed as a component of jj5-bin:
 *
 *  https://www.jj5.net/sixsigma/JJ5-bin
 *
 * Copyright John Elliot V 2017-2019. Licensed under the New BSD license.
 *
 * Invoke like this:
 *
 *  php hanok.php \
 *    --recent RECENT \
 *    --max MAX \
 *    --temp TEMP \
 *    --type TYPE \
 *    --zfs FILESYSTEM \
 *    [DIR]
 *
 *
 *  RECENT: the number of recent backups to keep. Default seven.
 *
 *  MAX: the number of old backups to keep. Note that you must always
 *  keep at least one, the program enforces this. Default forty-seven.
 *
 *  TEMP: the temp directory to use when deleting backups. The delete process
 *  moves the victim to the temp directory before deleting it making the
 *  delete appear somewhat atomic.
 *
 *  TYPE: use 'zfs' to destroy ZFS snapshots, or 'std' for file-system delete.
 *
 *  DIR: the directory you want to process, defaults to $PWD for 'std' mode
 *  and must be specified as the filesystem name for 'zfs' mode.
 *
 ******************************************************************************/

define( 'DEFAULT_RECENT', 7 );
define( 'DEFAULT_MAX', 47 );

if ( ! function_exists( 'main' ) ) {

  if ( ! defined( 'DEBUG' ) ) { define( 'DEBUG', false ); }

  function main( $argc, $argv ) { return run( $argc, $argv ); }

  main( $argc, $argv );

}

function run( $argc, $argv ) {

  $command = array_shift( $argv );
  $recent = DEFAULT_RECENT;
  $max = DEFAULT_MAX;
  $temp_dir = null;
  $type = 'std';
  $filesystem = null;
  $dir = null;

  echo "Running command: $command\n";

  while ( count( $argv ) ) {

    $arg = array_shift( $argv );

    //echo "checking argument: $arg\n";

    switch ( $arg ) {

    case '--recent' :

      $recent = intval( array_shift( $argv ) );

      break;

    case '--max' :

      $max = intval( array_shift( $argv ) );

      break;

    case '--temp' :

      $temp_dir = rtrim( trim( array_shift( $argv ), DIRECTORY_SEPARATOR ) );

      if ( ! is_dir( $temp_dir ) ) {

        echo "Path '$temp_dir' is not a directory.\n";

        exit( 1 );

      }

      break;

    case '--type' :

      $type = trim( array_shift( $argv ) );

      if ( ! in_array( $type, [ 'std', 'zfs' ] ) ) {

        echo "Unsuppored type '$type'.";

        exit( 1 );

      }

      break;

    case '--zfs' :

      $filesystem = trim( array_shift( $argv ) );

      break;

    default :

      $dir = $arg;

      $path = $type === 'zfs' ? "/$dir/.zfs/snapshot" : $dir;

      if ( ! chdir( $path ) ) { echo "Could not cd to '$path'.\n"; exit( 1 ); }

      break;

    }
  }

  // 2019-09-12 jj5 - if no explicit file system was provided assume it can
  // be determined from the DIR argument...
  //
  if ( $type === 'zfs' && ! $filesystem ) {

    $filesystem = "$dir";

  }

  if ( $type === 'zfs' && ! $filesystem ) {

    echo "Could not determine ZFS file system.\n";

    exit( 2 );

  }

  echo "type: $type\n";
  echo "file-system: $filesystem\n";

  // 2017-05-07 jj5 - DONE: must always keep at least one backup.
  if ( $recent < 1 ) { $recent = 1; }
  if ( $max < 1 ) { $max = 1; }
  if ( $max < $recent ) { $max = $recent; }

  // 2017-05-05 jj5 - DONE: we bump 'max' down so it's >= 0. We do this because
  // we leave one directory out of the deletion candidates list, see get_dirs().
  $max--;

  if ( $type === 'zfs' ) {

    if ( ! $dir ) { echo "Invalid ZFS filesystem '$dir'."; exit( 1 ); }

    $proc = 'process_zfs';

  }
  else {

    $proc = 'process_std';

  }

  // 2017-05-05 jj5 - DONE: get backup directories and process them until
  // we're finished...
  do {

    $dirs = get_dirs( '.', $type );

  }
  while ( $proc( $dirs, $recent, $max, $temp_dir, $dir, $filesystem ) );

}

function get_dirs( $dir, $type ) {

  //echo "Running get_dirs...\n";

  // 2017-05-05 jj5 - DONE: get_dirs() returns backup directories which are
  // candidates for deletion. The latest backup directory is never a
  // candidate for deletion, so there's always at least one safe recent
  // backup even if there's an operator error.

  $result = [];
  $files = array_diff( scandir( $dir ), [ '.', '..' ] );

  foreach ( $files as $file ) {

    $path = "$dir/$file";

    //echo "Processing path: $path\n";

    // 2017-05-05 jj5 - DONE: we only process backup directories.
    if ( ! is_dir( $path ) ) { continue; }

    // 2017-05-05 jj5 - DONE: directory must be in one of two possible formats.
    if (
      preg_match( '/^\d\d\d\d-\d\d-\d\d$/', $file ) ||
      preg_match( '/^\d\d\d\d-\d\d-\d\d-\d\d\d\d\d\d$/', $file )
    ) {

      //echo "Running scandir...\n";

      $subs = @scandir( $path );

      if ( ! $subs ) {

        echo "path: $path\n";
        echo "cwd: " . getcwd() . "\n";

        exit( 9 );

      }

      $subs_count = count( $subs );

      //echo "subs count: $subs_count\n";

      if ( $subs_count === 2 && ! DEBUG ) {

        // 2019-03-25 jj5 - don't try to delete snapshot directory in ZFS mode
        //
        if ( $type === 'zfs' ) { continue; }

        // 2017-05-05 jj5 - DONE: remove empty backup directories if we find
        // them...
        //
        if ( ! rmdir( $path ) ) {

          echo "Failed to remove '$path'.\n";

          exit( 1 );

        }

        echo "Removed empty backup '$path'.\n";

      }
      else {

        // 2017-05-05 jj5 - TODO: verify valid date/time, e.g. not 30th Feb

        $result[] = $file;

        //echo "Added '$file'.\n";

      }
    }
  }

  // 2017-05-05 jj5 - DONE: make sure our historical backups are in order.
  sort( $result );

  // 2017-05-05 jj5 - DONE: remove the latest backup so we don't delete it.
  array_pop( $result );

  return $result;

}

function process_std(
  $dirs,
  $recent,
  $max,
  $temp_dir = null,
  $dir,
  $filesystem = null
) {

  $count = count( $dirs );

  // 2017-05-05 jj5 - DONE: if we're not out of backup space there's nothing
  // to do.
  if ( $count <= $max ) { return false; }

  // 2017-05-05 jj5 - DONE: determine the victim. The 'victim' is the backup
  // which we will delete to create more space for newer backups.
  // 2017-05-07 jj5 - DONE: if $count <= 3 always delete the oldest backup.
  // 2017-05-07 jj5 - DONE: always keep a few of the latest backups around...
  $victim = find_victim( $dirs, $recent );

  // 2017-05-05 jj5 - DONE: get the name of the victim which we will remove...
  $remove = $dirs[ $victim ];

  // 2017-05-05 jj5 - DONE: do some basic sanity checking because we don't
  // want to fuck up an 'rm -rf'...
  if ( strlen( $remove ) && is_dir( $remove ) ) {

    // 2017-05-05 jj5 - DONE: seems to be ok, alert the user...
    echo "Deleting '$remove'...\n";

    if ( $temp_dir !== null ) {

      $target = "$temp_dir/$remove";

      if ( file_exists( $target ) ) {

        echo "Temp path '$target' exists!\n";

        exit( 1 );

      }

      if ( ! rename( $remove, "$target" ) ) {

        echo "Error moving '$remove' to '$target'.\n";

        exit( 1 );

      }
    }
    else {

      $target = $remove;

    }

    // 2017-05-05 jj5 - DONE: build the command to delete the victim...
    $command = 'rm -rf ' . addslashes( $target );

    // 2017-05-05 jj5 - DONE: process the deletion...
    exec( $command, $output, $error_level );

    // 2017-05-05 jj5 - DONE: return success if no error...
    if ( $error_level === 0 ) { return true; }

    // 2017-05-05 jj5 - NOTE: the command failed, alert the user...
    echo "Command '$command' failed with error level '$error_level'.\n";

    // 2017-05-05 jj5 - DONE: return error on command failure...
    exit( 1 );

  }

  echo "Backup '$remove' not removed.\n";

  // 2017-05-05 jj5 - DONE: return error if command doesn't pass validation...
  exit( 1 );

}

function process_zfs(
  $dirs,
  $recent,
  $max,
  $temp_dir = null,
  $dir,
  $filesystem
) {

  echo "Running process_zfs...\n";

  $count = count( $dirs );

  echo "count = $count\n";

  // 2017-05-05 jj5 - DONE: if we're not out of backup space there's nothing
  // to do.
  if ( $count <= $max ) { return false; }

  // 2017-05-05 jj5 - DONE: determine the victim. The 'victim' is the backup
  // which we will delete to create more space for newer backups.
  // 2017-05-07 jj5 - DONE: if $count <= 3 always delete the oldest backup.
  // 2017-05-07 jj5 - DONE: always keep a few of the latest backups around...
  $victim = find_victim( $dirs, $recent );

  // 2017-05-05 jj5 - DONE: get the name of the victim which we will remove...
  $remove = $dirs[ $victim ];

  // 2017-05-05 jj5 - DONE: do some basic sanity checking because we don't
  // want to fuck up an 'rm -rf'...
  if ( strlen( $remove ) && is_dir( $remove ) ) {

    // 2017-05-05 jj5 - DONE: seems to be ok, alert the user...
    echo "Deleting snapshot '$filesystem@$remove'...\n";

    // 2017-05-05 jj5 - DONE: build the command to destroy the victim...
    $command = "/sbin/zfs destroy $filesystem@$remove";

    // 2017-05-05 jj5 - DONE: process the deletion...
    exec( $command, $output, $error_level );

    // 2017-05-05 jj5 - DONE: return success if no error...
    if ( $error_level === 0 ) { return true; }

    // 2017-05-05 jj5 - NOTE: the command failed, alert the user...
    echo "Command '$command' failed with error level '$error_level'.\n";

    // 2017-05-05 jj5 - DONE: return error on command failure...
    exit( 1 );

  }

  echo "Snapshot '$filesystem@$remove' not removed.\n";

  // 2017-05-05 jj5 - DONE: return error if command doesn't pass validation...
  exit( 1 );

}

function find_victim( $dirs, $recent, &$item = null ) {

  // 2017-05-07 jj5 - DONE: new find_victim() script removes item based on
  // shortest backup interval.

  $item = null;
  $count = count( $dirs );
  $i = 0;

  // 2017-05-07 jj5 - DONE: we always keep the latest few backups per
  // $recent...
  while ( $i < $count && $i < $recent ) { array_pop( $dirs ); $i++; }

  $count = count( $dirs );

  // 2017-05-07 jj5 - DONE: delete oldest
  if ( $count <= 1 ) { return 0; }

  $list = [];
  $prev = null;

  foreach ( $dirs as $index => $dir ) {

    $date = substr( $dir, 0, 10 );
    $time = null;

    if ( strlen( $dir ) > strlen( $date ) ) {

      // 2017-05-07 jj5 - DONE: read hours, minutes, seconds

      $h = substr( $dir, 11, 2 );
      $m = substr( $dir, 13, 2 );
      $s = substr( $dir, 15, 2 );

      $time = "$h:$m:$s";

    }

    $datetime = new DateTime( "$date $time" );

    if ( $index > 0 ) {

      $prev[ 'duration' ] = $datetime->getTimestamp() - $prev[ 'timestamp' ];

      $list[] = $prev;

    }

    $prev = [
      'directory' => $dir,
      'index' => $index,
      'timestamp' => $datetime->getTimestamp()
    ];

  }

  usort(

    $list,

    function( $a, $b ) {

      // 2017-05-07 jj5 - DONE: sort with shortest backup interval
      // ("duration") first

      $result = $a[ 'duration' ] - $b[ 'duration' ];

      if ( $result ) { return $result; }

      // 2017-05-07 jj5 - DONE: if the duration is equal pick the most recent
      return strcmp( $b[ 'directory' ], $a[ 'directory' ] );

    }

  );

  $item = $list[ 0 ];

  return $item[ 'index' ] + 1;

}

// 2019-03-26 jj5 - TODO: add support for a --mount option, for use when 'zfs'
// filesystems aren't mounted using their name.
//

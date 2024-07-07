<?php

// 2024-07-06 jj5 - the important thing that happens in this script is that the _PATCH number is incremented by 2,
// the rest of it doesn't matter much...

// 2024-07-06 jj5 - NOTE: odd PATCH numbers indicate development versions, even PATCH numbers indicate release versions...
// This script just increments by two, keeping the PATCH number odd... a release script will increment by one before
// release and then by one after release.

define( 'APP_VERSION_FILE_PHP', 'inc/version.php' );
define( 'APP_VERSION_FILE_BASH', 'inc/version.sh' );

define( 'APP_VERSION_FILE_COMMENT', 'this file is automatically generated by bin/dev/version-*.sh scripts...' );

function main( $argv ) {

  $const_prefix_regex = '/\'([^_]+)_VERSION_MAJOR\', ([0-9]+)/';

  $version_major_regex = '/_VERSION_MAJOR\', ([0-9]+)/';
  $version_minor_regex = '/_VERSION_MINOR\', ([0-9]+)/';
  $version_patch_regex = '/_VERSION_PATCH\', ([0-9]+)/';

  $date_regex = '/Date: ([^ ]+) ([^ ]+) ([^ ]+) ([^)]+\))/';
  $revision_regex = '/Revision: ([^ ]+)/';
  $author_regex = '/Author: ([^ ]+)/';
  $git_date_regex = '/_GIT_DATE\', \'([^\']+)\'/';

  $const_prefix = null;

  $version_major = null;
  $version_minor = null;
  $version_patch = null;

  //$commit_hash = trim( `git rev-parse HEAD` );
  $commit_hash_short = trim( `git rev-parse --short HEAD` );

  $date = date( 'Y-m-d H:i:s O (D, d M Y)' );

  $svn_date = 'Date: ' . $date;

  // 2024-07-06 jj5 - this essentially writes a random number into the revision, which is fine for now...
  //
  $svn_revision = 'Revision: ' . hexdec( $commit_hash_short );

  $svn_author = 'Author: ' . get_current_user();

  $lines = file( APP_VERSION_FILE_PHP );

  $result = [];

  $found_git_date = false;

  for ( $i = 0; $i < count( $lines ); $i++ ) {

    $line = $lines[ $i ];
    $trim_line = trim( $line );

    if ( strpos( $line, '<?php' ) === 0 ) {

      $result[] = $line;
      $result[] = '// ' . APP_VERSION_FILE_COMMENT . "\n";

      continue;

    }

    if ( strlen( $trim_line ) === 0 ) {

      // 2024-07-06 jj5 - ignore blank lines...
      
      continue;

    }

    if ( strpos( $trim_line, '//' ) === 0 ) {

      // 2024-07-06 jj5 - ignore comments...

      continue;

    }

    if ( preg_match( $const_prefix_regex, $line, $matches ) ) {

      $const_prefix = $matches[ 1 ];

    }

    if ( preg_match( $version_major_regex, $line, $matches ) ) {

      $version_major = intval( $matches[ 1 ] );

      $result[] = $line;

    }
    elseif ( preg_match( $version_minor_regex, $line, $matches ) ) {

      $version_minor = intval( $matches[ 1 ] );

      $result[] = $line;

    }
    elseif ( preg_match( $version_patch_regex, $line, $matches ) ) {

      $version_patch = $matches[ 1 ] + 2;

      if ( $version_patch % 2 !== 1 ) {

        echo "Warning: patch number is not odd: $version_patch\n";

        exit( 1 );

      }

      $result[] = preg_replace( $version_patch_regex, '_VERSION_PATCH\', ' . $version_patch, $line );

    }
    elseif ( preg_match( $date_regex, $line, $matches ) ) {

      $result[] = preg_replace( $date_regex, $svn_date, $line );

    }
    elseif ( preg_match( $revision_regex, $line, $matches ) ) {

      $result[] = preg_replace( $revision_regex, $svn_revision, $line );

    }
    elseif ( preg_match( $author_regex, $line, $matches ) ) {

      $result[] = preg_replace( $author_regex, $svn_author, $line );

    }
    elseif ( preg_match( $git_date_regex, $line, $matches ) ) {

      $found_git_date = true;

      $result[] = preg_replace( $git_date_regex, '_GIT_DATE\', \'' . $date . '\'', $line );

    }
    else {

      $result[] = $line;

    }
  }

  if ( ! $found_git_date ) {

    $result[] = "\n";
    $result[] = "define( '{$const_prefix}_GIT_DATE', '$date' );\n";

  }

  $text = implode( '', $result );

  file_put_contents( APP_VERSION_FILE_PHP, $text );

  $version = $version_major . '.' . $version_minor . '.' . $version_patch;

  $bash = [];

  $bash[] = "#!/bin/bash";
  $bash[] = "# " . APP_VERSION_FILE_COMMENT;
  $bash[] = "export {$const_prefix}_VERSION=$version";
  $bash[] = "export {$const_prefix}_VERSION_MAJOR=$version_major";
  $bash[] = "export {$const_prefix}_VERSION_MINOR=$version_minor";
  $bash[] = "export {$const_prefix}_VERSION_PATCH=$version_patch";
  $bash[] = "export {$const_prefix}_SVN_DATE='$svn_date'";
  $bash[] = "export {$const_prefix}_SVN_REVISION='$svn_revision'";
  $bash[] = "export {$const_prefix}_SVN_AUTHOR='$svn_author'";
  $bash[] = "export {$const_prefix}_GIT_DATE='$date'";
  $bash[] = "";

  $bash_text = implode( "\n", $bash );

  file_put_contents( APP_VERSION_FILE_BASH, $bash_text );

}

main( $argv );

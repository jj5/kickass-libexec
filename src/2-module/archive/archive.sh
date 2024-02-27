#!/bin/bash

source "$( dirname "${BASH_SOURCE[0]}" )/archive-import.sh";

lx_archive_auto() {

  local path="$1";

  if [ -z "$path" ]; then

    lx_fail 1 "must specify a path.";

  fi;

  if [ ! -d "$path" ]; then

    lx_fail 2 "path '$path' is not a valid directory.";

  fi;

  lx_quiet pushd "$path";

  local file_count="$( ls -alh | wc -l )";

  if [ "$file_count" -gt 3 ]; then

    (
      shopt -s dotglob;
      lx_run lx_archive remove *;
    )

  fi;

  lx_quiet popd;

}

lx_archive() {

  lx_archive_do lx_archive_tarball "$@";

}

lx_archive_file() {

  lx_archive_do lx_archive_copy "$@";

}

lx_archive_tarball() {

  local tarball="$LX_WORKSPACE/archive.tgz";

  if [ -e "$tarball" ]; then

    lx_fail 8 "archive tarball '$tarball' already exists.";

  fi;

  lx_run tar -c -I 'pigz --fast' -f "$tarball" --owner=$user --group=$group "${file_list[@]}";

  lx_run chown "$user:$group" "$archive_note";

  lx_quiet pushd "$archive_path";

  lx_run mv "$archive_note" './';

  lx_run tar xzf "$tarball";

  lx_run rm "$tarball";

  # 2019-03-25 jj5 - I didn't think long and hard about this. The problem is
  # that we may have deleted some part of the current directory, but we need
  # to be where we started so that the 'rm' command can run to delete the
  # now archived files...
  #
  if lx_quiet popd; then

    true;

  else

    lx_fail "$LX_EXIT_BAD_ENVIRONMENT" "error popping directory stack.";

  fi;

}

lx_archive_copy() {

  lx_run $sudo cp -a "${file_list[@]}" "$archive_path";
  lx_run $sudo mv "$archive_note" "$archive_path/";
  lx_run $sudo chown -R "$user:$group" "$archive_path";
  lx_run $sudo chmod -R u+rw "$archive_path";

}

lx_archive_do() {

  local check_path="$PWD";

  local bundler="$1";
  local archive_type="$2";

  shift; shift;

  lx_require item "$bundler" 'lx_archive_tarball' 'lx_archive_copy';
  lx_require item "$archive_type" 'copy' 'remove';

  lx_debug "LX_ARCHIVE_DIR: $LX_ARCHIVE_DIR";

  lx_require dir "$LX_ARCHIVE_DIR";

  lx_debug "archive_type: $archive_type";

  if [ "$#" == '0' ]; then

    lx_fail 1 "must specify files to archive.";

  fi;

  local sudo='sudo';

  if [ "$HOSTNAME" = "mango" ]; then

    sudo='';

  fi;

  if ! sudo -v 2>/dev/null; then

    sudo='';

  fi;

  # 2019-03-25 jj5 - this affects the global state, but hey...
  #
  TZ='Australia/Sydney';

  local archive_dir="$LX_ARCHIVE_DIR";

  if $sudo mkdir -p "$archive_dir"; then

    true;

  else

    lx_fail 2 "error creating archive directory '$archive_dir'.";

  fi;

  local user="$LX_DEFAULT_USER";
  local group="$LX_DEFAULT_GROUP";

  if [ "$HOSTNAME" = "tilde.club" ]; then

    group='club';

  fi;

  if $sudo chown "$user:$group" "$archive_dir"; then

    true;

  else

    lx_fail 3 "error chowning directory '$archive_dir'.";

  fi;

  if $sudo chmod 700 "$archive_dir"; then

    true;

  else

    lx_fail 4 "error chmoding archive directory '$archive_dir'.";

  fi;

  while true; do

    local timestamp=$( date +%s );

    if [ "$( uname )" == "Darwin" ]; then

      local a_year=$(   date -r $timestamp +%Y );
      local a_month=$(  date -r $timestamp +%m );
      local a_day=$(    date -r $timestamp +%d );
      local a_time=$(   date -r $timestamp +%H%M%S );

    else

      local a_year=$(   date --date=@$timestamp +%Y );
      local a_month=$(  date --date=@$timestamp +%m );
      local a_day=$(    date --date=@$timestamp +%d );
      local a_time=$(   date --date=@$timestamp +%H%M%S );

    fi;

    local archive_path="$archive_dir/$a_year-$a_month-$a_day-$a_time";

    if [ -e "$archive_path" ]; then

      sleep 1;

      continue;

    fi;

    break;

  done;

  lx_debug "Archive path is: $archive_path";

  if $sudo mkdir "$archive_path"; then

    true;

  else

    lx_fail 5 "error creating archive directory '$archive_path'.";

  fi;

  if $sudo chown "$user:$group" "$archive_path"; then

    true;

  else

    lx_fail 6 "error chowning directory '$archive_path'.";

  fi;

  if $sudo chmod 755 "$archive_path"; then

    true;

  else

    lx_fail 7 "error chmoding archive directory '$archive_path'.";

  fi;

  lx_ensure_workspace;

  local archive_note="$LX_WORKSPACE/archive-note.txt";

  if [ "$( uname )" == "Darwin" ]; then

    local date=$( date -r $timestamp );

  else

    local date=$( date --date=@$timestamp );

  fi;

  local user="$USER";
  local host=$( hostname -f );
  local path="$PWD";
  declare -a file_list=();
  declare -a name_list=();

  # 2019-03-26 jj5 - this is a fixup for when we archive files via drag/drop
  # in KDE Plasma... the arg list has '/home/jj5/desktop//' prefixed to our
  # files and we want to remove that before creating the archive tarball.
  #
  while [ "$#" != '0' ]; do

    local file="$1";

    if [ "$path" = '/home/jj5/desktop' ]; then

      local strip='/home/jj5/desktop//';

      file="${file#*$strip*}";

    fi;

    file_list+=("$file");

    # 2019-03-26 jj5 - we build $name_list to escape double quotes and dollar
    # signs in file names for reporting (below)...
    #
    local name=( "${file//\"/\\\"}" );

    name_list+=( "${name//\$/\\\$}" );

    shift;

  done;

  cat <<EOF > "$archive_note"
Arch: $archive_path
Date: $date
User: $user
Host: $host
Path: $path
File: $( printf '"%s" ' "${name_list[@]}" | sed -e 's/[[:space:]]*$//' )
Type: $archive_type
Mode: path
EOF

  lx_run $bundler

  cat "$archive_path/archive-note.txt"

  #echo "bundler: $bundler";
  #echo "archive_type: $archive_type";

  if [ "$archive_type" == 'remove' ]; then

    #echo "check_path: $check_path";
    #echo "PWD: $PWD";

    if [ "$check_path" != "$PWD" ]; then

      lx_fail "$LX_EXIT_BAD_ENVIRONMENT" "will not delete archived files because path changed from '$check_path' to '$PWD'.";

    fi;

    if sudo -v 2>/dev/null; then

      sudo rm -rf "${file_list[@]}";

    else

      rm -rf "${file_list[@]}";

    fi;

  fi;

  # 2024-02-18 jj5 - I think this forces the desktop to refresh..?
  #
  if [ -d "$HOME/desktop" ]; then
    local finish="$HOME/desktop/finish.tmp";
    touch "$finish";
    rm "$finish"
  fi;

}

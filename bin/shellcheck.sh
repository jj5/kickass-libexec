#!/bin/bash

main() {

  set -euo pipefail;

  find . -type f -name '*.sh' -print0 |
  while IFS= read -r -d '' file; do
    while true; do
      if process_file "$file"; then
          break
      fi
      if ! shellcheck --color=always "$file" >/dev/null; then
        echo;
        echo "processing: $file";
        read -rp "File still has errors, process again? [Y/n] " answer < /dev/tty;
        case "$answer" in
          [Yy]|[Yy][Ee][Ss]) ;&
          '')
            continue;
            ;;
          [Nn]|[Nn]|[Oo])
            true;
            ;;
          *)
            echo "Unsupported response." 2>&1
            exit 1;
            ;;
        esac
      fi;
      if ! shellcheck --color=always "$file" >/dev/null; then
        echo;
        echo "finished with: $file";
        read -rp "Do you want to continue? [Y/n] " answer < /dev/tty;
        case "$answer" in
          [Yy]|[Yy][Ee][Ss]) ;&
          '')
            break;
            ;;
          [Nn]|[Nn]|[Oo])
            echo "Exiting.";
            exit 0;
            ;;
          *)
            echo "Unsupported response." 2>&1
            exit 1;
            ;;
        esac
      fi;
    done;
  done;

}

process_file() {

  local file="$1";

  clear;

  if shellcheck --color=always "$file" >/dev/null 2>&1; then
    return 0;
  fi;

  if ! shellcheck --color=always "$file" | less -R; then
    true;
  fi;

  if shellcheck --color=always "$file" >/dev/null; then
    return 0;
  fi

  return 1;

}

main "$@";


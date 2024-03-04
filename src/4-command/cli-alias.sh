#!/bin/bash

alias ll='ls -alh'

alias ..='builtin pushd .. >/dev/null';

alias cdl='pushd "$( ls -td */ | head -n1 )" >/dev/null';

alias s='sudo -s';

alias srv='pushd /srv >/dev/null && [ "$USER" == "root" ] || sudo -s';

alias sm='pushd ~/repo/git/staticmagic >/dev/null';

alias asa='pushd /etc/apache2/sites-available >/dev/null';

alias sar='sudo service apache2 restart';

alias etc='cd /etc && sudo -s';

alias archive="$LX_DIR_BIN/lx-archive.sh";
alias archive-copy="$LX_DIR_BIN/lx-archive-copy.sh";
alias archive-file="$LX_DIR_BIN/lx-archive-file.sh";
alias archive-file-copy="$LX_DIR_BIN/lx-archive-file-copy.sh";

alias rt="$LX_DIR_BIN/lx-run-tests.sh";

alias maint="$LX_DIR_BIN/lx-maint.sh";

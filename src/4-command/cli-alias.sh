#!/bin/bash

alias ll='ls -alh'

alias ..='builtin pushd .. >/dev/null';

alias cdl='pushd "$( ls -td */ | head -n1 )" >/dev/null';

alias reeb='sudo reboot';
alias shutd='sudo shutdown -h now';

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

# 2024-07-16 jj5 - OLD: this is a function now...
#alias maint="$LX_DIR_BIN/lx-maint.sh";

# 2024-03-04 jj5 - NOTE: pass the disk device, e.g. /dev/sda
alias disk-off='sudo udisksctl power-off -b';

alias commit='time bin/dev/commit.sh';
alias deploy='time bin/admin/deploy.sh';
alias push='time bin/dev/push.sh';

alias list-open="$LX_DIR_BIN/lx-netstat-list-open.sh";

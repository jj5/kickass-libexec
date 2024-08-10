#!/bin/bash

# 2024-02-18 jj5 - source this file from your bashrc script to get the interactive environment.

LX_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && realpath . )";
LX_DIR_BIN="$LX_DIR/bin";
LX_DIR_ETC="$LX_DIR/etc";
LX_DIR_INC="$LX_DIR/inc";
LX_DIR_SRC="$LX_DIR/src";

[ -d "$LX_DIR_BIN" ] || { echo "error: LX_DIR_BIN not found: $LX_DIR_BIN"; exit 40; }
[ -d "$LX_DIR_ETC" ] || { echo "error: LX_DIR_ETC not found: $LX_DIR_ETC"; exit 40; }
[ -d "$LX_DIR_INC" ] || { echo "error: LX_DIR_INC not found: $LX_DIR_INC"; exit 40; }
[ -d "$LX_DIR_SRC" ] || { echo "error: LX_DIR_SRC not found: $LX_DIR_SRC"; exit 40; }

source "$LX_DIR_INC/lib.sh";

source "$LX_DIR_SRC/4-command/cli-function.sh";

source "$LX_DIR_SRC/4-command/cli-alias.sh";

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -alh'
#alias l='ls $LS_OPTIONS -lA'

# Some more alias to avoid making mistakes:
[ "$USER" == "root" ] && {
  alias rm='rm -i'
  alias cp='cp -i'
  alias mv='mv -i'
}

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=-1
HISTFILESIZE=-1

for file in git-completion.bash git-prompt.sh; do

  test -f /home/jj5/bin/git/$file && source /home/jj5/bin/git/$file;

done


# 2024-02-03 jj5 - colour prompt that I like...
export PS1='-------------------\n${debian_chroot:+($debian_chroot)}\d \t [bash:\V jobs:\j error:$? time:$SECONDS]\n\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]$PWD\[\033[00m\]\n\[\033[1;31m\]\$\[\033[00m\] '

test -f /home/jj5/bin/git/git-prompt.sh && {

  export PS1='-------------------\n${debian_chroot:+($debian_chroot)}\d \t [bash:\V jobs:\j error:$? time:$SECONDS]\n\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]$PWD\[\033[00m\]\n\[\033[1;31m\]$(__git_ps1 "(%s) ")\$\[\033[00m\] ';

}

# 2023-12-29 jj5 - set the Konsole window title
echo -ne "\033]2;$USER@$HOSTNAME\007" >&2



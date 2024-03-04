#!/bin/bash

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

# Some more alias to avoid making mistakes:
[ "$USER" == "root" ] && {
  alias rm='rm -i'
  alias cp='cp -i'
  alias mv='mv -i'
}

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=-1
HISTFILESIZE=-1

# 2024-02-03 jj5 - colour prompt that I like...
PS1='-------------------\n${debian_chroot:+($debian_chroot)}\d \t [bash:\V jobs:\j error:$? time:$SECONDS]\n\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]$PWD\[\033[00m\]\n\[\033[1;31m\]\$\[\033[00m\] '

# 2023-12-29 jj5 - set the Konsole window title
echo -ne "\033]2;$USER@$HOSTNAME\007" >&2

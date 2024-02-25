#!/bin/bash

# 2024-02-18 jj5 - SEE: ANSI escape codes: https://stackoverflow.com/a/5947802/868138
# 2024-02-18 jj5 - NOTE: 'L' is for 'light' and 'D' is for 'dark'...
LX_BLACK='\033[m';
LX_RED='\033[0;31m';
LX_GREEN='\033[0;32m';
LX_BROWN='\033[0;33m';
LX_BLUE='\033[0;34m';
LX_PURPLE='\033[0;35m';
LX_CYAN='\033[0;36m';
LX_LGRAY='\033[0;37m';
LX_DGRAY='\033[1;30m';
LX_LRED='\033[1;31m';
LX_LGREEN='\033[1;32m';
LX_YELLOW='\033[1;33m';
LX_LBLUE='\033[1;34m';
LX_LPURPLE='\033[1;35m';
LX_LCYAN='\033[1;36m';
LX_WHITE='\033[1;37m';
LX_END='\033[0m'; # No Colour

# 2024-02-18 jj5 - clear the current line...
LX_CLEAR='\033[K';

# 2024-02-18 jj5 - colour aliases...
LX_ORANGE=$LX_BROWN;
LX_LGREY=$LX_LGRAY;
LX_DGREY=$LX_DGRAY;

#!/bin/bash

# 2018-03-05 jj5 - SEE: colorize-web-logs.sh documentation:
# https://www.jj5.net/sixsigma/JJ5-bin#colorize-web-logs.sh

# 2018-03-05 jj5 - this is a standalone script (the only dependecy is on the
# GNU 'sed' program) which colourises custom Apache2 web logs. See the doco
# on the above link for details.

# 2018-03-05 jj5 - the ESC character (dec 27, hex 1B)...
#
ESC=$( printf '\033' );

# 2018-03-05 jj5 - the various colour codes...
#
BLACK="${ESC}[m";
RED="${ESC}[0;31m";
GREEN="${ESC}[0;32m";
BROWN="${ESC}[0;33m";
BLUE="${ESC}[0;34m";
PURPLE="${ESC}[0;35m";
CYAN="${ESC}[0;36m";
LGRAY="${ESC}[0;37m";
DGRAY="${ESC}[1;30m";
LRED="${ESC}[1;31m";
LGREEN="${ESC}[1;32m";
YELLOW="${ESC}[1;33m";
LBLUE="${ESC}[1;34m";
LPURPLE="${ESC}[1;35m";
LCYAN="${ESC}[1;36m";
WHITE="${ESC}[1;37m";
END="${ESC}[0m"; # No Colour

# 2017-07-06 jj5 - colour aliases...
ORANGE="$BROWN";
LGREY="$LGRAY";
DGREY="$DGRAY";

# 2018-03-05 jj5 - NOTE: usually I would limit source code lines (such as
# below) to maximum 80 columns, but it didn't seem practical for these sed
# scripts, so probably best if you maximise your text editor for these...

#
# 2018-03-03 jj5 - these format the 'tail' headers, like: ==> whatever <==
#

access_log="s_^(==>) ([^:]+): ([^:]+): ([^:]+): ([^ ]+) \(([^\)]?)\): (access.log) (<==)\$_${WHITE}\\1 \\2: \\3:${END} ${YELLOW}\\4${END}: ${LGREEN}\\5${END} (${CYAN}\\6${END}): ${WHITE}\\7 \\8${END}_";
other_log="s_^(==>) ([^:]+): ([^:]+): ([^:]+): ([^ ]+) \(([^\)]?)\): (other\_vhosts\_access.log) (<==)\$_${RED}\\1 \\2: \\3:${END} ${YELLOW}\\4${END}: ${LGREEN}\\5${END} (${CYAN}\\6${END}): ${RED}\\7 \\8${END}_";
error_log="s_^(==>) ([^:]+): ([^:]+): ([^:]+): ([^ ]+) \(([^\)]?)\): (error.log) (<==)\$_${RED}\\1 \\2: \\3:${END} ${YELLOW}\\4${END}: ${LGREEN}\\5${END} (${CYAN}\\6${END}): ${RED}\\7 \\8${END}_";

#
# 2018-03-05 jj5 - these format the request URI as a fully qualified URL...
#

http_443="s_^([^:]+: [^ ]+ [^ ]+ [^ ]+ \\[.*\\]) ([^:]+):443 ([^ ]+ \"[^ ]+) ([^ ]+) (.*)\$_\\1 \\2:443 \\3 https://\\2\\4 \\5_";
http_80="s_^([^:]+: [^ ]+ [^ ]+ [^ ]+ \\[.*\\]) ([^:]+):80 ([^ ]+ \"[^ ]+) ([^ ]+) (.*)\$_\\1 \\2:80 \\3 http://\\2\\4 \\5_";
http_8080="s_^([^:]+: [^ ]+ [^ ]+ [^ ]+ \\[.*\\]) ([^:]+):8080 ([^ ]+ \"[^ ]+) ([^ ]+) (.*)\$_\\1 \\2:8080 \\3 http://\\2:8080\\4 \\5_";

#
# 2018-03-03 jj5 - these format based on HTTP status and server port
#

http_2xx_443="s_^(2[^:]+): ([^ ]+) ([^ ]+ [^ ]+) (\\[.*\\]) ([^:]*):443 ([^ ]+) \"([^\"]+)\" (.*)_${LGREEN}\\1${END}: ${PURPLE}\\4${END} ${WHITE}\\2${END} ${ORANGE}\\3${END} ${LGREEN}https://\\5:443${END} \\6 ${ORANGE}\"\\7\"${END} \\8_";
http_2xx="s_^(2[^:]+): ([^ ]+) ([^ ]+ [^ ]+) (\\[.*\\]) ([^:]*):([^ ]*) ([^ ]+) \"([^\"]+)\" (.*)_${LGREEN}\\1${END}: ${PURPLE}\\4${END} ${WHITE}\\2${END} ${ORANGE}\\3${END} ${RED}http://\\5:\\6${END} \\7 ${ORANGE}\"\\8\"${END} \\9_";
http_3xx_443="s_^(3[^:]+): ([^ ]+) ([^ ]+ [^ ]+) (\\[.*\\]) ([^:]*):443 ([^ ]+) \"([^\"]+)\" (.*)_${CYAN}\\1${END}: ${PURPLE}\\4${END} ${WHITE}\\2${END} ${ORANGE}\\3${END} ${LGREEN}https://\\5:443${END} \\6 ${ORANGE}\"\\7\"${END} \\8_";
http_3xx="s_^(3[^:]+): ([^ ]+) ([^ ]+ [^ ]+) (\\[.*\\]) ([^:]*):([^ ]*) ([^ ]+) \"([^\"]+)\" (.*)_${CYAN}\\1${END}: ${PURPLE}\\4${END} ${WHITE}\\2${END} ${ORANGE}\\3${END} ${RED}http://\\5:\\6${END} \\7 ${ORANGE}\"\\8\"${END} \\9_";
http_xxx_443="s_^([^:]+): ([^ ]+) ([^ ]+ [^ ]+) (\\[.*\\]) ([^:]*):443 ([^ ]+) \"([^\"]+)\" (.*)_${RED}\\1${END}: ${PURPLE}\\4${END} ${WHITE}\\2${END} ${ORANGE}\\3${END} ${LGREEN}https://\\5:443${END} \\6 ${ORANGE}\"\\7\"${END} \\8_";
http_xxx="s_^([^:]+): ([^ ]+) ([^ ]+ [^ ]+) (\\[.*\\]) ([^:]*):([^ ]*) ([^ ]+) \"([^\"]+)\" (.*)_${RED}\\1${END}: ${PURPLE}\\4${END} ${WHITE}\\2${END} ${ORANGE}\\3${END} ${RED}http://\\5:\\6${END} \\7 ${ORANGE}\"\\8\"${END} \\9_";

#
# 2018-03-03 jj5 - these do some basic formatting for error content
#

error_svn="s_^(svn: .*)\$_${RED}\\1${END}_";
error_4="s_^(\\[.*\\]) (\\[.*\\]) (\\[.*\\]) (\\[.*\\]) (.*)_${PURPLE}\\1 ${RED}\\2 ${ORANGE}\\3 ${YELLOW}\\4 ${RED}\\5${END}_";
error_3="s_^(\\[.*\\]) (\\[.*\\]) (\\[.*\\]) (.*)_${PURPLE}\\1 ${RED}\\2 ${ORANGE}\\3 ${RED}\\4${END}_";
error_default="s_^(\\[.*\\]) (.*)_${PURPLE}\\1 ${RED}\\2${END}_";

#
# 2018-03-03 jj5 - these do miscellaneous formating
#

# 2018-03-03 jj5 - format the HTTP user agent as cyan...
#
user_agent="s_(\"[^\"]*\")\$_${CYAN}\\1${END}_";

# 2018-03-03 jj5 - make traffic from John's house dark gray because we're probably less interested in that...
#
# 2019-02-26 jj5 - OLD: old IP address...
#home="s_${ESC}\\[1;37m(122\\.148\\.216\\.191)${ESC}_${DGRAY}\\1${ESC}_";
# 2019-02-26 jj5 - NEW: new Dodo nbn address...
home="s_${ESC}\\[1;37m(139\\.218\\.130\\.78)${ESC}_${DGRAY}\\1${ESC}_";
# 2019-02-26 jj5 - END

# 2018-03-03 jj5 - we gray out localhost too...
#
localhost="s_${ESC}\\[1;37m(127\\.0\\.0\\.1)${ESC}_${DGRAY}\\1${ESC}_";

sed -r -u \
  -e "$access_log" \
  -e "$other_log" \
  -e "$error_log" \
  -e "$http_443" \
  -e "$http_80" \
  -e "$http_8080" \
  -e "$http_2xx_443" \
  -e "$http_2xx" \
  -e "$http_3xx_443" \
  -e "$http_3xx" \
  -e "$http_xxx_443" \
  -e "$http_xxx" \
  -e "$error_svn" \
  -e "$error_4" \
  -e "$error_3" \
  -e "$error_default" \
  -e "$user_agent" \
  -e "$home" \
  -e "$localhost" \
  ;


#!/bin/bash

# 2024-07-16 jj5 - the point of this function is to delay for four hours around daylight savings time change. It is
# integrated as part of the framework and will be called automatically before main() is called.

# 2024-07-16 jj5 - NOTE: this code hasn't been well tested.

lx_daylight() {

  # 2024-07-16 jj5 - get the current timestamp
  #
  local current_timestamp=$( date +%s );

  # 2024-07-16 jj5 - get the current offset in seconds from UTC
  #
  local current_offset=$( date +%z | awk '{print ($1 / 100) * 3600}' );

  # 2024-07-16 jj5 - calculate the timestamps plus or minus two hours from now
  #
  local two_hours_before=$((  current_timestamp - 2 * 3600 ));
  local two_hours_later=$((   current_timestamp + 2 * 3600 ));

  # 2024-07-16 jj5 - get the offsets in seconds from UTC for plus or minus two hours from now
  #
  local two_hours_before_offset=$(  date -d @${two_hours_before}  +%z | awk '{print ($1 / 100) * 3600}');
  local two_hours_later_offset=$(   date -d @${two_hours_later}   +%z | awk '{print ($1 / 100) * 3600}');

  # 2024-07-16 jj5 - check if the offset changes within two hours either side of the curren time
  #
  if [ "$current_offset" -ne "$two_hours_before_offset" ]; then

    lx_note "daylight savings just changed, will sleep for 2 hours.";

    sleep 2h;
    sleep 30;

  elif [ "$current_offset" -ne "$two_hours_later_offset" ]; then

    lx_note "daylight savings is about to change, will sleep for 4 hours.";

    sleep 4h;
    sleep 30;

  fi

  return 0;

}

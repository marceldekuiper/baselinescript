#!/bin/sh

# SSID we want to connect to
eduroamSSID="eduroam"

# Get current connected SSID
ssid=$(networksetup -getairportnetwork en0 | awk '{print $NF}')
echo "You are currently connected to SSID ${ssid}."

# Only go down this routine if the user is connected to the following SSID's
# Prevents these prompts from appearing at home, etc.
ssidToCheck=("PUBLIC" "Guest_KPN@VUmc")

if [[ ${ssidToCheck[@]} =~ $ssid ]]
then
  # We are connected to one of the SSID's we are testing against, show swift dialog"
  # Prompt user to connect to preferred SSID. Keep nagging till user complies ;-)

  echo "You are connected to one of the SSID's we are testing against, showing prompt."
  
  while [[ "$ssid" != "$eduroamSSID" ]]
  do
      /usr/local/bin/dialog --title "Eduroam" \
      --message "Please switch to $eduroamSSID WiFi network to continue the setup process." \
      --icon "/System/Applications/Utilities/AirPort Utility.app" --mini \
      --ontop \
      /

      ssid=$(networksetup -getairportnetwork en0 | awk '{print $NF}')
      sleep 60
  done
fi

# Checking if we have an actuall working network connection
((count = 30))                           # Maximum number to try.

while [[ $count -ne 0 ]] ; do
    ping -W 1 -c 1 8.8.8.8               # Try once. Pass deadline (-W) param otherwise we wait up to 10 seconds per try.
    rc=$?
    if [[ $rc -eq 0 ]] ; then
        ((count = 1))                    # If okay, flag loop exit.
    else
        sleep 1                          # Minimise network storm.
    fi
    ((count = count - 1))                # So we don't go forever.
    echo "$count and counting"
done

if [[ $rc -eq 0 ]] ; then                # Make final determination.
    echo "Working internet connection established, continue!"
else
    echo "No working internet connection found within 30 tries. Informing user."
    /usr/local/bin/dialog --title "Internet connection" \
      --message "No working internet connection found. Installation of apps will fail." \
      --overlayicon warning \
      --icon "/System/Applications/Utilities/AirPort Utility.app" --mini \
      --ontop \
      /
fi

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
      sleep 5
  done
fi

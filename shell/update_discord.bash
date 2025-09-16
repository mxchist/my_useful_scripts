#!/usr/bin/bash
# Update the Discord using cron. Tested under Ubuntu + Gnome.

# Just take the DISPLAY and DBUS_SESSION_BUS_ADDRESS variables from the current X session and set them below!
export DISPLAY=:1
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus

set -e

notify-send "update discord" "check for updates"
declare redirect_url=$(curl -o /dev/null -w "%{redirect_url}" -silent https://discord.com/api/download?platform=linux\&format=deb)
declare remote_version=$(echo -n "$redirect_url" | sed -E "s/.*\/([^\/]+)\/discord\-\1\.deb/\1/g" - )
declare installed_version=$(dpkg-query --showformat='${Version}' -W discord)
if [[ $installed_version != $remote_version ]]; then
    curl -L --output-dir /tmp -O --remote-header-name --remote-name --silent https://discord.com/api/download?platform=linux\&format=deb;
    notify-send "update discord" "downloading version $remote_version"
    curl -L --output-dir ~/Downloads/ --output discord.deb --silent https://discord.com/api/download?platform=linux\&format=deb;
    notify-send "update discord" "installing version $remote_version"
    sudo dpkg -i ~/Downloads/discord.deb
    rm ~/Downloads/discord.deb
fi

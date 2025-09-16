#!/usr/bin/bash
# Update the Discord using cron. Tested under Ubuntu + Gnome.
set -e

declare remote_version=$(curl -o /dev/null -w "%{redirect_url}" -silent https://discord.com/api/download?platform=linux\&format=deb)
declare installed_version=$(dpkg-query --showformat='${Version}' -W discord)
if [[ $installed_version != $remote_version ]]; then
    curl -L --output-dir ~/Downloads/ --output discord.deb --silent https://discord.com/api/download?platform=linux\&format=deb;
    sudo dpkg -i ~/Downloads/discord.deb
    rm ~/Downloads/discord.deb
fi

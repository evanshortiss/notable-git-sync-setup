#!/bin/bash

# This script is used by the automated sync agent/daemon to synchronise files
# to the configured Git repository.
# 
# You can edit this to alter the sync behaviour if you feel confident that it
# won't have adverse side effects
export LC_ALL=en_US.UTF-8

NPX_AVAILABLE=$(which npx)
NOTIFY_AVAILABLE=$(which notify-send)
NOTABLE_SYNC_DATE=$(date)

echo "Notable sync started at $NOTABLE_SYNC_DATE"

cd ~/.notable/

git status | grep "nothing to commit"

if [ $? -eq 0 ]; then
    echo "Notable sync skipped. Nothing to commit.\n"
    exit 0
fi

git add .
git commit -m "Automatically synced on $NOTABLE_SYNC_DATE"
git pull origin master
git push origin master

echo "Notable sync completed at $(date)\n"

if [ "$OSTYPE" = "darwin" ] 
then
    if [[ -z "$NPX_AVAILABLE" ]]; then
        echo "npx not found. no notification will be displayed"
    elif $1
    then
        # There are multiple ways to trigger notifications, but this one works for
        # me personally. Happy to accept PRs that use AppleScript or other binaries
        npx node-notifier-cli notify --title 'Notable Git Sync' --sound "Glass" \
        --message "Synchronised successfully at $NOTABLE_SYNC_DATE" \
        --icon 'https://notable.app/favicon.ico'
    fi
elif [ "$OSTYPE" = "linux-gnu" ] 
then
    export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/${UID}/bus}" #for notify-send

    if [[ -z "$NOTIFY_AVAILABLE" ]]; then
        echo "notify-send not found. no notification will be displayed"
    elif $1; then
        notify-send "Notable Git Sync" "Synchronised successfully at $NOTABLE_SYNC_DATE" -u normal -t 7500 -i checkbox-checked-symbolic
    fi
fi
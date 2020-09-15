#!/bin/bash

# This script is used by the automated sync agent/daemon to synchronise files
# to the configured Git repository.
# 
# You can edit this to alter the sync behaviour if you feel confident that it
# won't have adverse side effects

NPX_AVAILABLE=$(which npx)
NOTABLE_SYNC_DATE=$(date)

echo "Notable sync started at $NOTABLE_SYNC_DATE"

cd ~/.notable/

git add .
git commit -m "Automatically synced on $NOTABLE_SYNC_DATE"
git pull origin master
git push origin master

echo "Notable sync completed at $(date)\n"

if [[ -z "$NPX_AVAILABLE" ]]; then
    echo "npx not found. no notification will be displayed"
else
    # There are multiple ways to trigger notifications, but this one works for
    # me personally. Happy to accept PRs that use AppleScript or other binaries
    npx node-notifier-cli notify --title 'Notable Git Sync' --sound "Glass" \
    --message "Synchronised successfully at $NOTABLE_SYNC_DATE" \
    --icon 'https://notable.app/favicon.ico'
fi
#!/bin/bash

# Auto commit and push changes to GitHub
cd "$(dirname "$0")"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
MESSAGE="Auto update on $TIMESTAMP"

echo "Committing changes with message: \"$MESSAGE\""
git add .
git commit -m "$MESSAGE"
git push


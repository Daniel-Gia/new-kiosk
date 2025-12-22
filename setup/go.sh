#!/bin/bash
# setup/go.sh - Remote URL Control

NEW_URL=$1

if [ -z "$NEW_URL" ]; then
    echo "Usage: ./go.sh https://example.com"
    exit 1
fi

# Open the new URL in a clean tab
curl -s -X PUT "http://localhost:9222/json/new?$NEW_URL" > /dev/null

echo "Display updated to: $NEW_URL"

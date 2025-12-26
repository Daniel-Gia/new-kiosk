#!/bin/bash

NEW_URL=$1

if [ -z "$NEW_URL" ]; then
    echo "Usage: ./go.sh https://example.com"
    exit 1
fi

curl -s -X PUT "http://localhost:9222/json/new?$NEW_URL" > /dev/null

echo "Display updated to: $NEW_URL"
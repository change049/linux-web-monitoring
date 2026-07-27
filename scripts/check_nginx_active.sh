#!/bin/bash

STATUS=$(curl -s --max-time 3 http://myapp.local/status) || {
    echo 0
    exit 1
}

ACTIVE=$(echo "$STATUS" | awk '/Active connections/ {print $3}')

if [[ "$ACTIVE" =~ ^[0-9]+$ ]]; then
    echo "$ACTIVE"
else
    echo 0
    exit 1
fi


#!/bin/bash

# usage:
# bash ./webhook.sh "Some text you want to be sent over to Discord"

discord_url="your_discord_webhook_url"

generate_post_data() {
  local content="$1"
  cat <<EOF
{
  "embeds": [{
    "title": "This just in from Semaphore!",
    "description": "$content",
    "color": 45973
  }]
}
EOF
}

if [ -z "$1" ]; then
  echo "Usage: $0 \"Your message here\""
  exit 1
fi

message="$1"

curl -H "Content-Type: application/json" -X POST -d "$(generate_post_data "$message")" "$discord_url"

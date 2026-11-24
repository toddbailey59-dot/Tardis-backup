#!/bin/bash
set -euo pipefail

CRED_FILE="$HOME/.config/git/credentials"
DEFAULT_USER="toddbailey59-dot"

printf 'GitHub username [%s]: ' "$DEFAULT_USER"
read -r user
user=${user:-$DEFAULT_USER}

printf 'Personal access token (input hidden): '
read -rs token
printf '\n'

if [ -z "$token" ]; then
    echo "Token cannot be empty." >&2
    exit 1
fi

mkdir -p "$(dirname "$CRED_FILE")"
umask 077
printf 'https://%s:%s@github.com\n' "$user" "$token" > "$CRED_FILE"
chmod 600 "$CRED_FILE"

echo "Saved HTTPS credential for $user to $CRED_FILE"
echo "You can now push with: ~/tardis-backup/backup.sh \"message\" --push"

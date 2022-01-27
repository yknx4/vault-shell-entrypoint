#!/usr/bin/env bash

set -eu

VAULT_SECRETS_DIR=${VAULT_SECRETS_DIR:='/vault/secrets'}
echo "Attempting to load .env files from ${VAULT_SECRETS_DIR}."

if [ -d "$VAULT_SECRETS_DIR" ]; then
  FILES="${VAULT_SECRETS_DIR}/*.env"
  for f in $FILES
  do
    echo "Processing $f file..."
    # take action on each file. $f store current file name
    source "$f"
  done
else
  echo "$VAULT_SECRETS_DIR is not available. Skipping .env loading."
fi

$@

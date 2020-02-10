#!/bin/bash

set -e
set -o pipefail

# Ensure that the GITHUB_TOKEN secret is included
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

# Ensure that the file path is present
if [[ -z "$1" ]]; then
  echo "Pass the name of the asset to download"
  exit 1
fi

FILE="$1"

mkdir assets
cd assets

asset_id=$(jq ".release.assets | map(select(.name == \"$FILE\"))[0].id" $GITHUB_EVENT_PATH)
if [ "$asset_id" = "null" ]; then
  echo "ERROR: asset id not found"
  exit 1
fi;

AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
ASSET_URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/assets/${asset_id}"

curl \
  -L \
  -H "${AUTH_HEADER}" \
  -H "Accept:application/octet-stream" \
  -o "${FILE}" \
  "${ASSET_URL}"

unzip "${FILE}"

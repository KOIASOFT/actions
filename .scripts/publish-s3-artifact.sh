#!/bin/bash
shopt -s expand_aliases

test -n "$APP"          || { echo "Variable 'app' missing"; exit 1; }
test -n "$CONFIG_PATH"  || { echo "Variable 'config_path' missing"; exit 2; }
test -n "$LOCAL_FOLDER" || { echo "Variable 'local_folder' missing"; exit 3; }
test -n "$DEBUG"        || { echo "Variable 'debug' missing"; exit 4; }
test -f "$CONFIG_PATH"  || { echo "Config '$CONFIG_PATH' file not found"; exit 5; }
test -f "$CHANGESET"    || { echo "Variable 'changeset' missing"; exit 6; }

source "$(dirname -- "${BASH_SOURCE[0]}")/functions/get-s3-distribution-artifact-info.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/functions/synchronize-folder-with-s3-folder.sh"

declare -A s3_artifact

get-s3-distribution-artifact-info s3_artifact "$CONFIG_PATH" "$APP" "$CHANGESET"

synchronize-folder-with-s3-folder "$LOCAL_FOLDER" "${s3_artifact["destination"]}"

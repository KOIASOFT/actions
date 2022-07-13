#!/bin/bash
shopt -s expand_aliases
set -e

test -n "$APP"                    || { echo "Variable 'app' missing"; exit 1; }
test -n "$CONFIG_PATH"            || { echo "Variable 'config_path' missing"; exit 2; }
test -n "$FILE_PATH"              || { echo "Variable 'file_path' missing"; exit 3; }
test -n "$CHANGESET"              || { echo "Variable 'changeset' missing"; exit 4; }
test -n "$DEBUG"                  || { echo "Variable 'debug' missing"; exit 5; }
test -f "$CONFIG_PATH"            || { echo "Config '$CONFIG_PATH' file not found"; exit 6; }

source "$(dirname -- "${BASH_SOURCE[0]}")/functions/get-s3-lambda-artifact-info.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/functions/copy-file-from-s3.sh"

declare -A s3_lambda_artifact
get-s3-lambda-artifact-info s3_lambda_artifact "$CONFIG_PATH" "$APP" "$CHANGESET"

echo " - name: ${s3_lambda_artifact["name"]}"
echo " - folder: ${s3_lambda_artifact["folder"]}"
echo " - bucket: ${s3_lambda_artifact["bucket"]}"
echo " - changeset: ${s3_lambda_artifact["changeset"]}"
echo " - destination: ${s3_lambda_artifact["destination"]}"

copy-file-from-s3 "${s3_lambda_artifact["destination"]}" "$FILE_PATH"

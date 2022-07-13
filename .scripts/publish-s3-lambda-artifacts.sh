#!/bin/bash
shopt -s expand_aliases
set -e

test -n "$EXCLUDED_APPS"          || { echo "Variable 'excluded_apps' missing"; exit 1; }
test -n "$CONFIG_PATH"            || { echo "Variable 'config_path' missing"; exit 2; }
test -n "$DEBUG"                  || { echo "Variable 'debug' missing"; exit 3; }
test -f "$CONFIG_PATH"            || { echo "Config '$CONFIG_PATH' file not found"; exit 4; }

source "$(dirname -- "${BASH_SOURCE[0]}")/list-available-apps.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/functions/get-s3-lambda-artifact-info.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/functions/copy-file-to-s3.sh"

alias yq='docker run --rm -v $PWD:/workdir mikefarah/yq'

base_pwd=$PWD

for app in "${apps[@]}"; do
  echo "Executing publishing for '$app'"

  declare -A s3_lambda_artifact

  get-s3-lambda-artifact-info s3_lambda_artifact "$CONFIG_PATH" "$app"

  echo " - name: ${s3_lambda_artifact["name"]}"
  echo " - folder: ${s3_lambda_artifact["folder"]}"
  echo " - bucket: ${s3_lambda_artifact["bucket"]}"
  echo " - changeset: ${s3_lambda_artifact["changeset"]}"
  echo " - destination: ${s3_lambda_artifact["destination"]}"

  build_dir="$base_pwd/build/lambda/$app"
  src_dir="${s3_lambda_artifact["folder"]}"
  src_file="$app"
  package_path="$build_dir/${s3_lambda_artifact["changeset"]}.zip"
  mkdir -p $build_dir

  cd $src_dir

  zip -r $package_path $src_file

  copy-file-to-s3 "$package_path" "${s3_lambda_artifact["destination"]}"

  cd $base_pwd
done




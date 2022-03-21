#!/bin/bash

# shellcheck disable=SC2034
function get-s3-distribution-artifact-info() {
  local RETURN_ARRAY_NAME
  local CONFIG_PATH

  RETURN_ARRAY_NAME="$1"
  CONFIG_PATH="$1"

  test -n "$RETURN_ARRAY_NAME" || { echo "Variable 'RETURN_ARRAY_NAME' missing";  exit 110; }
  test -n "$CONFIG_PATH"       || { echo "Variable 'CONFIG_PATH' missing";        exit 111; }
  test -f "$CONFIG_PATH"       || { echo "Config '$CONFIG_PATH' file not found";  exit 112; }

  yq() { docker run --rm -v $PWD:/workdir mikefarah/yq "$@"; }

  declare -n return="$1"

  name_query=".apps.${APP}.name"
  bucket_query=".apps.${APP}.artifact_bucket // .apps.common.artifact_bucket"

  return["bucket"]=$(yq e "$bucket_query" "$CONFIG_PATH")
  return["name"]=$(yq e "$name_query" "$CONFIG_PATH")
  return["version"]=$(git rev-parse --short HEAD)
  return["destination"]="s3://${return["bucket"]}/${return["name"]}/${return["version"]}/"

  test -n "${return["bucket"]}"       || { echo "Output 'bucket' missing";      exit 120; }
  test -n "${return["name"]}"         || { echo "Output 'name' missing";        exit 121; }
  test -n "${return["version"]}"      || { echo "Output 'version' missing";     exit 122; }
  test -n "${return["destination"]}"  || { echo "Output 'destination' missing"; exit 123; }
}

#!/bin/bash

# shellcheck disable=SC2034
function get-s3-distribution-artifact-info() {
  local config_path
  local return_arr

  return_arr="$1"
  config_path="$2"

  test -n "$return_arr"        || { echo "Variable 'return_arr' missing";         exit 110; }
  test -n "$config_path"       || { echo "Variable 'config_path' missing";        exit 111; }
  test -f "$config_path"       || { echo "Config '$config_path' file not found";  exit 112; }

  yq() { docker run --rm -v $PWD:/workdir mikefarah/yq "$@"; }

  declare -n return="$return_arr"

  name_query=".apps.${APP}.name"
  bucket_query=".apps.${APP}.artifact_bucket // .apps.common.artifact_bucket"

  return["bucket"]=$(yq e "$bucket_query" "$config_path")
  return["name"]=$(yq e "$name_query" "$config_path")
  return["version"]=$(git rev-parse --short HEAD)
  return["destination"]="s3://${return["bucket"]}/${return["name"]}/${return["version"]}"

  test -n "${return["bucket"]}"       || { echo "Output 'bucket' missing";      exit 120; }
  test -n "${return["name"]}"         || { echo "Output 'name' missing";        exit 121; }
  test -n "${return["version"]}"      || { echo "Output 'version' missing";     exit 122; }
  test -n "${return["destination"]}"  || { echo "Output 'destination' missing"; exit 123; }
}

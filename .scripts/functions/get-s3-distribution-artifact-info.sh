#!/bin/bash

# shellcheck disable=SC2034
function get-s3-distribution-artifact-info() {
  local config_path
  local return_arr
  local app
  local changeset

  return_arr="$1"
  config_path="$2"
  app="$3"
  changeset="$4"

  test -n "$return_arr"        || { echo "Variable 'return_arr' missing";         exit 110; }
  test -n "$config_path"       || { echo "Variable 'config_path' missing";        exit 111; }
  test -f "$config_path"       || { echo "Config '$config_path' file not found";  exit 112; }
  test -n "$app"               || { echo "Variable '$app' missing";               exit 113; }
  test -n "$changeset"         || { echo "Variable '$changeset' missing";         exit 114; }

  declare -n return="$return_arr"

  yq() { docker run --rm -v $PWD:/workdir mikefarah/yq "$@"; }

  name_query=".apps.${app}.name"
  bucket_query=".apps.${app}.artifact_bucket // .apps.common.artifact_bucket"

  return["bucket"]=$(yq e "$bucket_query" "$config_path")
  return["name"]=$(yq e "$name_query" "$config_path")
  return["changeset"]=$changeset
  return["destination"]="s3://${return["bucket"]}/${return["name"]}/${return["changeset"]}"

  test -n "${return["bucket"]}"       || { echo "Output 'bucket' missing";      exit 120; }
  test -n "${return["name"]}"         || { echo "Output 'name' missing";        exit 121; }
  test -n "${return["changeset"]}"    || { echo "Output 'changeset' missing";   exit 122; }
  test -n "${return["destination"]}"  || { echo "Output 'destination' missing"; exit 123; }
}

#!/bin/bash

# shellcheck disable=SC2034
function get-app-build-info() {
  set -e

  local return_arr
  local config_path
  local app
  local changeset

  return_arr="$1"
  config_path="$2"
  app="$3"
  changeset="$4"

  test -n "$return_arr"        || { echo "Variable 'return_arr' missing";         exit 110; }
  test -n "$config_path"       || { echo "Variable 'config_path' missing";        exit 111; }
  test -f "$config_path"       || { echo "Config '$config_path' file not found";  exit 112; }
  test -n "$app"               || { echo "Variable 'app' missing";                exit 113; }

  declare -n return="$return_arr"

  function yq() { docker run --rm -v $PWD:/workdir mikefarah/yq "$@"; }

  name_query=".apps.${app}.name"
  folder_query=".apps.${app}.folder"
  build_command_query=".apps.${app}.build_command // .apps.common.build_command"
  build_workdir_query=".apps.${app}.build_workdir // .apps.common.build_workdir // \"\""

  if [ -n "$changeset" ]; then
    return["changeset"]="$changeset"
  else
    return["changeset"]=$(git rev-parse --short HEAD)
  fi

  return["name"]=$(yq e -e "$name_query" "$config_path")
  return["folder"]=$(yq e -e "$folder_query" "$config_path")
  return["build_command"]=$(yq e -e "$build_command_query" "$config_path")
  return["build_workdir"]=$(yq e -e "$build_workdir_query" "$config_path")

  test -n "${return["build_command"]}"       || { echo "Output 'build_command' missing";    exit 120; }
  test -n "${return["name"]}"                || { echo "Output 'name' missing";             exit 121; }
  test -n "${return["folder"]}"              || { echo "Output 'folder' missing";           exit 122; }
  test -n "${return["changeset"]}"           || { echo "Output 'changeset' missing";        exit 123; }
}

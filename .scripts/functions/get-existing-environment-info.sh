#!/bin/bash

function get-existing-environment-info() {
  set -e

  local return_arr
  local target
  local config_path

  return_arr="$1"
  account="$2"
  environment="$3"
  config_path="$4"

  test -n "$account"            || { echo "Variable 'account' missing";         exit 1; }
  test -n "$environment"        || { echo "Variable 'account' missing";         exit 2; }
  test -n "$return_arr"         || { echo "Variable 'return_arr' missing";      exit 3; }
  test -n "$config_path"        || { echo "Variable 'config_path' missing";     exit 4; }
  test -f "$config_path"        || { echo "File '$config_path' missing";        exit 5; }

  declare -n return="$return_arr"

  yq() { docker run --rm -v $PWD:/workdir mikefarah/yq "$@"; }
  common_property() { echo ".accounts.$account.common.$1"; }
  env_property() { echo ".accounts.$account.environments.$environment.$1"; }

  common_keys=$(yq e ".accounts.$account.common | keys" $config_path | egrep -v "^[[:space:]]*#|^[[:space:]]*$" | sed 's/^- //' | sed -z 's/\n/ /g')
  env_keys=$(yq e ".accounts.$account.environments.$environment | keys" $config_path | egrep -v "^[[:space:]]*#|^[[:space:]]*$" | sed 's/^- //' | sed -z 's/\n/ /g')

  for key in $common_keys; do
    query=$(common_property $key)
    value=$(yq e "$query" $config_path)
    return["$key"]=$value
  done

  for key in $env_keys; do
    query=$(env_property $key)
    value=$(yq e "$query" $config_path)
    return["$key"]=$value
  done
}

#!/bin/bash

function get-existing-account-info() {
  set -e

  local return_arr
  local target
  local config_path

  return_arr="$1"
  account="$2"
  config_path="$3"

  test -n "$account"             || { echo "Variable 'account' missing";          exit 1; }
  test -n "$return_arr"         || { echo "Variable 'return_arr' missing";      exit 2; }
  test -n "$config_path"        || { echo "Variable 'config_path' missing";     exit 3; }
  test -f "$config_path"        || { echo "File '$config_path' missing";        exit 4; }

  declare -n return="$return_arr"

  if [ -f "$config_path" ]; then
    yq() { docker run --rm -v $PWD:/workdir mikefarah/yq "$@"; }
    property() { echo ".accounts.$account.common.$1"; }

    keys=$(yq e ".accounts.$account.common | keys" $config_path | sed 's/^- //' | sed -z 's/\n/ /g')

    for key in $keys; do
      query=$(property $key)
      value=$(yq e "$query" $config_path)
      return["$key"]=$value
    done
  fi
}

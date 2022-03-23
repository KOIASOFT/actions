#!/bin/bash

function get-deployment-environment-info() {
  local return_arr
  local target
  local config_path

  return_arr="$1"
  target="$2"
  config_path="$3"

  test -n "$target"             || { echo "Variable 'target' missing";          exit 1; }
  test -n "$return_arr"         || { echo "Variable 'return_arr' missing";      exit 2; }

  declare -n return="$return_arr"

  return["account"]=$(cut -d '-' -f 1,2 <<< "$target")
  return["environment"]=$(cut -d '-' -f 3- <<< "$target")

  test -n "${return["account"]}"             || { echo "Output 'account' missing";              exit 50; }
  test -n "${return["environment"]}"         || { echo "Output 'environment' missing";          exit 51; }

  if [ -f "$config_path" ]; then
    yq() { docker run --rm -v $PWD:/workdir mikefarah/yq $@; }
    property() { echo ".accounts.${return["account"]}.environments.${return["environment"]}.$1 || .accounts.${return["account"]}.common.$1"; }

    dns_zone_id_query=$(property 'dns_zone_id')
    domain_name_query=$(property 'domain_name')
    tf_role_arn_query=$(property 'tf_role_arn')

    return["dns_zone_id"]=$(yq e "$dns_zone_id_query" "$config_path")
    return["domain_name"]=$(yq e "$domain_name_query" "$config_path")
    return["tf_role_arn"]=$(yq e "$tf_role_arn_query" "$config_path")

    test -n "${return["dns_zone_id"]}"         || { echo "Output 'dns_zone_id' missing";          exit 52; }
    test -n "${return["domain_name"]}"         || { echo "Output 'domain_name' missing";          exit 53; }
    test -n "${return["tf_role_arn"]}"         || { echo "Output 'tf_role_arn' missing";          exit 54; }
  fi
}

#!/bin/bash

# shellcheck disable=SC2154
# shellcheck disable=SC2140
function get-and-prepare-s3-config() {
  set -e

  local return_arr
  local s3_app_config_file
  local s3_env_config_file
  local changeset

  return_arr="$1"
  s3_app_config_file="$2"
  s3_env_config_file="$3"
  changeset="$4"

  test -n "$return_arr"              || { echo "Variable 'return_arr' missing";              exit 110; }
  test -n "$s3_app_config_file"      || { echo "Variable 's3_app_config_file' missing";      exit 111; }
  test -n "$s3_env_config_file"      || { echo "Variable 's3_env_config_file' missing";      exit 112; }
  test -n "$changeset"               || { echo "Variable 'changeset' missing";               exit 113; }

  declare -n return="$return_arr"

  folder=$(mktemp -d -p "$PWD" s3-dist-cfg-XXXXXXXX)

  app_cfg_file_name=$(egrep -o "[^/]+$" <<< "$s3_app_config_file")
  env_cfg_file_name=$(egrep -o "[^/]+$" <<< "$s3_env_config_file")

  app_cfg_file_local_path="$folder/$app_cfg_file_name"
  env_cfg_file_local_path="$folder/$env_cfg_file_name"

  aws s3 cp "${s3_app_config_file}" "$app_cfg_file_local_path"
  aws s3 cp "${s3_env_config_file}" "$env_cfg_file_local_path"

  echo "REACT_APP_CHANGESET_ID=$changeset}" >> "$env_cfg_file_local_path"
  echo "" >> "$env_cfg_file_local_path"

  while IFS= read -r line
  do
        parts=(${line//=/ })
        key=$(echo ${parts[0]} | sed 's;/;\\/;g')
        value=$(echo ${parts[1]} | sed 's/"//g' | sed 's;/;\\/;g')

        command="s/\%$key\%/$value/g"

        sed -i $command $app_cfg_file_local_path
  done < "$env_cfg_file_local_path"

  return["cfg_file_path"]="$app_cfg_file_local_path"
}

#!/bin/bash

function deploy-build-to-s3-folder() {
  local source_s3_path
  local dest_s3_path
  local exclude
  local config_file_path
  local cf_distribution_id

  source_s3_path="$1"
  dest_s3_path="$2"
  exclude="$3"
  config_file_path="$4"
  cf_distribution_id="$5"

  test -n "$source_s3_path"          || { echo "Variable 'source_s3_path' missing";     exit 101; }
  test -n "$dest_s3_path"            || { echo "Variable 'dest_s3_path' missing";       exit 102; }
  test -n "$exclude"                 || { echo "Variable 'exclude' missing";            exit 103; }
  test -n "$config_file_path"        || { echo "Variable 'config_file_path' missing";   exit 104; }
  test -f "$config_file_path"        || { echo "File '$config_file_path' missing";      exit 105; }
  test -n "$cf_distribution_id"      || { echo "File 'cf_distribution_id' missing";     exit 106; }

  aws s3 sync --acl bucket-owner-full-control --exclude "$exclude" --delete "$source_s3_path" "$dest_s3_path"
  aws s3 cp --acl bucket-owner-full-control "$config_file_path" "$dest_s3_path"
  aws cloudfront create-invalidation --distribution-id "$cf_distribution_id" --paths "/*"
}

function deploy-build-to-s3-folder-role() {
  source "$(dirname -- "${BASH_SOURCE[0]}")/execute-role-aws.sh"

  local role
  local source_s3_path
  local dest_s3_path
  local exclude
  local config_file_path
  local cf_distribution_id

  role="$1"
  source_s3_path="$2"
  dest_s3_path="$3"
  exclude="$4"
  config_file_path="$5"
  cf_distribution_id="$6"

  test -n "$role"                    || { echo "Variable 'role' missing";               exit 101; }
  test -n "$source_s3_path"          || { echo "Variable 'source_s3_path' missing";     exit 102; }
  test -n "$dest_s3_path"            || { echo "Variable 'dest_s3_path' missing";       exit 103; }
  test -n "$exclude"                 || { echo "Variable 'exclude' missing";            exit 104; }
  test -n "$config_file_path"        || { echo "Variable 'config_file_path' missing";   exit 105; }
  test -f "$config_file_path"        || { echo "File '$config_file_path' missing";      exit 106; }
  test -n "$cf_distribution_id"      || { echo "File 'cf_distribution_id' missing";     exit 107; }

  execute-role-aws "$role" "s3-folder-sync" s3 sync --acl bucket-owner-full-control --exclude "$exclude" --delete "$source_s3_path" "$dest_s3_path"
  execute-role-aws "$role" "s3-folder-cfg-copy" s3 cp --acl bucket-owner-full-control "$config_file_path" "$dest_s3_path"
  execute-role-aws "$role" "clear-cf-dist-cache" cloudfront create-invalidation --distribution-id "$cf_distribution_id" --paths "/*"
}
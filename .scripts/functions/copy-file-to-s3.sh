#!/bin/bash

function copy-file-to-s3() {
  set -e

  local local_file
  local destination_file

  local_file="$1"
  destination_file="$2"

  test -n "$local_file"            || { echo "Variable 'local_file' missing";       exit 101; }
  test -n "$destination_file"      || { echo "Variable 'destination_file' missing"; exit 102; }

  aws s3 cp --acl bucket-owner-full-control "$local_file" "$destination_file"
}

function copy-file-to-s3-role() {
  source "$(dirname -- "${BASH_SOURCE[0]}")/execute-role-aws.sh"

  local role
  local local_file
  local destination_file

  role="$1"
  local_file="$2"
  destination_file="$3"

  test -n "$role"                  || { echo "Variable 'role' missing";                 exit 101; }
  test -n "$local_file"            || { echo "Variable 'local_file' missing";         exit 102; }
  test -n "$destination_file"      || { echo "Variable 'destination_file' missing";   exit 103; }

  execute-role-aws "$role" "s3-copy-file-sync" s3 cp --acl bucket-owner-full-control "$local_file" "$destination_file"
}
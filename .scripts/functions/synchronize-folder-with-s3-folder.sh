#!/bin/bash

function synchronize-folder-with-s3-folder() {
  local local_folder
  local destination_folder

  local_folder="$1"
  destination_folder="$2"

  test -n "$local_folder"            || { echo "Variable 'local_folder' missing";       exit 101; }
  test -n "$destination_folder"      || { echo "Variable 'destination_folder' missing"; exit 102; }

  aws s3 sync "$local_folder" "$destination_folder"
}

function synchronize-folder-with-s3-folder-role() {
  source "$(dirname -- "${BASH_SOURCE[0]}")/execute-role-aws.sh"

  local role
  local local_folder
  local destination_folder

  role="$1"
  local_folder="$2"
  destination_folder="$3"

  test -n "$role"                    || { echo "Variable 'role' missing";                 exit 101; }
  test -n "$local_folder"            || { echo "Variable 'local_folder' missing";         exit 102; }
  test -n "$destination_folder"      || { echo "Variable 'destination_folder' missing";   exit 103; }

  execute-role-aws "$role" "s3-folder-sync" s3 sync "$local_folder" "$destination_folder"
}
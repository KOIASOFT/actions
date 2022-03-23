#!/bin/bash

function ecr-login() {
  set -e

  local role
  local registry

  registry="$1"

  test -n "$registry"             || { echo "Variable 'registry' missing";  exit 101; }

  aws ecr get-login-password | docker login --username AWS --password-stdin "$registry"
}

function ecr-login-role() {
  set -e

  source "$(dirname -- "${BASH_SOURCE[0]}")/execute-role-aws.sh"

  local role
  local registry

  role="$1"
  registry="$2"

  test -n "$role"                 || { echo "Variable 'role' missing";      exit 101; }
  test -n "$registry"             || { echo "Variable 'registry' missing";  exit 102; }

  OUT=$(execute-role-aws "$role" "ecr-login" ecr get-login-password)
  docker login --username AWS --password-stdin "$registry" <<< "$OUT"
}
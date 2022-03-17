#!/bin/bash

function create-repository-role() {
  repository="$1"

  test -n "$repository"      || { echo "Variable 'repository' missing"; exit 101; }

  aws ecr create-repository --repository-name="$repository"
}

function create-repository-role() {
  source "$(dirname -- "${BASH_SOURCE[0]}")/execute-role-aws.sh"

  role="$1"
  repository="$2"

  test -n "$role"            || { echo "Variable 'role' missing";       exit 101; }
  test -n "$repository"      || { echo "Variable 'repository' missing"; exit 102; }

  execute-role-aws "$role" "create-repository" ecr create-repository --repository-name="$repository"
}
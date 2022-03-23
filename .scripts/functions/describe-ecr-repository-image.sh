#!/bin/bash

function describe-ecr-repository-image() {
  set -e

  local repository
  local tag

  repository="$1"
  tag="$2"

  test -n "$repository"      || { echo "Variable 'repository' missing"; exit 101; }
  test -n "$tag"             || { echo "Variable 'tag' missing";        exit 102; }

  aws ecr describe-images --repository-name="$repository" --image-ids=imageTag="$tag"
}

function describe-ecr-repository-image-role() {
  set -e

  source "$(dirname -- "${BASH_SOURCE[0]}")/execute-role-aws.sh"

  local role
  local repository
  local tag

  role="$1"
  repository="$2"
  tag="$3"

  test -n "$role"            || { echo "Variable 'role' missing";       exit 101; }
  test -n "$repository"      || { echo "Variable 'repository' missing"; exit 102; }
  test -n "$tag"             || { echo "Variable 'tag' missing";        exit 103; }

  execute-role-aws "$role" "describe-ecr-repository-image" ecr describe-images --repository-name="$repository" --image-ids=imageTag="$tag"
}
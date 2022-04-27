#!/bin/bash
source "$(dirname -- "${BASH_SOURCE[0]}")/functions/get-existing-environment-info.sh"

shopt -s expand_aliases

test -n "$ACCOUNT"      || { echo "Variable 'account' missing"; exit 1; }
test -n "$ENVIRONMENT"  || { echo "Variable 'environment' missing"; exit 2; }
test -f "$CONFIG_PATH"  || { echo "Config '$CONFIG_PATH' file not found"; exit 3; }

alias yq='docker run --rm -v $PWD:/workdir mikefarah/yq'

declare -A info

get-existing-environment-info info "$ACCOUNT" "$ENVIRONMENT" "$CONFIG_PATH"

for key in "${!info[@]}"
do
  echo "::set-output name=$key::${info[$key]}"
done


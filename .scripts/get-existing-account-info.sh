#!/bin/bash
source "$(dirname -- "${BASH_SOURCE[0]}")/functions/get-existing-account-info.sh"

shopt -s expand_aliases

test -n "$ACCOUNT"     || { echo "Variable 'account' missing"; exit 1; }
test -f "$CONFIG_PATH" || { echo "Config '$CONFIG_PATH' file not found"; exit 2; }

alias yq='docker run --rm -v $PWD:/workdir mikefarah/yq'

declare -A info

get-existing-account-info info "$ACCOUNT" "$CONFIG_PATH"

for key in "${!info[@]}"
do
  echo "::set-output name=$key::${info[$key]}"
done


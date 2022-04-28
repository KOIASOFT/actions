#!/bin/bash
source "$(dirname -- "${BASH_SOURCE[0]}")/functions/get-existing-environment-info.sh"

shopt -s expand_aliases

output_arr="$1"

test -n "$ACCOUNT"      || { echo "Variable 'account' missing"; exit 1; }
test -n "$ENVIRONMENT"  || { echo "Variable 'environment' missing"; exit 2; }
test -f "$CONFIG_PATH"  || { echo "Config '$CONFIG_PATH' file not found"; exit 3; }
test -n "$output_arr"   || { echo "Variable 'output_arr' missing"; exit 4; }

alias yq='docker run --rm -v $PWD:/workdir mikefarah/yq'

declare -n info="$output_arr"

get-existing-environment-info info "$ACCOUNT" "$ENVIRONMENT" "$CONFIG_PATH"

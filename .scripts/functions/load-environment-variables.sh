#!/bin/bash

function load-environment-variables() {
  local file
  local input
  local prefix

  file="$1"
  input="$2"
  prefix="$3"

  test -n "$file"             || { echo "Variable 'file' missing";   exit 101; }
  test -n "$input"            || { echo "Variable 'input' missing";  exit 102; }

  while IFS= read -r line
  do
    line=$(echo "$line" | xargs)
    input_var="$prefix$line"

    echo "Setting: $input_var"
    echo "$input_var" >> "$file"

  done <<< "$input"
}

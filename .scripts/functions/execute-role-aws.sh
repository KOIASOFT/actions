#!/bin/bash

function aws-role() {
  set -e

  local return_Arr
  local role
  local session

  return_arr=$1
  role=$2
  session=$3

  test -n "$return_arr"   || { echo "Variable 'return_arr' missing";    exit 100; }
  test -n "$role"         || { echo "Variable 'role' missing";    exit 101; }
  test -n "$session"      || { echo "Variable 'session' missing"; exit 102; }

  declare -n return="$return_arr"

  STS_SESSION=$(aws sts assume-role --role-arn "$role" --role-session-name "$session")

  return["AWS_ACCESS_KEY_ID"]=$(jq -r '.Credentials.AccessKeyId' <<< $STS_SESSION)
  return["AWS_SECRET_ACCESS_KEY"]=$(jq -r '.Credentials.SecretAccessKey' <<< $STS_SESSION)
  return["AWS_SESSION_TOKEN"]=$(jq -r '.Credentials.SessionToken' <<< $STS_SESSION)
}
function execute-role-aws() {
  set -e

  local role
  local session
  local command

  role=$1
  session=$2
  command=${*#"$role"}
  command=${command#" "}
  command=${command#"$session "}
  command=${command#" "}

  test -n "$role"         || { echo "Variable 'role' missing";    exit 101; }
  test -n "$session"      || { echo "Variable 'session' missing"; exit 102; }
  test -n "$command"      || { echo "Variable 'command' missing"; exit 103; }

  local STS_SESSION
  local AWS_ACCESS_KEY_ID
  local AWS_SECRET_ACCESS_KEY
  local AWS_SESSION_TOKEN

  STS_SESSION=$(aws sts assume-role --role-arn "$role" --role-session-name "$session")

  AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' <<< $STS_SESSION)
  AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' <<< $STS_SESSION)
  AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' <<< $STS_SESSION)

  AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN aws $command
}
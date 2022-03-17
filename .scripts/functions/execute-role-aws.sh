#!/bin/bash

function execute-role-aws() {
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
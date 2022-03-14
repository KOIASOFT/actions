#!/bin/bash

test -o errexit && SET_E=true || SET_E=false

shopt -s expand_aliases

test -n "$APP"         || { echo "Variable 'app' missing"; exit 1; }
test -n "$CONFIG_PATH" || { echo "Variable 'config_path' missing"; exit 2; }
test -n "$DEBUG"       || { echo "Variable 'debug' missing"; exit 3; }
test -n "$ACCOUNT"     || { echo "Variable 'account' missing"; exit 4; }
test -n "$TAG"         || { echo "Variable 'tag' missing"; exit 5; }
test -f "$CONFIG_PATH" || { echo "Config '$CONFIG_PATH' file not found"; exit 6; }

alias yq='docker run --rm -v $PWD:/workdir mikefarah/yq'

role=$(yq e ".accounts.${ACCOUNT}.common.tf_role_arn" $CONFIG_PATH)
repository=$(yq e ".apps.${APP}.docker_repository" $CONFIG_PATH)

STS_SESSION=$(aws sts assume-role --role-arn "$role" --role-session-name "ecr-image-existence-checker-$APP")

export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' <<< $STS_SESSION)
export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' <<< $STS_SESSION)
export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' <<< $STS_SESSION)

log_file="check-stdout.log"
rm -rf $log_file
set +e

aws ecr create-repository --repository-name="$repository"  >& /dev/null
aws ecr describe-images --repository-name="$repository" --image-ids=imageTag="$TAG" > >(tee -a $log_file) 2> >(tee -a $log_file >&2)

exit_code=$?

test "SET_E" == "true" && set -e || true

if [[ $exit_code == 0 ]]; then
  export exists=true
else
  IMAGE_NOT_FOUND_ENTRIES=$(grep "ImageNotFoundException" $log_file | wc -l)

  if [ $IMAGE_NOT_FOUND_ENTRIES -eq 1 ]; then
    export exists=false;
  else
    exit 7
  fi
fi

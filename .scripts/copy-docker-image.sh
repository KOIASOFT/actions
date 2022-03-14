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
source_registry=$(yq e ".apps.common.docker_registry" $CONFIG_PATH)
destination_registry=$(yq e ".accounts.${ACCOUNT}.common.docker_registry" $CONFIG_PATH)
source_image="${source_registry}/${repository}:$TAG"
destination_image="${destination_registry}/${repository}:$TAG"

docker pull $source_image
SHA=$(docker inspect --format='{{.ID}}' $source_image | awk -F: '{print $2}')
docker tag "$SHA" $destination_image

STS_SESSION=$(aws sts assume-role --role-arn "$role" --role-session-name "ecr-image-shipper-$APP")

export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' <<< $STS_SESSION)
export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' <<< $STS_SESSION)
export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' <<< $STS_SESSION)

unset AWS_PROFILE

login=$(aws ecr get-login)

$login

docker push $destination_image

if [[ $exit_code != 0 ]]; then
  exit 7
fi

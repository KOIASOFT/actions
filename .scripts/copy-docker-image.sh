#!/bin/bash
shopt -s expand_aliases

test -n "$APP"         || { echo "Variable 'app' missing"; exit 1; }
test -n "$CONFIG_PATH" || { echo "Variable 'config_path' missing"; exit 2; }
test -n "$DEBUG"       || { echo "Variable 'debug' missing"; exit 3; }
test -n "$ACCOUNT"     || { echo "Variable 'account' missing"; exit 4; }
test -n "$TAG"         || { echo "Variable 'tag' missing"; exit 5; }
test -f "$CONFIG_PATH" || { echo "Config '$CONFIG_PATH' file not found"; exit 6; }

source "$(dirname -- "${BASH_SOURCE[0]}")/check-docker-image-exists.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/functions/ecr-login.sh"

if [ "$exists" == "true" ]; then
  echo "Image already exists"
  exit 0;
fi

alias yq='docker run --rm -v $PWD:/workdir mikefarah/yq'

role=$(yq e ".accounts.${ACCOUNT}.common.tf_role_arn" $CONFIG_PATH)
repository=$(yq e ".apps.${APP}.docker_repository" $CONFIG_PATH)
source_registry=$(yq e ".apps.common.docker_registry" $CONFIG_PATH)
destination_registry=$(yq e ".accounts.${ACCOUNT}.common.docker_registry" $CONFIG_PATH)
source_image="${source_registry}/${repository}:$TAG"
destination_image="${destination_registry}/${repository}:$TAG"

ecr-login $source_registry

docker pull $source_image
SHA=$(docker inspect --format='{{.ID}}' $source_image | awk -F: '{print $2}')
docker tag "$SHA" $destination_image

ecr-login-role "$role" $destination_registry

docker push $destination_image

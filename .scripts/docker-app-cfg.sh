#!/bin/bash
shopt -s expand_aliases

test -n "$APP"         || { echo "Variable 'app' missing"; exit 1; }
test -n "$CONFIG_PATH" || { echo "Variable 'config_path' missing"; exit 2; }
test -n "$DEBUG"       || { echo "Variable 'debug' missing"; exit 3; }
test -f "$CONFIG_PATH" || { echo "Config '$CONFIG_PATH' file not found"; exit 4; }

alias yq='docker run --rm -v $PWD:/workdir mikefarah/yq'

repository_query=".apps.${APP}.docker_repository"
folder_query=".apps.${APP}.folder"
dockerfile_query=".apps.${APP}.dockerfile // .apps.common.dockerfile"
dockerignore_query=".apps.${APP}.dockerignore // .apps.common.dockerignore"
docker_context_query=".apps.${APP}.docker_context // .apps.common.docker_context // .apps.${APP}.folder"

export docker_image_tag=$(git rev-parse --short HEAD)
export docker_registry=$(yq e '.apps.common.docker_registry' $CONFIG_PATH)
export docker_repository_location_only=$(yq e "$repository_query" $CONFIG_PATH)
export docker_repository="$docker_registry/$docker_repository_location_only"
export docker_image="$docker_repository:$docker_image_tag"
export docker_context=$(yq e "$docker_context_query"  $CONFIG_PATH)
export dockerfile=$(yq e "$dockerfile_query"  $CONFIG_PATH)
export dockerignore=$(yq e "$dockerignore_query"  $CONFIG_PATH)
export app_folder=$(yq e "$folder_query" $CONFIG_PATH)


#!/bin/bash
shopt -s expand_aliases

set -e

test -n "$CONFIG_PATH"   || { echo "Variable 'config_path' missing"; exit 1; }
test -n "$EXCLUDED_APPS" || { echo "Variable 'excluded_apps' missing"; exit 2; }
test -n "$DEBUG"         || { echo "Variable 'debug' missing"; exit 3; }
test -f "$CONFIG_PATH"   || { echo "Config '$CONFIG_PATH' file not found"; exit 4; }

alias yq='docker run --rm -v $PWD:/workdir mikefarah/yq'

. $(dirname -- "${BASH_SOURCE[0]}")/list-available-apps.sh

for app in "${apps[@]}"; do
  echo "Executing Docker build for '$app'"

  APP="$app"

  . $(dirname -- "${BASH_SOURCE[0]}")/docker-app-cfg.sh

  echo " - docker_image: $docker_image"
  echo " - dockerfile: $dockerfile"
  echo " - dockerignore: $dockerignore"
  echo " - docker_contexts: $docker_contexts"
  echo " - build_args:"
  echo "   - APP_FOLDER: $app_folder"
  echo "   - APP: $APP"
  echo "   - CONTAINER_PORT: $container_port"

  if [ "$dockerignore" != "null" ]; then
     cmp --silent $dockerignore $docker_context/.dockerignore || cp $dockerignore $app_folder/.dockerignore
  fi

  build_contexts=""

  for ctx in $docker_contexts; do
    build_contexts="$build_contexts --build-context $ctx"
  done

  aws ecr create-repository --repository-name="$docker_repository_location_only" || true

  docker buildx build --platform linux/amd64 $build_contexts --build-arg=APP=$APP --build-arg=APP_FOLDER=$app_folder --build-arg=CONTAINER_PORT=$container_port -f $dockerfile --push --squash -t $docker_image $app_folder
done

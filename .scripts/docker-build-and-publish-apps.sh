#!/bin/bash
shopt -s expand_aliases

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
  echo " - docker_context: $docker_context"
  echo " - build_args:"
  echo "   - APP_FOLDER: $app_folder"
  echo "   - APP: $APP"
  echo "   - CONTAINER_PORT: $container_port"

  if [ "$dockerignore" != "null" ]; then
     cmp --silent $dockerignore $docker_context/.dockerignore || cp $dockerignore $docker_context/.dockerignore
  fi

  relative_app_folder=$(realpath --relative-to $docker_context ${GITHUB_WORKSPACE}/$app_folder)

  echo "Relative app folder: $relative_app_folder"

  docker build --force-rm --build-arg=APP_FOLDER=$relative_app_folder --build-arg=APP=$APP --build-arg=CONTAINER_PORT=$container_port -f $dockerfile -t $docker_image $docker_context

  aws ecr create-repository --repository-name="$docker_repository_location_only" || true

  docker push $docker_image
done

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

  if [ "$dockerignore" != "null" ]; then
    cp $dockerignore $docker_context
  fi

  docker build --force-rm -f $dockerfile -t $docker_image $docker_context

  aws ecr create-repository --repository-name="$docker_repository_location_only"  >& /dev/null
  docker push $docker_image
done



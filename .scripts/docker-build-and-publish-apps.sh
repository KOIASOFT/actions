#!/bin/bash
shopt -s expand_aliases

test -n "$CONFIG_PATH"   || { echo "Variable 'config_path' missing"; exit 1; }
test -n "$EXCLUDED_APPS" || { echo "Variable 'excluded_apps' missing"; exit 2; }
test -n "$DEBUG"         || { echo "Variable 'debug' missing"; exit 3; }
test -f "$CONFIG_PATH"   || { echo "Config '$CONFIG_PATH' file not found"; exit 4; }

alias yq='docker run --rm -v $PWD:/workdir mikefarah/yq'

#test -f "$CONFIG_PATH" || { echo "Config '$CONFIG_PATH' not found"; exit 1; }

. $(dirname -- "${BASH_SOURCE[0]}")/list-available-apps.sh

for app in "${apps[@]}"; do
  echo "Executing Docker build for '$app'"

  . $(dirname -- "${BASH_SOURCE[0]}")/docker-app-cfg.sh

  echo " - docker_image: $docker_image"
  echo " - dockerfile: $dockerfile"
  echo " - dockerignore: $dockerignore"
  echo " - docker_context: $docker_context"

  if [ "$dockerignore" != "null" ]; then
    cp $dockerignore $docker_context
  fi

  docker build --force-rm -f $dockerfile -t $docker_image $docker_context
done



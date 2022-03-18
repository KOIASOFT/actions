#!/bin/bash
source "$(dirname -- "${BASH_SOURCE[0]}")/functions/create-ecr-repository.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/functions/describe-ecr-repository-image.sh"

shopt -s expand_aliases

test -n "$APP"         || { echo "Variable 'app' missing"; exit 1; }
test -n "$CONFIG_PATH" || { echo "Variable 'config_path' missing"; exit 2; }
test -n "$DEBUG"       || { echo "Variable 'debug' missing"; exit 3; }
test -n "$ACCOUNT"     || { echo "Variable 'account' missing"; exit 4; }
test -n "$TAG"         || { echo "Variable 'tag' missing"; exit 5; }
test -f "$CONFIG_PATH" || { echo "Config '$CONFIG_PATH' file not found"; exit 6; }

alias yq='docker run --rm -v $PWD:/workdir mikefarah/yq'

role=$(yq e ".accounts.${ACCOUNT}.common.tf_role_arn" "$CONFIG_PATH")
repository=$(yq e ".apps.${APP}.docker_repository" "$CONFIG_PATH")

log_file="check-stdout.log"
rm -rf $log_file

create-ecr-repository-role "$role" "$repository" || true
describe-ecr-repository-image-role "$role" "$repository" "$TAG" > >(tee -a $log_file) 2> >(tee -a $log_file >&2) || true

exit_code=$?

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

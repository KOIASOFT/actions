#!/bin/bash
shopt -s expand_aliases

test -n "$EXCLUDED_APPS"          || { echo "Variable 'excluded_apps' missing"; exit 1; }
test -n "$CONFIG_PATH"            || { echo "Variable 'config_path' missing"; exit 2; }
test -n "$DEBUG"                  || { echo "Variable 'debug' missing"; exit 3; }
test -n "$IMAGE"                  || { echo "Variable 'image' missing"; exit 4; }
test -f "$CONFIG_PATH"            || { echo "Config '$CONFIG_PATH' file not found"; exit 5; }

source "$(dirname -- "${BASH_SOURCE[0]}")/list-available-apps.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/functions/get-app-build-info.sh"

alias yq='docker run --rm -v $PWD:/workdir mikefarah/yq'

cur_pwd=$PWD

for app in "${apps[@]}"; do
  echo "Executing build for '$app'"

  APP="$app"

  declare -A build_info
  get-app-build-info build_info "$CONFIG_PATH" "$APP"

  docker pull "$IMAGE"
  workdir="${build_info["build_workdir"]}"
  test -n "$workdir" || workdir=$(docker inspect $IMAGE --format '{{ or .Config.WorkingDir "/root"}}')

  tmpfile=$(mktemp $PWD/${build_info["folder"]}/command-script.XXXXXX)

  echo "#/bin/sh" > $tmpfile
  echo "set -xe" > $tmpfile
  echo "chown -R \$SAVE_UID:\$SAVE_GID ." >> $tmpfile
  echo "find . -type d -exec chmod ug+s {} \;" >> $tmpfile
  cat <<< "${build_info["build_command"]}" >> $tmpfile

  chmod +x $tmpfile
  trap 'rm -rf -- "$tmpfile"' EXIT

  script="-c ./$(basename $tmpfile)"

  out_file="stdout.log"
  err_file="stderr.log"

  run="docker run --entrypoint=/bin/sh --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly -e APP=$APP -w $workdir --mount type=bind,source=/etc/group,target=/etc/group,readonly -e SAVE_UID=$(id -u) -e SAVE_GID=$(id -g) --rm -v $PWD/${build_info["folder"]}:$workdir $IMAGE"

  echo "Running as '$(id -u):' user and '$(id -g)' group"

  $run $script >> >(tee -a $out_file) 2>> >(tee -a $err_file >&2)
done

export out=$(cat $out_file)
export err=$(cat $err_file)



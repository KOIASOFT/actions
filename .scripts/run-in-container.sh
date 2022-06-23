#!/bin/bash
shopt -s expand_aliases

test -n "$COMMAND"   || { echo "Variable 'COMMAND' missing"; exit 1; }
test -n "$IMAGE"     || { echo "Variable 'IMAGE' missing";   exit 2; }

tmpfile=$(mktemp $PWD/command-script.XXXXXX)
cat <<< "$COMMAND" > $tmpfile
chmod +x $tmpfile
trap 'rm -rf -- "$tmpfile"' EXIT

script="-c ./$(basename $tmpfile)"

out_file="stdout.log"
err_file="stderr.log"

docker pull "$IMAGE"

workdir=$(docker inspect $IMAGE --format '{{ or .Config.WorkingDir "/root"}}')

alias run="docker run --entrypoint=/bin/bash --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly --mount type=bind,source=/etc/group,target=/etc/group,readonly -u $(id -u):$(id -g) --rm -v $PWD:$workdir $IMAGE"

echo "Running as '$(id -u):' user and '$(id -g)' group"

run $script > >(tee -a $out_file) 2> >(tee -a $err_file >&2)

export out=$(cat $out_file)
export err=$(cat $err_file)

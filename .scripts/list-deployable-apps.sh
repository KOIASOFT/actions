#!/bin/bash
shopt -s expand_aliases

test -n "$CONFIG_PATH"   || { echo "Variable 'config_path' missing"; exit 1; }
test -n "$DEBUG"         || { echo "Variable 'debug' missing"; exit 2; }
test -f "$CONFIG_PATH"   || { echo "Config '$CONFIG_PATH' file not found"; exit 3; }

test -n "$APPS"          || { echo "Variable 'apps_input' missing"; exit 4; }
test -n "$ACCOUNT"       || { echo "Variable 'account' missing"; exit 5; }
test -n "$ENVIRONMENT"   || { echo "Variable 'environment' missing"; exit 6; }

alias yq='docker run --rm -v $PWD:/workdir mikefarah/yq'

echo "Check '$APPS' apps in '$ENVIRONMENT' environment of '$ACCOUNT' account"

if [ "$APPS" == "all" ]; then
  apps_str=$(yq e '.apps | keys' $CONFIG_PATH | egrep -v "^[[:space:]]*#|^[[:space:]]*$" )
else
  apps_str="$APPS"
fi

apps_list=$(sed 's/^- //' <<< "$apps_str" | sed -z 's/\n/,/g' | sed 's/,$//;s/ //g;s/#.*$//')
IFS=',' read -r -a apps_array <<< "$apps_list"

allowed_apps=()

for app in "${apps_array[@]}"; do
  if [ "$app" != "common" ]; then
      available=$(yq e ".accounts.$ACCOUNT.apps.$app.environments | has(\"$ENVIRONMENT\")" .infrastructure/config.yaml)

      echo "App $app is allowed to be deployed in $ENVIRONMENT: $available"

      if [ "$available" == "true" ]; then
          allowed_apps+=("$app")
      fi
  fi
done

export allowed_apps_list=$(sed "s/ /,/g" <<< "${allowed_apps[@]}")
export allowed_apps_json=$(sed -z 's/\n/"]/;s/,/","/g;s/^/["/' <<< "$allowed_apps_list")

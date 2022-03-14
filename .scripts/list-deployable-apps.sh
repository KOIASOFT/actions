#!/bin/bash
shopt -s expand_aliases

test -n "$CONFIG_PATH"   || { echo "Variable 'config_path' missing"; exit 1; }
test -n "$EXCLUDED_APPS" || { echo "Variable 'excluded_apps' missing"; exit 2; }
test -n "$DEBUG"         || { echo "Variable 'debug' missing"; exit 3; }
test -f "$CONFIG_PATH"   || { echo "Config '$CONFIG_PATH' file not found"; exit 4; }

alias yq='docker run --rm -v $PWD:/workdir mikefarah/yq'

echo "Check '$apps_input' apps in '$environment' environment of '$account' account"

if [ "$apps_input" == "all" ]; then
  apps_str=$(yq e '.apps | keys' $CONFIG_PATH)
else
  apps_str="$apps_input"
fi

apps_list=$(sed 's/^- //' <<< "$apps_str" | sed -z 's/\n/,/g' | sed 's/,$//;s/ //g;s/#.*$//')
IFS=',' read -r -a apps_array <<< "$apps_list"

allowed_apps=()

for app in "${apps_array[@]}"; do
  if [ "$app" != "common" ]; then
      available=$(yq e ".accounts.$account.apps.$app.environments | has(\"$environment\")" .infrastructure/config.yaml)

      echo "App $app is allowed to be deployed in $environment: $available"

      if [ "$available" == "true" ]; then
          allowed_apps+=("$app")
      fi
  fi
done

export allowed_apps_list=$(sed "s/ /,/g" <<< "${allowed_apps[@]}")
export allowed_apps_json=$(sed -z 's/\n/"]/;s/,/","/g;s/^/["/' <<< "$allowed_apps_list")

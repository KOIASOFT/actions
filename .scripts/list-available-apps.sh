#!/bin/bash
shopt -s expand_aliases

test -n "$CONFIG_PATH"   || { echo "Variable 'config_path' missing"; exit 1; }
test -n "$EXCLUDED_APPS" || { echo "Variable 'excluded_apps' missing"; exit 2; }
test -n "$DEBUG"         || { echo "Variable 'debug' missing"; exit 3; }
test -f "$CONFIG_PATH"   || { echo "Config '$CONFIG_PATH' file not found"; exit 4; }

alias yq='docker run --rm -v $PWD:/workdir mikefarah/yq'

test -f "$CONFIG_PATH" || { echo "Config '$CONFIG_PATH' not found"; exit 1; }

apps_str=$(yq e '.apps | keys' $CONFIG_PATH)
apps_list=$(sed 's/^- //' <<< "$apps_str" | sed -z 's/\n/,/g' | sed 's/,$//;s/ //g;s/#.*$//')

IFS=',' read -r -a apps_array <<< "$apps_list"
IFS=',' read -r -a excluded_array <<< "$EXCLUDED_APPS"

apps=()

for app in "${apps_array[@]}"; do
      for excluded in "${excluded_array[@]}"; do
          KEEP=true
          if [[ "$app" == "$excluded" ]]; then
              KEEP=false
              break
          fi
      done

      if ${KEEP}; then
        apps+=($app)
      fi
done

export apps
export apps_csl=$(sed -z "s/ /,/g" <<< "${apps[@]}")
export apps_json=$(sed -z 's/\n/"]/;s/,/","/g;s/^/["/' <<< "$apps_csl")

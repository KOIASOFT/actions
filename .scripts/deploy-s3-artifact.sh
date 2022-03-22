#!/bin/bash
shopt -s expand_aliases

test -n "$APP"                || { echo "Variable 'app' missing";                         exit 1; }
test -n "$ENVIRONMENT"        || { echo "Variable 'environment' missing";                 exit 2; }
test -n "$CONFIG_PATH"        || { echo "Variable 'config_path' missing";                 exit 3; }
test -n "$TERRAGRUNT_FOLDER"  || { echo "Variable 'terragrunt_folder' missing";           exit 4; }
test -n "$CHANGESET"          || { echo "Variable 'changeset' missing";                   exit 5; }
test -n "$DEBUG"              || { echo "Variable 'debug' missing";                       exit 6; }
test -f "$CONFIG_PATH"        || { echo "Config '$CONFIG_PATH' file not found";           exit 7; }
test -d "$TERRAGRUNT_FOLDER"  || { echo "Config '$TERRAGRUNT_FOLDER' folder not found";   exit 8; }

source "$(dirname -- "${BASH_SOURCE[0]}")/get-s3-distribution-artifact-info.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/get-and-prepare-s3-config.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/get-deployment-environment-info.sh"
source "$(dirname -- "${BASH_SOURCE[0]}")/deploy-build-to-s3-folder.sh"

declare -A environment
declare -A s3_artifact
declare -A s3_distribution

get-deployment-environment-info environment "$ENVIRONMENT" "$CONFIG_PATH"
get-s3-distribution-artifact-info s3_artifact "$CONFIG_PATH"
get-cloudfront-distribution-info s3_distribution "$TERRAGRUNT_FOLDER"

s3_app_config_file="${s3_artifact["destination"]}/build/index.html"
s3_env_config_file="${s3_artifact["destination"]}/config/${environment["environment"]}.env"

config_file=$(get-and-prepare-s3-config "$s3_app_config_file" "$s3_env_config_file" "$CHANGESET")

deploy-build-to-s3-folder-role "${environment["role"]}" "${s3_distribution["bucket_url"]}" "index.html" "$config_file"

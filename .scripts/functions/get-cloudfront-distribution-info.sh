#!/bin/bash

# shellcheck disable=SC2034
function get-cloudfront-distribution-info() {
  set -e

  local terragrunt_dir
  local return_arr
  local account
  local environment
  local app
  local changeset

  return_arr="$1"
  terragrunt_dir="$2"
  account="$3"
  environment="$4"
  app="$5"
  changeset="$6"

  test -n "$return_arr"        || { echo "Variable 'return_arr' missing";           exit 110; }
  test -n "$terragrunt_dir"    || { echo "Variable 'terragrunt_dir' missing";       exit 111; }
  test -d "$terragrunt_dir"    || { echo "Directory 'terragrunt_dir' not found";    exit 112; }
  test -n "$account"           || { echo "Variable 'account' missing";              exit 113; }
  test -n "$environment"       || { echo "Variable 'environment' missing"           exit 114; }
  test -n "$app"               || { echo "Variable 'app' missing";                  exit 115; }
  test -n "$changeset"         || { echo "Variable 'changeset' missing";            exit 116; }

  declare -n return="$return_arr"

  yq() { docker run --rm -v $PWD:/workdir mikefarah/yq "$@"; }
  json_file=$(mktemp -p $PWD | egrep -o "[^/]+$")
  chmod +r $json_file

  ACCOUNT="$account" ENVIRONMENT="$environment" APP="$app" CHANGESET="$changeset" terragrunt output -json --terragrunt-working-dir "$terragrunt_dir" > $json_file

  return["bucket_arn"]=$(yq e '.spa_hosting_cdn.value.bucket_arn' "$json_file")
  return["bucket_id"]=$(yq e '.spa_hosting_cdn.value.bucket_id' "$json_file")
  return["bucket_name"]=$(yq e '.spa_hosting_cdn.value.bucket_name' "$json_file")
  return["bucket_domain_name"]=$(yq e '.spa_hosting_cdn.value.bucket_domain_name' "$json_file")
  return["bucket_url"]="s3://${return["bucket_id"]}"
  return["dns_alias_id"]=$(yq e '.spa_hosting_cdn.value.dns_alias_id' "$json_file")
  return["dns_www_alias_id"]=$(yq e '.spa_hosting_cdn.value.dns_www_alias_id' "$json_file")
  return["cloudfront_distribution_arn"]=$(yq e '.spa_hosting_cdn.value.cloudfront_distribution_arn' "$json_file")
  return["cloudfront_distribution_id"]=$(yq e '.spa_hosting_cdn.value.cloudfront_distribution_id' "$json_file")
  return["acm_certificate_arn"]=$(yq e '.spa_hosting_cdn.value.acm_certificate_arn' "$json_file")

  test -n "${return["bucket_arn"]}"                   || { echo "Output 'bucket_arn' missing";                    exit 100; }
  test -n "${return["bucket_id"]}"                    || { echo "Output 'bucket_id' missing";                     exit 101; }
  test -n "${return["bucket_name"]}"                  || { echo "Output 'bucket_name' missing";                   exit 102; }
  test -n "${return["bucket_domain_name"]}"           || { echo "Output 'bucket_domain_name' missing";            exit 103; }
  test -n "${return["dns_alias_id"]}"                 || { echo "Output 'dns_alias_id' missing";                  exit 104; }
  test -n "${return["dns_www_alias_id"]}"             || { echo "Output 'dns_www_alias_id' missing";              exit 105; }
  test -n "${return["cloudfront_distribution_arn"]}"  || { echo "Output 'cloudfront_distribution_arn' missing";   exit 106; }
  test -n "${return["cloudfront_distribution_id"]}"   || { echo "Output 'cloudfront_distribution_id' missing";    exit 107; }
  test -n "${return["acm_certificate_arn"]}"          || { echo "Output 'acm_certificate_arn' missing";           exit 108; }
}

#!/bin/bash

# shellcheck disable=SC2034
function get-s3-distribution-artifact-info() {
  local terragrunt_dir
  local return_arr

  return_arr="$1"
  terragrunt_dir="$2"

  test -n "$return_arr"        || { echo "Variable 'return_arr' missing";          exit 110; }
  test -n "$terragrunt_dir"    || { echo "Variable 'terragrunt_dir' missing";      exit 111; }
  test -f "$terragrunt_dir"    || { echo "Directory '$terragrunt_dir' not found";  exit 112; }

  declare -n return="$return_arr"

  json=$(terragrunt output -json --terragrunt-working-dir "$terragrunt_dir")

  return["bucket_arn"]=$(yq e '.spa_hosting_cdn.bucket_arn' <<< "$json")
  return["bucket_id"]=$(yq e '.spa_hosting_cdn.bucket_id' <<< "$json")
  return["bucket_name"]=$(yq e '.spa_hosting_cdn.bucket_name' <<< "$json")
  return["bucket_domain_name"]=$(yq e '.spa_hosting_cdn.bucket_domain_name' <<< "$json")
  return["bucket_url"]="s3://${return["bucket_id"]}"
  return["dns_alias_id"]=$(yq e '.spa_hosting_cdn.dns_alias_id' <<< "$json")
  return["dns_www_alias_id"]=$(yq e '.spa_hosting_cdn.dns_www_alias_id' <<< "$json")
  return["cloudfront_distribution_arn"]=$(yq e '.spa_hosting_cdn.cloudfront_distribution_arn' <<< "$json")
  return["cloudfront_distribution_id"]=$(yq e '.spa_hosting_cdn.cloudfront_distribution_id' <<< "$json")
  return["acm_certificate_arn"]=$(yq e '.spa_hosting_cdn.acm_certificate_arn' <<< "$json")

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

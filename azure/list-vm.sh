#!/bin/bash

while getopts ":s:g:t:" opt; do
  case ${opt} in
    s) subscription=$OPTARG
    ;;
    g) resgrp=$OPTARG
    ;;
    t) tenant=$OPTARG
    ;;
    \?)
      echo "Usage: $(basename $0) -t [tenant_id]"
      echo "Usage: $(basename $0) -s [subscription_id]"
      echo "Usage: $(basename $0) -s [subscription_id] -r [resourcegroup]"
      echo "Insert into {markup} in confluence"
      exit 1
    ;;
  esac
done

[[ $# -lt 2 ]] && exit 1

listvm() {
  local resgrp=$1
  az vm list -g ${resgrp} -d --output=json | jq -r '.[] | "\(.osProfile.computerName);\(.osProfile.adminUsername);\(.privateIps);\(.publicIps);\(.storageProfile.imageReference.publisher);\(.storageProfile.imageReference.sku)"' | awk -F";" -v resgrp="${resgrp}" '
  BEGIN {
    printf "h1. %s\n",resgrp
    printf "|| %-31s || %-31s || %-17s || %-17s || %-31s || %-31s ||\n", "Name","Internal Network","Public Network","Login","Password","OS"
  }
  {
    if ($7 == "false") {
      password = $7
    } else {
      password = "ssh key"
    }
    printf "| %-32s | %-32s | %-18s | %-18s | %-32s | %-32s |\n",$1,$3,$4,$2,password,$5" "$6
  }'
}

listvm_resgrp() {
  local resgrps=$1
  for resgrp in ${resgrps}; do
    listvm "${resgrp}"
    echo
  done
}

[[ -n ${resgrp} ]] && listvm

[[ -n ${tenant} ]] && subscriptions="$(az account list --output json | jq -r '.[] | select(.tenantId | match("'${tenant}'")) | .id')"

[[ -n ${subscription} ]] && az account set -s ${subscription}

[[ -z ${resgrp} ]] && [[ -z ${tenant} ]] && resgrps="$(az group list --output=json | jq -r '.[].name')" && listvm_resgrp "${resgrps}"

if [[ -n ${subscriptions} ]]; then
  for subscription in ${subscriptions}; do
    az account set -s ${subscription}
    resgrps="$(az group list --output=json | jq -r '.[].name')" && listvm_resgrp "${resgrps}"
  done
fi

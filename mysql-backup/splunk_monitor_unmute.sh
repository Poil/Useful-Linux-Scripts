#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

[[ $# != 1 ]] && exit 1

ENV=$1

[[ ! -e .config/splunk_monitor_${ENV} ]] && echo "No configuration exiting" && exit 0
source .config/splunk_monitor_${ENV}

[[ ! -f backup/splunk_monitor_${ENV}.flag ]] && exit 0
MUTING_ID=$(cat backup/splunk_monitor_${ENV}.flag)

RES=$(curl -X "DELETE" "${SFX_URL}/${MUTING_ID}" \
      -H 'X-SF-TOKEN: '${TOKEN}'' \
      -H 'Content-Type: application/json')

rm backup/splunk_monitor_${ENV}.flag
if [ $? -eq 0 ]; then
  echo -e "\nDetector has been unmuted\n"
fi

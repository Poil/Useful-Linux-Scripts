#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

[[ $# != 1 ]] && exit 1

ENV=$1

[[ ! -e .config/splunk_monitor_${ENV} ]] && echo "No configuration exiting" && exit 0
source .config/splunk_monitor_${ENV}


START_TIME=$(date  +%s%N | cut -b1-13)
END_TIME=$(date -d "+${DURATION} minutes"  +%s%N | cut -b1-13)
RES=$(curl -X "POST" "${SFX_URL}" \
      -H 'X-SF-TOKEN: '${TOKEN}'' \
      -H 'Content-Type: application/json' \
      -d $'{
        "startTime": "'"${START_TIME}"'",
        "stopTime": "'"${END_TIME}"'",
        "filters": [
          {
            "property": "azure_resource_name",
            "propertyValue": "'${HOST}'"
          },
	  {
            "property": "sf_detectorId",
            "propertyValue": "'${DETECTOR_ID}'"
          }
        ]
      }')

echo ${RES} | jq -r .id > backup/splunk_monitor_${ENV}.flag
if [ $? -eq 0 ]; then
  echo -e "\nDetector has been muted\n"
fi

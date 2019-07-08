#!/usr/bin/env bash
# From Gitlab and Harbor, rebuild container if vulnerability
# Parameters:
#  - Gitlab Project ID
#  - Gitlab Token
#  - Harbor repository
#  - Harbor Container name

# Get latest tag on gitlab
tag=$(curl --header "Private-Token: ${2}" \
    http://gitlab.engsec/api/v4/projects/${1}/repository/tags?order_by=updated | jq -r '.[0].name')

# Get vulnerability list from harbor for this tag
vuln=$(curl -s -k -H  "accept: application/json" -X GET \
    "https://harbor.engsec/api/repositories/${3}%2F${4}/tags/${tag}/vulnerability/details" | jq -r '.[].package' | uniq)

# If no vuln or only kernel-headers we ignore rebuild
# https://github.com/coreos/clair/issues/428
if [[ "${vuln}" != '' && "${vuln}" != 'kernel-headers' ]]; then
    # If already a vuln increase patch number
    if [[ $tag =~ ^[0-9]+\.[0-9]+\.[0-9]+([a-zA-Z0-9]+)?-[0-9]+$ ]]; then
        patch="$((${tag##*-} + 1))"
        tag="${tag%%-*}"
    else
        patch=1
    fi
    tag=${tag}-${patch}
    curl --header "Private-Token: ${2}" -X POST \
        "http://gitlab.engsec/api/v4/projects/${1}/repository/tags?tag_name=${tag}&ref=master"
fi

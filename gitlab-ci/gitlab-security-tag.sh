#!/usr/bin/env bash

project_id=$1
token=$2
namespace=$3
project=$4

build_vuln() {
    local tag=$1
    local branch=$2

    vuln=$(curl -s -k -H  "accept: application/json" -X GET \
        "https://harbor.engsec/api/repositories/${namespace}%2F${project}/tags/${tag}/vulnerability/details" | jq -r '.[].package' | uniq)
    
    if [[ "${vuln}" != '' && "${vuln}" != 'kernel-headers' ]]; then
        if [[ $tag =~ ^[0-9]+\.[0-9]+\.[0-9]+([a-zA-Z0-9]+)?-[0-9]+$ ]]; then
            patch="$((${tag##*-} + 1))"
            tag="${tag%%-*}"
        else
            patch=1
        fi
        tag=${tag}-${patch}
        curl --header "Private-Token: ${token}" -X POST \
            "http://gitlab.engsec/api/v4/projects/${project_id}/repository/tags?tag_name=${tag}&ref=${branch}"
    fi
}

tags=$(curl --header "Private-Token: ${token}" \
    http://gitlab.engsec/api/v4/projects/${project_id}/repository/tags?order_by=updated | jq -r '.[].name')

# main tag
for tag in ${tags}; do
  if [[ ${tag} =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9]+)?$ ]]; then
      [[ -z ${main_tag} ]] && main_tag=${tag}
      rpmdev-vercmp ${tag} ${main_tag}
      # ret_code 12 = X less than Y, ret_code 11 = X greater than Y
      [[ $? -eq 11 ]] && main_tag=${tag}
  fi
done

# dev tag
for tag in ${tags}; do
  if [[ ${tag} =~ ^[0-9]+\.[0-9]+\.[0-9]+-dev(-[0-9]+)?$ ]]; then
      [[ -z ${dev_tag} ]] && dev_tag=${tag}
      rpmdev-vercmp ${tag} ${dev_tag}
      # ret_code 12 = X less than Y, ret_code 11 = X greater than Y
      [[ $? -eq 11 ]] && dev_tag=${tag}
  fi
done

curl --header "Private-Token: ${token}" \
    http://gitlab.engsec/api/v4/projects/${project_id}/repository/tags/${main_tag} \
    | grep '404 Tag Not Found' >/dev/null || (echo Master Tag ${main_tag} already exists; exit 1)

curl --header "Private-Token: ${token}" \
    http://gitlab.engsec/api/v4/projects/${project_id}/repository/tags/${dev_tag} \
    | grep '404 Tag Not Found' >/dev/null || (echo Dev Tag ${dev_tag} already exists; exit 1)

[[ -n ${main_tag} ]] && build_vuln "$main_tag" "master"
[[ -n ${dev_tag} ]] && build_vuln "$dev_tag" "dev"

#!/usr/bin/env bash
project_id=$1
token=$2
branch=$3

tag=$(curl --header "Private-Token: ${token}" \
    http://gitlab.engsec/api/v4/projects/${project_id}/repository/tags?order_by=updated | jq -r '.[0].name')

newtag=$(echo $tag | perl -pe 's/^((\d+\.)*)(\d+)(.*)$/$1.($3+1).$4/e')

curl --header "Private-Token: ${token}" \
    http://gitlab.engsec/api/v4/projects/${project_id}/repository/tags/${newtag} \
    | grep '404 Tag Not Found' >/dev/null || (echo Tag ${newtag} already exists; exit 1)

curl --header "Private-Token: ${token}" -X POST \
    "http://gitlab.engsec/api/v4/projects/${project_id}/repository/tags?tag_name=${newtag}&ref=${branch}"

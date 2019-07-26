#!/usr/bin/env bash

[[ $# -ne 2 ]] && echo "Usage $(basename $0) repo_id \"package1,package2\"" && exit 1

d=$(pulp-admin -v python repo list --repo-id=$1 --details)

[[ -z "$d" ]] && echo "Error, empty repo $repo_id" && exit 2

d1="${d##*Package Names:}"
[[ -z "$d1" ]] && echo "Error, empty repo $repo_id" && exit 3

d2="${d1%%Proxy Host:*}"
[[ -z "$d2" ]] && echo "Error, empty repo $repo_id" && exit 4

d3=$(echo $d2 | sed -E -e 's/[[:blank:]]+/\n/g' | tr -d "\n")

echo "Appending $2 to $d3"
pulp-admin -v python repo update --repo-id="$1" --feed "https://pypi.python.org/" --package-names "$d3"
pulp-admin -v python repo sync run --repo-id="$1"
pulp-admin -v python repo sync publish --repo-id="$1"

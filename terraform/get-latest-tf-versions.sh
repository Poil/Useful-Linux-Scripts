#!/usr/bin/env bash

curl --silent https://releases.hashicorp.com/terraform/index.json | jq -r '[.versions[] | select(.version|test("(^0\\.[0-9]+\\.[0-9]+$)|(^1\\.[0-5]\\.[0-9]+$)")) | { "version_short": (.version |= split(".") | .version[0] + "." + .version[1]), "version_full": .version, "rev": (.version |= split(".") | (.version[2] | tonumber))}] | sort_by(.rev) | reverse | unique_by(.version_short)[] | [.version_short, .version_full] | @tsv'

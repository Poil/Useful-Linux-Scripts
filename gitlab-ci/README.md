# Intro

This script need Harbor
This script need gitlab tag in form of "M.m.p"
If a vulnerability is detected on Harbor, a tag will be create in form of "M.m.p-f" and a rebuild will be triggered

# Usage

- Create a service account and generate a token
- Declare this token on the gitlab project variables (named gitlab_token)
- Add gitlab-ci
- Create a tag



#!/bin/bash -eu

# See https://github.com/Automattic/bash-cache-buildkite-plugin/issues/16
gem install bundler:2.3.4

if [[ -z $DANGER_GITHUB_API_TOKEN ]]; then
  echo "Can't find DANGER_GITHUB_API_TOKEN"
fi

if [[ -z $GITHUB_TOKEN ]]; then
  echo "Can't find GITHUB_TOKEN"
fi

bundle install
bundle exec danger

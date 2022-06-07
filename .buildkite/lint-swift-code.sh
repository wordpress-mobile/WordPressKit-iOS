#!/bin/bash -eu

if [[ -z $COCOAPODS_TRUNK_TOKEN ]]; then
  echo "Can't find COCOAPODS_TRUNK_TOKEN" # Of course, this will fail because of the `-u` in the shebang
fi

if [[ -z $DANGER_GITHUB_API_TOKEN ]]; then
  echo "Can't find DANGER_GITHUB_API_TOKEN"
fi

echo "--- :rubygems: Setting up Gems"
# See https://github.com/Automattic/bash-cache-buildkite-plugin/issues/16
gem install bundler:2.3.4

install_gems

echo "--- :cocoapods: Setting up Pods"
install_cocoapods

echo "--- :swift::danger: Running SwiftLint via Danger"
bundle exec danger

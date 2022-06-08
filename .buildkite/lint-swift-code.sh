#!/bin/bash -eu

echo "--- :rubygems: Setting up Gems"
# See https://github.com/Automattic/bash-cache-buildkite-plugin/issues/16
gem install bundler:2.3.4

install_gems

echo "--- :cocoapods: Setting up Pods"
install_cocoapods

echo "--- :swift: Running SwiftLint via Danger"
bundle exec danger --fail-on-errors=true

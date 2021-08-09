#!/bin/bash -eu

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :cocoapods: Setting up Pods"
install_cocoapods

echo "--- :microscope: Validate Podspec"
# For some reason this fixes a failure in `lib lint`
# https://github.com/Automattic/buildkite-ci/issues/7
xcrun simctl list >> /dev/null

bundle exec pod lib lint --verbose --fail-fast

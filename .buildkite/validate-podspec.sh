#!/bin/bash

set -e

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :cocoapods: Setting up Pods"
install_cocoapods

echo "--- :microscope: Validate Podspec"
xcrun simctl list >> /dev/null # For some reason this fixes a failure in `lib lint`
bundle exec pod lib lint --verbose --fail-fast

#!/bin/bash -eu

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :cocoapods: Setting up Pods"
install_cocoapods

echo "--- :test_tube: Building and Running Tests"
bundle exec fastlane test

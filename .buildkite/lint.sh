#!/bin/bash -eu

echo "--- :rubygems: Setting up Gems"
bundle install

echo "--- :rubygems: Checking Gemfile.lock"
validate_gemfile_lock

echo "--- :rubocop: Running Rubocop"
bundle exec rubocop

echo "--- :cocoapods: Checking Podfile.lock"
validate_podfile_lock

# TODO: Add swiftlint

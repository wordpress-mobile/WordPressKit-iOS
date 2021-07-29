#!/bin/bash

set -e

echo "--- :rubygems: Setting up Gems"
bundle install

echo "--- :rubocop: Running Rubocop"
bundle exec rubocop

# TODO: Add swiftlint

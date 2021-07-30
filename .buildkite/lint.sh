#!/bin/bash

set -e

echo "--- :rubygems: Setting up Gems"
bundle install

echo "--- :rubygems: Checking Gemfile.lock"
# This will only work if it goes after `bundle install` – don't try to run it first
if [ -n "$(git status | grep modified | grep Gemfile.lock)" ]; then 
	echo "Error: Gemfile.lock is not in sync – please run \`bundle install\` and commit your changes"
	exit 1
fi 

echo "--- :rubocop: Running Rubocop"
bundle exec rubocop

echo "Gemfile.lock is in sync"

echo "--- :cocoapods: Checking Podfile.lock"
bundle exec pod check

# This will only work if it goes after `pod install` – don't try to run it first
if [ -n "$(git status | grep modified | grep Podfile.lock)" ]; then 
	echo "Error: Podfile.lock is not in sync – please run \`bundle exec pod install\` and commit your changes"
	exit 1
fi 

# TODO: Add swiftlint

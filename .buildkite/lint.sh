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
PODFILE_SHA1=$(ruby -e "require 'yaml';puts YAML.load_file('Podfile.lock')['PODFILE CHECKSUM']")
RESULT=$(echo "$PODFILE_SHA1 *Podfile" | shasum -c)

# This will only work if it goes after `pod install` – don't try to run it first
if [[ $RESULT != "Podfile: OK" ]]; then 
	echo "Error: Podfile.lock is not in sync – please run \`bundle exec pod install\` and commit your changes"
	exit 1
fi 

# TODO: Add swiftlint

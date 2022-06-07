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
set +e
bundle exec danger > danger_output
DANGER_EXIT_CODE=$?

echo "Danger finished with: $DANGER_EXIT_CODE"
if [ "$DANGER_EXIT_CODE" -ne 0 ] ; then
    echo "Danger failed the build"
    # FIXME: ShellCheck tells us this cat is useless (SC2002)
    cat danger_output | buildkite-agent annotate \
      --style 'error' \
      --context 'ctx-error' \
    exit 1
fi

# Now that we don't need to trap error codes to annotate the build with extra
# info, fail the script if a commands it calls fails.
#
# It's sort of unnecessary to do this here because the script is finished, but
# useful in case we'll add code in the future.
set -e

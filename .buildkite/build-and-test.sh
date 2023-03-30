#!/bin/bash -u

set +e
build_and_test_pod
TESTS_EXIT_STATUS=$?
set -e

if [[ $TESTS_EXIT_STATUS -ne 0 ]]; then
  # Keep the (otherwise collapsed) current "Testing" section open in Buildkite logs on error. See https://buildkite.com/docs/pipelines/managing-log-output#collapsing-output
  echo "^^^ +++"
  echo "Tests failed!"
fi

echo "--- 📦 Zipping test results"
cd fastlane/test_output/ && zip -rq WordPressKit.xcresult.zip WordPressKit.xcresult && cd -

echo "--- 🚦 Report Tests Status"
if [[ $TESTS_EXIT_STATUS -eq 0 ]]; then
  echo "Tests seems to have passed (exit code 0). All good 👍"
else
  echo "The tests have failed."
  echo "For more details about the failed tests, check the Buildkite annotation, the logs under the '🧪 Building and Running Tests' section and the \`.xcresult\` and test reports in Buildkite artifacts."
fi
annotate_test_failures "fastlane/test_output/report.junit"

exit $TESTS_EXIT_STATUS

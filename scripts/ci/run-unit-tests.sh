#!/bin/bash

set -xo pipefail

CONFIGURATION_BUILD_DIR="$PARRA_TEST_DERIVED_DATA_DIRECTORY"

test() {
    rm -rf "$PARRA_TEST_OUTPUT_DIRECTORY"

    xcodebuild test-without-building \
        -project "$PARRA_TEST_PROJECT_NAME" \
        -scheme "$PARRA_TEST_SCHEME_NAME" \
        -configuration "$PARRA_TEST_CONFIGURATION" \
        -destination "$PARRA_TEST_DESTINATION" \
        -derivedDataPath "$PARRA_TEST_DERIVED_DATA_DIRECTORY" \
        -resultBundlePath "$PARRA_TEST_OUTPUT_DIRECTORY"
        # -parallel-testing-enabled yes \
        # -parallel-testing-worker-count 2 \
        # -maximum-parallel-testing-workers 4 \
        | xcbeautify --is-ci --junit-report-filename artifacts/junit-results.xml
    RESULT=$?
}

test
# ! grep --max-count=1 'Early unexpected exit, operation never finished bootstrapping' "$OUTDIR"/TestSummaries.plist && break

# ./scripts/plist2junit.rb "$OUTDIR"/TestSummaries.plist >"$OUTDIR"/report.junit

exit $RESULT

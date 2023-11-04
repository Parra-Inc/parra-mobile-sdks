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
        -resultBundlePath "$PARRA_TEST_OUTPUT_DIRECTORY" |
        xcbeautify --is-ci --junit-report-filename artifacts/junit-results.xml
    RESULT=$?
}

for run in {1..5}; do
    test

    # ! grep --max-count=1 'Early unexpected exit, operation never finished bootstrapping' "$OUTDIR"/TestSummaries.plist && break
done

# ./scripts/plist2junit.rb "$OUTDIR"/TestSummaries.plist >"$OUTDIR"/report.junit

exit $RESULT

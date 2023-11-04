#!/bin/bash

set -xo pipefail

export CONFIGURATION_BUILD_DIR="$PARRA_TEST_DERIVED_DATA_DIRECTORY"

build() {
    NSUnbufferedIO=YES set -o pipefail &&
        xcodebuild build-for-testing \
            -project "$PARRA_TEST_PROJECT_NAME" \
            -scheme "$PARRA_TEST_SCHEME_NAME" \
            -configuration "$PARRA_TEST_CONFIGURATION" \
            -destination "$PARRA_TEST_DESTINATION" \
            -derivedDataPath "$PARRA_TEST_DERIVED_DATA_DIRECTORY" |
        tee buildlog |
            xcbeautify --is-ci --junit-report-filename artifacts/junit-results.xml

    RESULT=$?

    return $RESULT
}

if ! build && grep 'error: Cycle' buildlog; then
    rm -rf "$DATADIR"
    build
fi

exit $RESULT

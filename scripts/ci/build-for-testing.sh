#!/bin/bash

set -xo pipefail

DATADIR=build/unit-tests/derivedData
export CONFIGURATION_BUILD_DIR="${DERIVED_DATA[@]}"

build() {
    NSUnbufferedIO=YES set -o pipefail &&
        xcodebuild build-for-testing \
            -project ./Parra.xcodeproj \
            -scheme Parra \
            -configuration "Debug" \
            -destination 'generic/platform=iOS,name=iPhone 15,OS=latest' \
            -derivedDataPath "$DATADIR" |
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

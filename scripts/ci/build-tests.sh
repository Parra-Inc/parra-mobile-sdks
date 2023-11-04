#!/bin/bash

set -xo pipefail

DATADIR=build/unit-tests/derivedData
DERIVED_DATA=(-derivedDataPath "$DATADIR")

build() {
    set -o pipefail && \
    NSUnbufferedIO=YES \
        xcodebuild \
        -project ./Parra.xcodeproj \
        -scheme Parra \
        -configuration "Debug" \
        -destination 'generic/platform=iOS,name=iPhone 15,OS=17.0.1' \
        # -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0.1' \
        ${DERIVED_DATA[@]} build-for-testing \
        | tee buildlog \
        | xcbeautify --is-ci --junit-report-filename artifacts/junit-results.xml
    
    RESULT=$?
    
    return $RESULT
}

if ! build && grep 'error: Cycle' buildlog; then
    rm -rf "$DATADIR"
    build
fi

exit $RESULT

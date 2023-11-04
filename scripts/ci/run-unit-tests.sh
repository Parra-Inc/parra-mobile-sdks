#!/bin/bash

set -xo pipefail

export CONFIGURATION_BUILD_DIR="$DERIVED_DATA_DIRECTORY"

DATADIR=derivedData
OUTDIR=output
DERIVED_DATA=(-derivedDataPath "$DATADIR")
OUTPUT=(-resultBundlePath "$OUTDIR")

test() {
    rm -rf "$OUTDIR"
    xcodebuild -scheme Tests -project ./MyApp.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 6' ${DERIVED_DATA[@]} ${OUTPUT[@]} test-without-building | bundle exec xcpretty --color
    RESULT=$?
}

for run in {1..5}; do
    test

    ! grep --max-count=1 'Early unexpected exit, operation never finished bootstrapping' "$OUTDIR"/TestSummaries.plist && break
done

./scripts/plist2junit.rb "$OUTDIR"/TestSummaries.plist >"$OUTDIR"/report.junit

exit $RESULT

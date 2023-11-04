#!/bin/bash

set -xo pipefail

CONFIGURATION_BUILD_DIR="$PARRA_TEST_DERIVED_DATA_DIRECTORY"
# -authenticationKeyPath is required to be an absolute path. It makes more sense to convert it
# from a relative path here, since it's possible that Circle will rename the user home directory
# in the future.
ABSOLUTE_KEY_PATH=$(realpath $PARRA_ASC_API_KEY_PATH)

build() {
    # ARGS:
    # -allowProvisioningUpdates and -allowProvisioningDeviceRegistration are required to enable -authentication... flags.
    CODE_SIGNING_ALLOWED=NO NSUnbufferedIO=YES set -o pipefail &&
        xcodebuild build-for-testing \
            -project "$PARRA_TEST_PROJECT_NAME" \
            -scheme "$PARRA_TEST_SCHEME_NAME" \
            -configuration "$PARRA_TEST_CONFIGURATION" \
            -destination "$PARRA_TEST_DESTINATION" \
            -allowProvisioningUpdates \
            -allowProvisioningDeviceRegistration \
            -authenticationKeyPath "$ABSOLUTE_KEY_PATH" \
            -authenticationKeyID "$ASC_API_KEY_ID" \
            -authenticationKeyIssuerID "$ASC_API_ISSUER_ID" \
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

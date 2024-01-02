#! /bin/bash

# This is used instead of the macOS ORB's preboot-simulator step, since it takes too long to return.

deviceId=`./cli/bin/obtain-simulator-device-id.sh "$PARRA_TEST_DEVICE_NAME" "$PARRA_TEST_DEVICE_OS_VERSION"`

echo "Booting simulator with device ID: $deviceId"

# Store the device ID in an environment variable so it can be used by other steps.
export PARRA_TEST_DEVICE_UDID="$deviceId"

# Boot the device but don't wait for it to finish. We want to get through other preparations while it's booting
# and there will be another task later that waits for it to finish booting before starting tests.
nohup xcrun simctl boot $deviceId --arch=arm64 & 

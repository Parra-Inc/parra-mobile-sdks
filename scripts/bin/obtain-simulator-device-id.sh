#! /bin/bash

# Obtains the UDID of the first available simulator device matching the input args.
# Args should be: <device name (iPhone 15)> <os version (17.2)>

log() {
    echo "$1" >&2
}


if [ -z "$1" ]; then
    log "Device name not specified."
    exit 1
fi

if [ -z "$2" ]; then
    log "Device OS version not specified."
    exit 1
fi

deviceName="$1"
deviceOsVersion="$2"


log "Searching for iOS simulator matching $deviceName ($deviceOsVersion)"

ESCAPED_VER=$(echo "$2" | tr '.' '-')
SIMREQ="iOS-${ESCAPED_VER}"
SIMLIST=$(xcrun simctl list -j)

found=$(echo "${SIMLIST}" | jq -r ".devices.\"com.apple.CoreSimulator.SimRuntime.${SIMREQ}\"[] | select(.name==\"$1\").udid")

if [ -z "$found" ]; then
    >&2 echo "Unable to find matching device!"
    exit 2
fi

log "Found matching device: $found"

echo "$found"

exit 0
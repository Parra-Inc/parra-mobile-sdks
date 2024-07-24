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

found=$(applesimutils --byName "$deviceName" --byOS "$deviceOsVersion" --list --maxResults 1 | jq '.[0].udid' -r)

# Sample response JSON from applesimutils:
# {
#   "os": {
#     "bundlePath": "/Library/Developer/CoreSimulator/Volumes/iOS_21C62/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 17.2.simruntime",
#     "buildversion": "21C62",
#     "platform": "iOS",
#     "runtimeRoot": "/Library/Developer/CoreSimulator/Volumes/iOS_21C62/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 17.2.simruntime/Contents/Resources/RuntimeRoot",
#     "identifier": "com.apple.CoreSimulator.SimRuntime.iOS-17-2",
#     "version": "17.2",
#     "isInternal": false,
#     "isAvailable": true,
#     "name": "iOS 17.2",
#     "supportedDeviceTypes": [
#       {
#         "bundlePath": "/Applications/Xcode-15.1.0.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/DeviceTypes/iPhone Xs.simdevicetype",
#         "name": "iPhone Xs",
#         "identifier": "com.apple.CoreSimulator.SimDeviceType.iPhone-XS",
#         "productFamily": "iPhone"
#       },
#       // .... many more devices
#     ]
#   },
#   "dataPath": "/Users/mick/Library/Developer/CoreSimulator/Devices/CEA23780-96E6-44F5-8ED9-0D6EDE193CDF/data",
#   "dataPathSize": 18337792,
#   "logPath": "/Users/mick/Library/Logs/CoreSimulator/CEA23780-96E6-44F5-8ED9-0D6EDE193CDF",
#   "udid": "CEA23780-96E6-44F5-8ED9-0D6EDE193CDF",
#   "isAvailable": true,
#   "deviceType": {
#     "maxRuntimeVersion": 4294967295,
#     "bundlePath": "/Applications/Xcode-15.1.0.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/DeviceTypes/iPhone 15.simdevicetype",
#     "maxRuntimeVersionString": "65535.255.255",
#     "name": "iPhone 15",
#     "identifier": "com.apple.CoreSimulator.SimDeviceType.iPhone-15",
#     "productFamily": "iPhone",
#     "modelIdentifier": "iPhone15,4",
#     "minRuntimeVersionString": "17.0.0",
#     "minRuntimeVersion": 1114112
#   },
#   "deviceTypeIdentifier": "com.apple.CoreSimulator.SimDeviceType.iPhone-15",
#   "state": "Shutdown",
#   "name": "iPhone 15"
# }

if [ -z "$found" ]; then
    >&2 echo "Unable to find matching device!"
    exit 2
fi

log "Found matching device: $found"

echo "$found"

exit 0
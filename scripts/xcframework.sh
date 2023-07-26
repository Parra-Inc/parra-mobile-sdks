#!/bin/bash

xcodebuild archive \
    -project Parra.xcodeproj \
    -scheme ParraCore \
    -destination "generic/platform=iOS" \
    -archivePath "archives/Parra" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive \
    -project Parra.xcodeproj \
    -scheme ParraCore \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "archives/Parra-Simulator" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \

xcodebuild -create-xcframework \
        -framework "archives/Parra-Simulator.xcarchive/Products/Library/Frameworks/Parra.framework" \
        -framework "archives/Parra.xcarchive/Products/Library/Frameworks/Parra.framework" \
        -output "xcframeworks/Parra.xcframework"

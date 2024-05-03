// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Parra",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .library(name: "Parra", targets: ["Parra"]) // type: .static, .dynamic
    ],
    targets: [
        .target(
            name: "Parra",
            dependencies: [],
            // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/adding_a_privacy_manifest_to_your_app_or_third-party_sdk
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "ParraTests",
            dependencies: ["Parra"]
        )
    ],
    swiftLanguageVersions: [.version("5.9")]
)

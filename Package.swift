// swift-tools-version:5.9

import PackageDescription

let iosSdkDir = "sdks/ios"

let package = Package(
    name: "Parra",
    defaultLocalization: "en",
    platforms: [
        .iOS("17.0"),
    ],
    products: [
        .library(
            name: "Parra",
            targets: [
                "Parra",
            ]
        ),
    ],
    targets: [
        .target(
            name: "Parra",
            dependencies: [],
            path: "\(iosSdkDir)/Sources/Parra",
            exclude: [],
            resources: [
                // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/adding_a_privacy_manifest_to_your_app_or_third-party_sdk
                .process("PrivacyInfo.xcprivacy"),
                .process("Resources/ParraAssets.xcassets")
            ]
        ),
        .testTarget(
            name: "ParraTests",
            dependencies: [
                "Parra",
            ],
            path: "\(iosSdkDir)/Tests"
        ),
    ],
    swiftLanguageVersions: [.version("5.9")]
)

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("BareSlashRegexLiterals"),
]

for target in package.targets {
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(contentsOf: swiftSettings)
}

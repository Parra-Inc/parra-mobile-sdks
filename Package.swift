// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Parra",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .library(
            name: "Parra",
            targets: ["Parra"]
            // type: .static, .dynamic
        )
    ],
    targets: [
        .target(
            name: "Parra",
            dependencies: [],
            exclude: ["Resources/README.md"],
            resources: [
                // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/adding_a_privacy_manifest_to_your_app_or_third-party_sdk
                .process("PrivacyInfo.xcprivacy"),
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "ParraTests",
            dependencies: ["Parra"]
        )
    ],
    swiftLanguageVersions: [.version("5.9")]
)

let swiftSettings: [SwiftSetting] = [
    // -enable-bare-slash-regex becomes
    .enableUpcomingFeature("BareSlashRegexLiterals")
    // -warn-concurrency becomes
    // .enableUpcomingFeature("StrictConcurrency"),
    // .unsafeFlags(["-enable-actor-data-race-checks"],
    //     .when(configuration: .debug)),
]

for target in package.targets {
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(contentsOf: swiftSettings)
}

// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let iosSdkDir = "ios"

let package = Package(
    name: "Parra",
    defaultLocalization: "en",
    platforms: [
        .iOS("17.0"),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Parra",
            targets: [
                "Parra"
            ]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Parra",
            path: "\(iosSdkDir)/Sources/Parra",
            resources: [
                // Xcode doesn’t recognize privacy manifest files as resources by default.
                // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/adding_a_privacy_manifest_to_your_app_or_third-party_sdk/
                .process("PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "ParraTests",
            dependencies: ["Parra"],
            path: "\(iosSdkDir)/Tests/ParraTests"
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

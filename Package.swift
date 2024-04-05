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
            dependencies: []
        ),
        .testTarget(
            name: "ParraTests",
            dependencies: ["Parra"]
        )
    ],
    swiftLanguageVersions: [.version("5.9")]
)

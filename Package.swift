// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "Parra",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Parra", targets: ["Parra"])
        ],
        dependencies: [],
        targets: [
            .target(
                name: "Parra",
                path: "Parra",
                sources: ["Classes"]),
    ]
)

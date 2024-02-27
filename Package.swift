// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "WordPressKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "RFC3339",
            targets: ["RFC3339"]
        )
    ],
    targets: [
        .target(
            name: "RFC3339",
            path: "RFC3339",
            publicHeadersPath: "." // publicHeadersPath is relative to path
        )
    ]
)

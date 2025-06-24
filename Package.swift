// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "WordPressKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "WordPressKit", targets: ["WordPressKit"]),
    ],
    targets: [
        .binaryTarget(
            name: "WordPressKit",
            url: "https://github.com/user-attachments/files/20825728/WordPressKit.zip",
            checksum: "097a2e55e4ec66b4d8c37bc49181df33c4b62ea9d130fac4de057a0867b68a69"
        ),
    ]
)

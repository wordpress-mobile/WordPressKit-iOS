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
            url: "https://github.com/user-attachments/files/19329609/WordPressKit.zip",
            checksum: "0b29beaa2001b00f38b8d3ecae411ea100bd9867e17c86d0128fa995a7597b55"
        ),
    ]
)

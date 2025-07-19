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
            url: "https://github.com/user-attachments/files/21328988/WordPressKit.zip",
            checksum: "963e7189b0b2e207267c94138f2b08dd2d26d3fc5cbedae8b38d49a2c1e7d72b"
        ),
    ]
)

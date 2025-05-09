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
            url: "https://github.com/user-attachments/files/20124623/WordPressKit.zip",
            checksum: "fb3d6043a07ffe1ba50bbbf3ca8daaa001bff7f05273bad2a113c89705400b1b"
        ),
    ]
)

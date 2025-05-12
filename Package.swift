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
            url: "https://github.com/user-attachments/files/20127687/WordPressKit.zip",
            checksum: "13aa0e5952616a2f01a0f0db370ee7925d58253c2aab6e216671e8a013ab471b"
        ),
    ]
)

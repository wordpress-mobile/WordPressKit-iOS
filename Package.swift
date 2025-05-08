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
            url: "https://github.com/user-attachments/files/20105676/WordPressKit.zip",
            checksum: "6a446e44dda98d3f5d0d916fbd946d1bf602dfb6124e4ce01aeb7a0c161ee3f6"
        ),
    ]
)

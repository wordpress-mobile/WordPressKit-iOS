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
            url: "https://github.com/user-attachments/files/19338252/WordPressKit.zip",
            checksum: "e91be125b5d4e3ba98a0c06b32c71f428cbf3ab1aaa8da08598177ebd24d9a1a"
        ),
    ]
)

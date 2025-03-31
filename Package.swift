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
            url: "https://github.com/user-attachments/files/19533607/WordPressKit.zip",
            checksum: "d0c8d8994a64ff7ac0cf0fb1cc23c4fa419df011406c327f716b40af7dd8faa0"
        ),
    ]
)

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
            url: "https://github.com/user-attachments/files/17435956/WordPressKit.zip",
            checksum: "b3babe54d211d862e485ab3a742080dc9f2a5f04e2a6fa1d675545b0d00a795e"
        ),
    ]
)

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
            url: "https://github.com/user-attachments/files/21474850/WordPressKit.zip",
            checksum: "4621e8faa2ce9c7ef847008b044ac9e04e733e6d8ede9e4a424eeb8c832b85c3"
        ),
    ]
)

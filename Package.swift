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
            url: "https://github.com/user-attachments/files/20062492/WordPressKit.zip",
            checksum: "dd2bcc029d1d0bdc1b973f006d4c5cb9f0a6219a1fbfd82392c28be8c0bbe2a3"
        ),
    ]
)

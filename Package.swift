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
            url: "https://github.com/user-attachments/files/19338447/WordPressKit.zip",
            checksum: "309f0960e8881e174bec2f9c0f2d833c6c5926e952394bfa87eb532d92709eac"
        ),
    ]
)

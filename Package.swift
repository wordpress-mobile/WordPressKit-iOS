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
            url: "https://github.com/user-attachments/files/19338050/WordPressKit.zip",
            checksum: "b54214abf4a67e3349ce191463cffe908ec3b5dc2c0989fe5a616c660e1edaa8"
        ),
    ]
)

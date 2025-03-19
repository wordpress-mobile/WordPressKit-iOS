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
            url: "https://github.com/user-attachments/files/19337867/WordPressKit.zip",
            checksum: "03c45998c7dbb58c2a5a6799c066037b33762b93545d9de764397b7e8ad4173d"
        ),
    ]
)

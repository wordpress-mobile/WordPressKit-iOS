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
            url: "https://github.com/user-attachments/files/21350975/WordPressKit.zip",
            checksum: "dc40a4c09af565c16eca2ca0cd110c57ed4e8638ea4baeb2cf1bd124b07d3f8e"
        ),
    ]
)

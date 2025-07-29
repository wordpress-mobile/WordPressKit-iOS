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
            url: "https://github.com/user-attachments/files/21488685/WordPressKit.zip",
            checksum: "c591b9d12fdfeeedf7f31d884c6ce751722a37ae8ebb396a511fdb045698bccd"
        ),
    ]
)

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
            url: "https://github.com/user-attachments/files/19949703/WordPressKit.zip",
            checksum: "68359fda96ca0c7f9d98130c19b6246c2aa2dfdd3ede736be5330270f5e7abdd"
        ),
    ]
)

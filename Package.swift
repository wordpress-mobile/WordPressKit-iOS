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
            url: "https://github.com/user-attachments/files/19034102/WordPressKit.zip",
            checksum: "1d845ec9b6b22ae82f309dc7909333b952ca28a523b8e483230f4d3884ef0a0f"
        ),
    ]
)

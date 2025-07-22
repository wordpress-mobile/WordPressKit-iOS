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
            url: "https://github.com/user-attachments/files/21373882/WordPressKit.zip",
            checksum: "57a23a1340f2a9d24f1848b337da89c3556f1440767d91cc2a5ee8a6fe16b79b"
        ),
    ]
)
